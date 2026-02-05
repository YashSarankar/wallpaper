import 'dart:io';
import 'dart:math';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wallpaper/l10n/app_localizations.dart';
import 'package:workmanager/workmanager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/services/local_storage_service.dart';
import 'presentation/providers/wallpaper_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/screens/splash_screen.dart';

import 'package:async_wallpaper/async_wallpaper.dart';

const String autoChangeTask = "com.amozea.wallpapers.autoChange";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      debugPrint('--- WORKMANAGER TASK STARTED ---');
      WidgetsFlutterBinding.ensureInitialized();

      // Ensure Hive is initialized and boxes are open
      await LocalStorageService.init();

      final prefs = await SharedPreferences.getInstance();
      final isEnabled = prefs.getBool('autoChangeEnabled') ?? false;

      debugPrint('Auto-change status: $isEnabled');

      if (!isEnabled) {
        debugPrint('Auto-change is disabled in settings. Skipping.');
        return true;
      }

      final favorites = LocalStorageService.getFavorites();
      debugPrint('Favorites count: ${favorites.length}');

      if (favorites.isEmpty) {
        debugPrint('No favorites found. Skipping.');
        return true;
      }

      final random = Random();
      final wallpaper = favorites[random.nextInt(favorites.length)];
      debugPrint('Selected wallpaper: ${wallpaper.id} (${wallpaper.url})');

      String? finalPath;

      if (wallpaper.url.startsWith('http')) {
        debugPrint('Downloading image from URL...');
        http.Response? response;
        int retries = 0;
        while (retries < 3) {
          try {
            response = await http
                .get(
                  Uri.parse(wallpaper.url),
                  headers: {
                    'User-Agent':
                        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
                  },
                )
                .timeout(const Duration(seconds: 45));

            if (response.statusCode == 200) break;
            debugPrint(
              'Download failed with status: ${response.statusCode}. Retrying...',
            );
          } catch (e) {
            debugPrint('Download error: $e');
          }
          retries++;
          await Future.delayed(const Duration(seconds: 5));
        }

        if (response != null && response.statusCode == 200) {
          final tempDir = await getTemporaryDirectory();
          final file = File('${tempDir.path}/auto_wallpaper.png');
          await file.writeAsBytes(response.bodyBytes);
          finalPath = file.path;
          debugPrint('Image saved to: $finalPath');
        } else {
          debugPrint('Failed to download image after retries.');
        }
      } else {
        finalPath = wallpaper.url;
        debugPrint('Using local file path: $finalPath');
      }

      if (finalPath != null && await File(finalPath).exists()) {
        try {
          debugPrint('Setting wallpaper...');
          await AsyncWallpaper.setWallpaperFromFile(
            filePath: finalPath,
            wallpaperLocation: AsyncWallpaper.BOTH_SCREENS,
          );

          await prefs.setInt(
            'lastAutoChange',
            DateTime.now().millisecondsSinceEpoch,
          );
          debugPrint('--- WALLPAPER CHANGED SUCCESSFULLY ---');
        } catch (e) {
          debugPrint('Error setting wallpaper: $e');
          return false;
        }
      } else {
        debugPrint('Final path is null or file does not exist.');
      }

      return true;
    } catch (e) {
      debugPrint('CRITICAL TASK ERROR: $e');
      return false;
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.init();

  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

  // Initialize Mobile Ads SDK
  await MobileAds.instance.initialize();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  Locale _getLocale(String language) {
    switch (language) {
      case 'Spanish':
        return const Locale('es');
      case 'French':
        return const Locale('fr');
      case 'Hindi':
        return const Locale('hi');
      case 'Japanese':
        return const Locale('ja');
      default:
        return const Locale('en');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'Amozea',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
        Locale('es'),
        Locale('fr'),
        Locale('ja'),
      ],
      locale: _getLocale(settings.language),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}

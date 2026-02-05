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
import 'data/models/wallpaper_model.dart';
import 'presentation/providers/wallpaper_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/screens/splash_screen.dart';

import 'package:async_wallpaper/async_wallpaper.dart';

const String autoChangeTask = "com.amozea.wallpapers.autoChange";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      await LocalStorageService.init();

      final prefs = await SharedPreferences.getInstance();
      final isEnabled = prefs.getBool('autoChangeEnabled') ?? false;

      // Removed force inputData check as testing mode is removed
      if (!isEnabled) return true;

      final favorites = LocalStorageService.getFavorites();
      if (favorites.isEmpty) return true;

      final random = Random();
      final wallpaper = favorites[random.nextInt(favorites.length)];

      String? finalPath;

      if (wallpaper.url.startsWith('http')) {
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
                .timeout(const Duration(seconds: 30));

            if (response.statusCode == 200) break;
          } catch (e) {
            // Silently fail retries
          }
          retries++;
          await Future.delayed(const Duration(seconds: 2));
        }

        if (response != null && response.statusCode == 200) {
          final tempDir = await getTemporaryDirectory();
          final file = File('${tempDir.path}/auto_wallpaper.png');
          await file.writeAsBytes(response.bodyBytes);
          finalPath = file.path;
        }
      } else {
        finalPath = wallpaper.url;
      }

      if (finalPath != null && await File(finalPath).exists()) {
        try {
          // Set wallpaper using async_wallpaper package
          await AsyncWallpaper.setWallpaperFromFile(
            filePath: finalPath,
            wallpaperLocation: AsyncWallpaper.BOTH_SCREENS,
          );

          await prefs.setInt(
            'lastAutoChange',
            DateTime.now().millisecondsSinceEpoch,
          );
        } catch (e) {
          return false;
        }
      }

      return true;
    } catch (e) {
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

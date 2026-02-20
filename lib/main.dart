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

      final bool isAnimated = wallpaper.type == 'animated';
      final String downloadUrl = isAnimated
          ? (wallpaper.videoUrl ?? wallpaper.url)
          : wallpaper.url;
      final String extension = isAnimated ? 'mp4' : 'png';

      String? finalPath;

      if (downloadUrl.startsWith('http')) {
        debugPrint(
          'Downloading ${isAnimated ? "video" : "image"} from URL: $downloadUrl',
        );
        http.Response? response;
        int retries = 0;
        while (retries < 3) {
          try {
            response = await http
                .get(
                  Uri.parse(downloadUrl),
                  headers: {
                    'User-Agent':
                        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
                  },
                )
                .timeout(const Duration(seconds: 60));

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
          final file = File('${tempDir.path}/auto_wallpaper.$extension');
          await file.writeAsBytes(response.bodyBytes);
          finalPath = file.path;
          debugPrint('File saved to: $finalPath');
        } else {
          debugPrint('Failed to download file after retries.');
        }
      } else {
        finalPath = downloadUrl;
        debugPrint('Using local file path: $finalPath');
      }

      if (finalPath != null && await File(finalPath).exists()) {
        try {
          const platform = MethodChannel(
            'com.amozea.wallpapers/wallpaper_background',
          );

          if (isAnimated) {
            debugPrint('Handling animated wallpaper change...');
            final bool isLiveActive = await platform.invokeMethod(
              'isLiveWallpaperActive',
            );

            if (isLiveActive) {
              debugPrint(
                'Live wallpaper ACTIVE. Silently updating video path.',
              );
              await platform.invokeMethod('updateLiveWallpaperSilent', {
                'path': finalPath,
              });
            } else {
              debugPrint('Live wallpaper NOT active. Setting static cover.');
              // We need the static image, not the video file
              // Download the cover (wallpaper.midUrl or wallpaper.url)
              final coverUrl = wallpaper.midUrl ?? wallpaper.url;
              final tempDir = await getTemporaryDirectory();
              final coverFile = File('${tempDir.path}/auto_fallback.png');

              final response = await http
                  .get(Uri.parse(coverUrl))
                  .timeout(const Duration(seconds: 30));
              if (response.statusCode == 200) {
                await coverFile.writeAsBytes(response.bodyBytes);
                await platform.invokeMethod('setStaticWallpaper', {
                  'path': coverFile.path,
                  'location': 3, // Both screens
                });
                debugPrint('Fallback static wallpaper set.');
              }
            }
          } else {
            debugPrint('Setting static wallpaper via native channel...');
            await platform.invokeMethod('setStaticWallpaper', {
              'path': finalPath,
              'location': 3, // Both screens
            });
          }

          await prefs.setInt(
            'lastAutoChange',
            DateTime.now().millisecondsSinceEpoch,
          );
          debugPrint('--- WALLPAPER CHANGED SUCCESSFULLY ---');
        } catch (e) {
          debugPrint('Error setting wallpaper in background: $e');
          // Still return true to avoid Workmanager blocking the task
          return true;
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

  // Only await essential local storage
  await LocalStorageService.init();

  // Initialize these in background without awaiting to speed up cold start
  Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  MobileAds.instance.initialize();

  // Enable Edge-to-Edge for Android 15+ compatibility
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

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

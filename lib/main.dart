import 'dart:io';

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
import 'presentation/providers/live_wallpaper_provider.dart';
import 'presentation/screens/splash_screen.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const String autoChangeTask = "com.amozea.wallpapers.autoChange";

// Notification setup
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      debugPrint('--- WORKMANAGER TASK STARTED ($task) ---');
      WidgetsFlutterBinding.ensureInitialized();

      // Initialize Notifications inside the background task
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/launcher_icon');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);
      await flutterLocalNotificationsPlugin.initialize(
        settings: initializationSettings,
      );

      // Ensure Hive is initialized and boxes are open
      await LocalStorageService.init();

      final prefs = await SharedPreferences.getInstance();
      final isEnabled = prefs.getBool('autoChangeEnabled') ?? false;

      debugPrint('Auto-change status: $isEnabled');

      if (!isEnabled) {
        debugPrint('Auto-change is disabled in settings. Skipping.');
        return true;
      }

      final favorites = LocalStorageService.getFavorites()
          .where((w) => w.type != 'animated')
          .toList();
      debugPrint('Favorites count: ${favorites.length}');

      if (favorites.isEmpty) {
        debugPrint('No favorites found. Turning OFF auto-change.');
        await prefs.setBool('autoChangeEnabled', false);
        await Workmanager().cancelByTag(autoChangeTask);
        return true;
      }

      // Implement Looping logic
      int lastIndex = prefs.getInt('lastAutoChangeIndex') ?? -1;
      int nextIndex = lastIndex + 1;

      if (nextIndex >= favorites.length || nextIndex < 0) {
        nextIndex = 0;
      }

      final wallpaper = favorites[nextIndex];
      debugPrint('Selected wallpaper index: $nextIndex (ID: ${wallpaper.id})');

      String downloadUrl = wallpaper.url;
      // High-res logic for Unsplash
      if (downloadUrl.contains('unsplash.com')) {
        downloadUrl = downloadUrl.replaceAllMapped(
          RegExp(r'([?&])w=\d+'),
          (m) => '${m[1]}w=5000',
        );
        downloadUrl = downloadUrl.replaceAllMapped(
          RegExp(r'([?&])q=\d+'),
          (m) => '${m[1]}q=100',
        );
        if (!downloadUrl.contains('w=5000')) {
          downloadUrl =
              '$downloadUrl${downloadUrl.contains('?') ? '&' : '?'}w=5000';
        }
      }

      const String extension = 'png';

      String? finalPath;

      if (downloadUrl.startsWith('http')) {
        debugPrint('Downloading image from URL: $downloadUrl');
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
          return false;
        }
      } else {
        finalPath = downloadUrl;
        debugPrint('Using local file path: $finalPath');
      }

      if (await File(finalPath).exists()) {
        try {
          debugPrint(
            'Setting static wallpaper via Native Platform Channel (Background)...',
          );
          const platform = MethodChannel('com.amozea.wallpapers/wallpaper');
          final result = await platform.invokeMethod('setWallpaper', {
            'path': finalPath,
            'location': 3, // BOTH_SCREENS
          });

          final success = result == "Success";

          if (success) {
            final now = DateTime.now().millisecondsSinceEpoch;
            await prefs.setInt('lastAutoChange', now);
            await prefs.setInt('lastAutoChangeIndex', nextIndex);
            debugPrint('--- WALLPAPER CHANGED SUCCESSFULLY ---');

            // Show Notification ONLY on SUCCESS
            const AndroidNotificationDetails
            androidPlatformChannelSpecifics = AndroidNotificationDetails(
              'wallpaper_channel',
              'Wallpaper Updates',
              channelDescription:
                  'Notifications when the wallpaper is automatically changed',
              importance: Importance.defaultImportance,
              priority: Priority.defaultPriority,
              showWhen: true,
            );
            const NotificationDetails platformChannelSpecifics =
                NotificationDetails(android: androidPlatformChannelSpecifics);
            await flutterLocalNotificationsPlugin.show(
              id: 0,
              title: 'Wallpaper Updated',
              body:
                  'Your wallpaper has been automatically updated with a new favorite.',
              notificationDetails: platformChannelSpecifics,
            );
          }

          // If frequency is 60s (Test mode), schedule the next one-off task
          final freq = prefs.getInt('autoChangeFrequency') ?? 86400;
          if (freq == 60) {
            final now = DateTime.now().millisecondsSinceEpoch;
            debugPrint('Test mode: Scheduling next change in 60s...');
            Workmanager().registerOneOffTask(
              "oneOffAutoChange_${now + 60000}",
              autoChangeTask,
              initialDelay: const Duration(seconds: 60),
              tag: autoChangeTask,
              constraints: Constraints(networkType: NetworkType.connected),
            );
          }
        } catch (e) {
          debugPrint('Error setting wallpaper in background: $e');
          return true;
        }
      }

      return true;
    } catch (e) {
      debugPrint('CRITICAL TASK ERROR: $e');
      return false;
    }
  });
}

void main() async {
  debugPrint('--- APP STARTING ---');
  WidgetsFlutterBinding.ensureInitialized();

  // Only await essential local storage
  await LocalStorageService.init();

  // Initialize these in background without awaiting to speed up cold start
  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  MobileAds.instance.initialize();

  // Enable Edge-to-Edge for Android 15+ compatibility
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Revalidate live wallpaper state when coming back from wallpaper picker
      ref.read(liveWallpaperProvider.notifier).revalidateState();
    }
  }

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
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final language = ref.watch(settingsProvider.select((s) => s.language));

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
      locale: _getLocale(language),
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

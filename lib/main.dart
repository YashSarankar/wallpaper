import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'data/services/local_storage_service.dart';
import 'data/models/wallpaper_model.dart';
import 'presentation/providers/wallpaper_provider.dart';
import 'presentation/screens/splash_screen.dart';

const String autoChangeTask = "com.amozea.wallpapers.autoChange";
const platform = MethodChannel('com.amozea.wallpapers/wallpaper');

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // 1. Initialize services (Hive needs path_provider)
      WidgetsFlutterBinding.ensureInitialized();
      final dir = await getApplicationDocumentsDirectory();
      await LocalStorageService.init(); // Assuming it handles Hive.init(dir.path)

      final prefs = await SharedPreferences.getInstance();
      final isEnabled = prefs.getBool('autoChangeEnabled') ?? false;
      if (!isEnabled) return true;

      // 2. Load Favorites
      final favorites = LocalStorageService.getFavorites();
      if (favorites.isEmpty) return true;

      // 3. Pick Random
      final random = Random();
      final wallpaper = favorites[random.nextInt(favorites.length)];

      String? finalPath;

      if (wallpaper.url.startsWith('http')) {
        // 4. Download with Retry & User-Agent
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
            debugPrint('Background Download Attempt $retries failed: $e');
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
        // 5. Set Wallpaper (Location 3 = Both)
        await platform.invokeMethod('setWallpaper', {
          'path': finalPath,
          'location': 3,
        });

        // 6. Update timestamp
        await prefs.setInt(
          'lastAutoChange',
          DateTime.now().millisecondsSinceEpoch,
        );
      }

      return true;
    } catch (e) {
      debugPrint('Background Task Error: $e');
      return false;
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.init();

  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Amozea – AMOLED Wallpapers',
      debugShowCheckedModeBanner: false,
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

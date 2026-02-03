import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../models/wallpaper_model.dart';

class LocalStorageService {
  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(WallpaperModelAdapter());
    }
    await Hive.openBox(AppConstants.themeBox);
    await Hive.openBox<WallpaperModel>(AppConstants.favoritesBox);
  }

  // Theme
  static bool get isDarkMode {
    final box = Hive.box(AppConstants.themeBox);
    return box.get(AppConstants.themeKey, defaultValue: false);
  }

  static Future<void> setDarkMode(bool isDark) async {
    final box = Hive.box(AppConstants.themeBox);
    await box.put(AppConstants.themeKey, isDark);
  }

  // Favorites
  static List<WallpaperModel> getFavorites() {
    final box = Hive.box<WallpaperModel>(AppConstants.favoritesBox);
    return box.values.toList();
  }

  static Future<void> addToFavorites(WallpaperModel wallpaper) async {
    final box = Hive.box<WallpaperModel>(AppConstants.favoritesBox);
    await box.put(wallpaper.id, wallpaper);
  }

  static Future<void> removeFromFavorites(String id) async {
    final box = Hive.box<WallpaperModel>(AppConstants.favoritesBox);
    await box.delete(id);
  }

  static bool isFavorite(String id) {
    final box = Hive.box<WallpaperModel>(AppConstants.favoritesBox);
    return box.containsKey(id);
  }
}

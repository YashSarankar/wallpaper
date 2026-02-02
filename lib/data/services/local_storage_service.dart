import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../models/wallpaper_model.dart';

class LocalStorageService {
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(WallpaperModelAdapter());
    await Hive.openBox(AppConstants.themeBox);
    await Hive.openBox<WallpaperModel>(AppConstants.favoritesBox);
  }

  // Theme
  Box get _themeBox => Hive.box(AppConstants.themeBox);

  bool get isDarkMode =>
      _themeBox.get(AppConstants.themeKey, defaultValue: false);

  Future<void> setDarkMode(bool isDark) async {
    await _themeBox.put(AppConstants.themeKey, isDark);
  }

  // Favorites
  Box<WallpaperModel> get _favoritesBox =>
      Hive.box<WallpaperModel>(AppConstants.favoritesBox);

  List<WallpaperModel> getFavorites() {
    return _favoritesBox.values.toList();
  }

  Future<void> addToFavorites(WallpaperModel wallpaper) async {
    await _favoritesBox.put(wallpaper.id, wallpaper);
  }

  Future<void> removeFromFavorites(String id) async {
    await _favoritesBox.delete(id);
  }

  bool isFavorite(String id) {
    return _favoritesBox.containsKey(id);
  }
}

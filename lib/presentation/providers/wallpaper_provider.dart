import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/api_service.dart';
import '../../data/services/local_storage_service.dart';
import '../../data/repositories/wallpaper_repository_impl.dart';
import '../../domain/repositories/wallpaper_repository.dart';
import '../../data/models/wallpaper_model.dart';

// Services
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
final localStorageServiceProvider = Provider<LocalStorageService>(
  (ref) => LocalStorageService(),
);

// Repository
final wallpaperRepositoryProvider = Provider<WallpaperRepository>((ref) {
  return WallpaperRepositoryImpl(ref.watch(apiServiceProvider));
});

// Logic
final wallpapersProvider = FutureProvider<List<CategoryModel>>((ref) async {
  return ref.watch(wallpaperRepositoryProvider).getWallpapers();
});

class ThemeNotifier extends StateNotifier<bool> {
  final LocalStorageService _storage;

  ThemeNotifier(this._storage) : super(_storage.isDarkMode);

  Future<void> toggleTheme() async {
    final newMode = !state;
    await _storage.setDarkMode(newMode);
    state = newMode;
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  return ThemeNotifier(ref.watch(localStorageServiceProvider));
});

// Favorites Logic
class FavoritesNotifier extends StateNotifier<List<WallpaperModel>> {
  final LocalStorageService _storage;

  FavoritesNotifier(this._storage) : super(_storage.getFavorites());

  Future<void> toggleFavorite(WallpaperModel wallpaper) async {
    if (_storage.isFavorite(wallpaper.id)) {
      await _storage.removeFromFavorites(wallpaper.id);
    } else {
      await _storage.addToFavorites(wallpaper);
    }
    state = _storage.getFavorites();
  }

  bool isFavorite(String id) {
    return _storage.isFavorite(id);
  }
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, List<WallpaperModel>>((ref) {
      return FavoritesNotifier(ref.watch(localStorageServiceProvider));
    });

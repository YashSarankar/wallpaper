import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
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

// Derived Providers
final allWallpapersProvider = Provider<List<WallpaperModel>>((ref) {
  final wallpapersAsync = ref.watch(wallpapersProvider);
  return wallpapersAsync.maybeWhen(
    data: (categories) => categories.expand((c) => c.wallpapers).toList(),
    orElse: () => [],
  );
});

final randomWallpapersProvider = Provider<List<WallpaperModel>>((ref) {
  final all = [...ref.watch(allWallpapersProvider)];
  all.shuffle();
  return all;
});

final latestWallpapersProvider = Provider<List<WallpaperModel>>((ref) {
  // Assuming the order delivered by API is already sorted by newest
  return ref.watch(allWallpapersProvider);
});

final trendingWallpapersProvider = Provider<List<WallpaperModel>>((ref) {
  final all = ref.watch(allWallpapersProvider);
  return all.where((w) => w.category.toLowerCase() == 'trending').toList();
});

class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(LocalStorageService.isDarkMode);

  Future<void> toggleTheme() async {
    final newMode = !state;
    await LocalStorageService.setDarkMode(newMode);
    state = newMode;
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  return ThemeNotifier();
});

// Favorites Logic
class FavoritesNotifier extends StateNotifier<List<WallpaperModel>> {
  FavoritesNotifier() : super(LocalStorageService.getFavorites());

  Future<void> toggleFavorite(WallpaperModel wallpaper) async {
    if (LocalStorageService.isFavorite(wallpaper.id)) {
      await LocalStorageService.removeFromFavorites(wallpaper.id);
    } else {
      await LocalStorageService.addToFavorites(wallpaper);
    }
    state = LocalStorageService.getFavorites();
  }

  Future<void> toggleLocalFavorite(File file) async {
    final id = 'local_${file.path.hashCode}';
    if (LocalStorageService.isFavorite(id)) {
      final existing = state.firstWhere((w) => w.id == id);
      if (existing.url.contains('custom_wallpapers')) {
        try {
          final f = File(existing.url);
          if (await f.exists()) await f.delete();
        } catch (_) {}
      }
      await LocalStorageService.removeFromFavorites(id);
    } else {
      // Copy to internal storage
      final appDir = await getApplicationDocumentsDirectory();
      final customDir = Directory('${appDir.path}/custom_wallpapers');
      if (!await customDir.exists()) await customDir.create();

      final fileName =
          'custom_${DateTime.now().millisecondsSinceEpoch}.${file.path.split('.').last}';
      final newFile = await file.copy('${customDir.path}/$fileName');

      final localWallpaper = WallpaperModel(
        id: id,
        type: 'static',
        url: newFile.path,
        category: 'Custom',
      );
      await LocalStorageService.addToFavorites(localWallpaper);
    }
    state = LocalStorageService.getFavorites();
  }

  bool isFavorite(String id) {
    return LocalStorageService.isFavorite(id);
  }
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, List<WallpaperModel>>((ref) {
      return FavoritesNotifier();
    });

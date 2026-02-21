import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/api_service.dart';
import '../../data/services/local_storage_service.dart';
import '../../data/repositories/wallpaper_repository_impl.dart';
import '../../domain/repositories/wallpaper_repository.dart';
import '../../data/models/wallpaper_model.dart';

import 'settings_provider.dart';

// Services
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
final localStorageServiceProvider = Provider<LocalStorageService>(
  (ref) => LocalStorageService(),
);

// Repository
final wallpaperRepositoryProvider = Provider<WallpaperRepository>((ref) {
  return WallpaperRepositoryImpl(ref.watch(apiServiceProvider));
});

String _getLangCode(String language) {
  switch (language) {
    case 'Spanish':
      return 'es';
    case 'French':
      return 'fr';
    case 'Hindi':
      return 'hi';
    case 'Japanese':
      return 'ja';
    default:
      return 'en';
  }
}

// Logic
final wallpapersProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final language = ref.watch(settingsProvider.select((s) => s.language));
  final langCode = _getLangCode(language);
  final categories = await ref
      .watch(wallpaperRepositoryProvider)
      .getWallpapers(langCode);

  return categories;
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
  final all = [
    ...ref.watch(allWallpapersProvider),
  ].where((w) => w.type != 'animated').toList();
  all.shuffle();
  return all;
});

final latestWallpapersProvider = Provider<List<WallpaperModel>>((ref) {
  // Assuming the order delivered by API is already sorted by newest
  return ref
      .watch(allWallpapersProvider)
      .where((w) => w.type != 'animated')
      .toList();
});

final liveWallpapersProvider = Provider<List<WallpaperModel>>((ref) {
  return ref
      .watch(allWallpapersProvider)
      .where((w) => w.type == 'animated')
      .toList();
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

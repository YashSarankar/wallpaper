import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/models/wallpaper_model.dart';
import '../../data/services/local_storage_service.dart';

class FavoritesNotifier extends StateNotifier<List<WallpaperModel>> {
  FavoritesNotifier()
    : super(
        LocalStorageService.getFavorites()
            .where((w) => w.type != 'animated')
            .toList(),
      );

  Future<void> toggleFavorite(WallpaperModel wallpaper) async {
    if (LocalStorageService.isFavorite(wallpaper.id)) {
      await LocalStorageService.removeFromFavorites(wallpaper.id);
    } else {
      if (wallpaper.type == 'animated')
        return; // Cannot favorite live wallpapers
      await LocalStorageService.addToFavorites(wallpaper);
    }
    state = LocalStorageService.getFavorites()
        .where((w) => w.type != 'animated')
        .toList();
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

import '../../data/models/wallpaper_model.dart';

abstract class WallpaperRepository {
  Future<List<CategoryModel>> getWallpapers(String languageCode);
}

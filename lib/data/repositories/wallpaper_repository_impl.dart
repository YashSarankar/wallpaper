import '../../domain/repositories/wallpaper_repository.dart';
import '../../data/models/wallpaper_model.dart';
import '../services/api_service.dart';

class WallpaperRepositoryImpl implements WallpaperRepository {
  final ApiService _apiService;
  WallpaperRepositoryImpl(this._apiService);

  @override
  Future<List<CategoryModel>> getWallpapers() async {
    // We now fetch exclusively from the backend
    return await _apiService.fetchWallpapers();
  }
}

import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../models/wallpaper_model.dart';

class ApiService {
  final Dio _dio = Dio();

  Future<List<CategoryModel>> fetchWallpapers() async {
    try {
      final response = await _dio.get(AppConstants.remoteWallpaperJsonUrl);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['categories'] != null) {
          final List categories = data['categories'];
          return categories.map((e) => CategoryModel.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      // Allow fallback to local if remote fails
      throw Exception('Failed to load wallpapers: $e');
    }
  }
}

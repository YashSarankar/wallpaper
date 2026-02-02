import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../models/wallpaper_model.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  Future<List<CategoryModel>> fetchWallpapers() async {
    try {
      final response = await _dio.get(AppConstants.remoteWallpaperJsonUrl);

      if (response.statusCode == 200) {
        final List data = response.data;

        // Group by category to match app structure
        final Map<String, List<dynamic>> groupedMap = {};

        for (var item in data) {
          final category = item['category'] ?? 'Uncategorized';
          if (!groupedMap.containsKey(category)) {
            groupedMap[category] = [];
          }
          groupedMap[category]!.add(item);
        }

        final List<CategoryModel> categories = [];
        groupedMap.forEach((key, value) {
          // Construct CategoryModel manually since structure changed
          final wallpapers = value
              .map((e) => WallpaperModel.fromJson(e, key))
              .toList();
          categories.add(CategoryModel(name: key, wallpapers: wallpapers));
        });

        if (categories.isEmpty) {
          throw Exception('No wallpapers found on server');
        }

        return categories;
      }
      throw Exception(
        'Failed to load wallpapers status: ${response.statusCode}',
      );
    } catch (e) {
      // Allow fallback to local if remote fails
      throw Exception('Failed to load wallpapers: $e');
    }
  }
}

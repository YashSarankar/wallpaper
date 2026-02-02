import '../../domain/repositories/wallpaper_repository.dart';
import '../../data/models/wallpaper_model.dart';
import '../services/api_service.dart';

import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../../core/constants/app_constants.dart';

class WallpaperRepositoryImpl implements WallpaperRepository {
  final ApiService _apiService;
  WallpaperRepositoryImpl(this._apiService);

  @override
  Future<List<CategoryModel>> getWallpapers() async {
    try {
      // Try fetching from API
      return await _apiService.fetchWallpapers();
    } catch (e) {
      // Fallback to local asset
      try {
        final jsonString = await rootBundle.loadString(
          AppConstants.localWallpaperJson,
        );
        final data = json.decode(jsonString);
        if (data['categories'] != null) {
          final List categories = data['categories'];
          return categories.map((e) => CategoryModel.fromJson(e)).toList();
        }
      } catch (_) {
        return [];
      }
      return [];
    }
  }
}

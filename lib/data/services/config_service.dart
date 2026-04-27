import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';

class RemoteConfig {
  final String minVersion;
  final String updateUrl;
  final String updateMessage;
  final bool forceUpdate;

  RemoteConfig({
    required this.minVersion,
    required this.updateUrl,
    required this.updateMessage,
    required this.forceUpdate,
  });

  factory RemoteConfig.fromJson(Map<String, dynamic> json) {
    return RemoteConfig(
      minVersion: json['min_version'] ?? '1.0.0',
      updateUrl: json['update_url'] ?? 'https://play.google.com/store/apps/details?id=com.amozea.wallpapers',
      updateMessage: json['update_message'] ?? 'A new version of Amozea is available. Please update to continue.',
      forceUpdate: json['force_update'] ?? false,
    );
  }
}

class ConfigService {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      validateStatus: (status) => status! < 500, // Don't throw for 404
    ),
  );

  Future<RemoteConfig?> fetchRemoteConfig() async {
    try {
      final response = await _dio.get(AppConstants.remoteConfigUrl);

      if (response.statusCode == 200) {
        return RemoteConfig.fromJson(response.data);
      }
    } catch (e) {
      // If endpoint doesn't exist yet, return null or a safe default
    }
    return null;
  }

  bool shouldUpdate(String currentVersion, String minVersion) {
    try {
      final current = currentVersion.split('.').map(int.parse).toList();
      final required = minVersion.split('.').map(int.parse).toList();

      for (var i = 0; i < required.length; i++) {
        if (i >= current.length) return true;
        if (current[i] < required[i]) return true;
        if (current[i] > required[i]) return false;
      }
    } catch (e) {
      // Error
    }
    return false;
  }
}

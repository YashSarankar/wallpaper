import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class LiveWallpaperState {
  final String? pendingWallpaperId;
  final String? lastAppliedWallpaperId;
  final bool isDownloading;
  final bool isPreviewing;
  final double downloadProgress;

  LiveWallpaperState({
    this.pendingWallpaperId,
    this.lastAppliedWallpaperId,
    this.isDownloading = false,
    this.isPreviewing = false,
    this.downloadProgress = 0,
  });

  LiveWallpaperState copyWith({
    String? pendingWallpaperId,
    String? lastAppliedWallpaperId,
    bool? isDownloading,
    bool? isPreviewing,
    double? downloadProgress,
  }) {
    return LiveWallpaperState(
      pendingWallpaperId: pendingWallpaperId ?? this.pendingWallpaperId,
      lastAppliedWallpaperId:
          lastAppliedWallpaperId ?? this.lastAppliedWallpaperId,
      isDownloading: isDownloading ?? this.isDownloading,
      isPreviewing: isPreviewing ?? this.isPreviewing,
      downloadProgress: downloadProgress ?? this.downloadProgress,
    );
  }
}

class LiveWallpaperNotifier extends StateNotifier<LiveWallpaperState> {
  static const String _prefLastApplied = 'last_applied_live_wp';
  static const String _prefPending = 'pending_live_wp';

  LiveWallpaperNotifier() : super(LiveWallpaperState()) {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    state = state.copyWith(
      lastAppliedWallpaperId: prefs.getString(_prefLastApplied),
      pendingWallpaperId: prefs.getString(_prefPending),
    );
  }

  void setDownloading(bool downloading, {double progress = 0}) {
    state = state.copyWith(
      isDownloading: downloading,
      downloadProgress: progress,
    );
  }

  Future<void> setPending(String? id) async {
    final prefs = await SharedPreferences.getInstance();
    if (id == null) {
      await prefs.remove(_prefPending);
    } else {
      await prefs.setString(_prefPending, id);
    }
    state = state.copyWith(pendingWallpaperId: id, isPreviewing: id != null);
  }

  Future<void> confirmApplied() async {
    final prefs = await SharedPreferences.getInstance();
    final id = state.pendingWallpaperId;
    if (id != null) {
      await prefs.setString(_prefLastApplied, id);
      await prefs.remove(_prefPending);
      state = state.copyWith(
        lastAppliedWallpaperId: id,
        pendingWallpaperId: null,
        isPreviewing: false,
      );
      await cleanupOldWallpapers(id);
    }
  }

  Future<void> cancelPreview() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefPending);
    state = state.copyWith(pendingWallpaperId: null, isPreviewing: false);
  }

  Future<void> cleanupOldWallpapers(String currentId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final wpDir = Directory('${directory.path}/live_wallpapers');
      if (await wpDir.exists()) {
        final files = wpDir.listSync();
        for (var file in files) {
          if (file is File && file.path.contains('LiveWallpaper_')) {
            // Only delete if it's not the current one
            if (!file.path.contains(currentId)) {
              await file.delete();
            }
          }
        }
      }
    } catch (_) {}
  }

  Future<void> revalidateState() async {
    const platform = MethodChannel('com.amozea.wallpapers/wallpaper');
    final bool isActive = await platform.invokeMethod('isLiveWallpaperActive');

    if (isActive && state.pendingWallpaperId != null) {
      // It was applied while app was in background
      await confirmApplied();
    } else if (!isActive && state.pendingWallpaperId != null) {
      // High-level check: if it's not active but we have a pending ID,
      // user might have backed out. We don't clear pending yet to allow retry,
      // but we reset isPreviewing.
      state = state.copyWith(isPreviewing: false);
    }
  }
}

final liveWallpaperProvider =
    StateNotifierProvider<LiveWallpaperNotifier, LiveWallpaperState>((ref) {
      return LiveWallpaperNotifier();
    });

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';
import 'favorites_provider.dart';
import '../../data/models/wallpaper_model.dart';

const String autoChangeTask = "com.amozea.wallpapers.autoChange";

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) {
    final notifier = SettingsNotifier(ref);
    // Watch favorites and disable auto-change if empty
    ref.listen<List<WallpaperModel>>(favoritesProvider, (previous, next) {
      if (next.isEmpty) {
        notifier.setAutoChangeEnabled(false);
      }
    });
    return notifier;
  },
);

class SettingsState {
  final int gridColumns;
  final bool dataSaver;
  final String downloadQuality;
  final bool autoChangeEnabled;
  final int autoChangeFrequency; // Seconds
  final int lastAutoChange; // Timestamp
  final String language;
  final bool isInitialized;

  SettingsState({
    required this.gridColumns,
    required this.dataSaver,
    required this.downloadQuality,
    required this.autoChangeEnabled,
    required this.autoChangeFrequency,
    required this.lastAutoChange,
    required this.language,
    this.isInitialized = false,
  });

  SettingsState copyWith({
    int? gridColumns,
    bool? dataSaver,
    String? downloadQuality,
    bool? autoChangeEnabled,
    int? autoChangeFrequency,
    int? lastAutoChange,
    String? language,
    bool? isInitialized,
  }) {
    return SettingsState(
      gridColumns: gridColumns ?? this.gridColumns,
      dataSaver: dataSaver ?? this.dataSaver,
      downloadQuality: downloadQuality ?? this.downloadQuality,
      autoChangeEnabled: autoChangeEnabled ?? this.autoChangeEnabled,
      autoChangeFrequency: autoChangeFrequency ?? this.autoChangeFrequency,
      lastAutoChange: lastAutoChange ?? this.lastAutoChange,
      language: language ?? this.language,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final Ref ref;

  SettingsNotifier(this.ref)
    : super(
        SettingsState(
          gridColumns: 2,
          dataSaver: false,
          downloadQuality: 'Original',
          autoChangeEnabled: false,
          autoChangeFrequency: 86400, // Default 24h in seconds
          lastAutoChange: 0,
          language: 'English',
        ),
      ) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    int freq = prefs.getInt('autoChangeFrequency') ?? 86400;

    if (freq > 0 && freq <= 168 && freq != 10) {
      freq = freq * 3600;
      await prefs.setInt('autoChangeFrequency', freq);
    }

    const allowed = [60, 1200, 21600, 43200, 86400, 172800, 604800];
    if (!allowed.contains(freq)) {
      freq = 86400;
      await prefs.setInt('autoChangeFrequency', freq);
    }

    state = state.copyWith(
      gridColumns: prefs.getInt('gridColumns') ?? 2,
      dataSaver: prefs.getBool('dataSaver') ?? false,
      downloadQuality: prefs.getString('downloadQuality') ?? 'Original',
      autoChangeEnabled: prefs.getBool('autoChangeEnabled') ?? false,
      autoChangeFrequency: freq,
      lastAutoChange: prefs.getInt('lastAutoChange') ?? 0,
      language: prefs.getString('language') ?? 'English',
      isInitialized: true,
    );

    // Final sanity check: if enabled but no favorites, turn off
    if (state.autoChangeEnabled) {
      final favorites = ref.read(favoritesProvider);
      if (favorites.isEmpty) {
        await setAutoChangeEnabled(false);
      } else {
        _scheduleTask(ExistingPeriodicWorkPolicy.keep);
      }
    }
  }

  Future<void> setAutoChangeEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoChangeEnabled', enabled);
    state = state.copyWith(autoChangeEnabled: enabled);

    if (enabled) {
      if (Platform.isAndroid) {
        final flutterLocalNotificationsPlugin =
            FlutterLocalNotificationsPlugin();
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission();
      }
      _scheduleTask(ExistingPeriodicWorkPolicy.replace);

      // Trigger immediate change when enabled
      Workmanager().registerOneOffTask(
        "oneOffAutoChange_${DateTime.now().millisecondsSinceEpoch}",
        autoChangeTask,
        tag: autoChangeTask,
        constraints: Constraints(networkType: NetworkType.connected),
      );
    } else {
      await Workmanager().cancelByTag(autoChangeTask);
    }
  }

  Future<void> setAutoChangeFrequency(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('autoChangeFrequency', seconds);
    state = state.copyWith(autoChangeFrequency: seconds);

    if (state.autoChangeEnabled) {
      _scheduleTask(ExistingPeriodicWorkPolicy.replace);
    }
  }

  void _scheduleTask(ExistingPeriodicWorkPolicy policy) {
    Workmanager().registerPeriodicTask(
      "1",
      autoChangeTask,
      frequency: Duration(seconds: state.autoChangeFrequency),
      tag: autoChangeTask,
      existingWorkPolicy: policy,
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  Future<void> setGridColumns(int columns) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('gridColumns', columns);
    state = state.copyWith(gridColumns: columns);
  }

  Future<void> setDataSaver(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dataSaver', enabled);
    state = state.copyWith(dataSaver: enabled);
  }

  Future<void> setDownloadQuality(String quality) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('downloadQuality', quality);
    state = state.copyWith(downloadQuality: quality);
  }

  Future<void> setLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
    state = state.copyWith(language: language);
  }
}

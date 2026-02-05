import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

const String autoChangeTask = "com.amozea.wallpapers.autoChange";

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) {
    return SettingsNotifier();
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

  SettingsState({
    required this.gridColumns,
    required this.dataSaver,
    required this.downloadQuality,
    required this.autoChangeEnabled,
    required this.autoChangeFrequency,
    required this.lastAutoChange,
    required this.language,
  });

  SettingsState copyWith({
    int? gridColumns,
    bool? dataSaver,
    String? downloadQuality,
    bool? autoChangeEnabled,
    int? autoChangeFrequency,
    int? lastAutoChange,
    String? language,
  }) {
    return SettingsState(
      gridColumns: gridColumns ?? this.gridColumns,
      dataSaver: dataSaver ?? this.dataSaver,
      downloadQuality: downloadQuality ?? this.downloadQuality,
      autoChangeEnabled: autoChangeEnabled ?? this.autoChangeEnabled,
      autoChangeFrequency: autoChangeFrequency ?? this.autoChangeFrequency,
      lastAutoChange: lastAutoChange ?? this.lastAutoChange,
      language: language ?? this.language,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier()
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

    const allowed = [3600, 21600, 43200, 86400, 172800, 604800];
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
    );

    if (state.autoChangeEnabled) {
      _scheduleTask(ExistingPeriodicWorkPolicy.keep);
    }
  }

  Future<void> setAutoChangeEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoChangeEnabled', enabled);
    state = state.copyWith(autoChangeEnabled: enabled);

    if (enabled) {
      _scheduleTask(ExistingPeriodicWorkPolicy.replace);
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

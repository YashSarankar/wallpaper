import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wallpaper/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/ad_helper.dart';
import '../providers/wallpaper_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/favorites_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _pickAndAddPhotos(BuildContext context, WidgetRef ref) async {
    final adHelper = AdHelper();

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Center(child: CircularProgressIndicator()),
    );

    // Define the reward action to avoid code duplication
    void handleReward() async {
      final picker = ImagePicker();
      try {
        final List<XFile> images = await picker.pickMultiImage();
        if (images.isNotEmpty) {
          int count = 0;
          for (final image in images) {
            await ref
                .read(favoritesProvider.notifier)
                .toggleLocalFavorite(File(image.path));
            count++;
          }

          if (context.mounted) {
            final l10n = AppLocalizations.of(context)!;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.addedPhotos(count)),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } catch (e) {
        debugPrint('Error picking images: $e');
      }
    }

    // Load and show ad with callbacks
    adHelper.loadRewardedAd(
      onLoaded: () {
        if (context.mounted) {
          Navigator.pop(context); // Dismiss loading dialog
          adHelper.showRewardedAd(
            onRewardEarned: handleReward,
            onDismissed: () {
              // Optional: handle dismissal
            },
          );
        }
      },
      onFailed: () {
        if (context.mounted) {
          Navigator.pop(context); // Dismiss loading dialog
          // If ad fails to load, we can choose to let the user proceed anyway
          // relying on the fallback in showRewardedAd which calls onRewardEarned
          adHelper.showRewardedAd(
            onRewardEarned: handleReward,
            onDismissed: null,
          );
        }
      },
    );
  }

  Future<void> _clearCache(BuildContext context) async {
    try {
      final cacheDir = await getTemporaryDirectory();
      if (cacheDir.existsSync()) {
        cacheDir.deleteSync(recursive: true);
      }
      if (context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.cacheCleared)));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to clear cache')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.back,
            color: isDarkMode ? Colors.white : Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.settings,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 20),

          // Appearance Section
          _buildSectionHeader(context, l10n.appearance, isDarkMode),
          const SizedBox(height: 10),
          _buildSettingsTile(
            context,
            icon: isDarkMode
                ? CupertinoIcons.moon_fill
                : CupertinoIcons.sun_max_fill,
            title: l10n.darkMode,
            trailing: Switch.adaptive(
              value: isDarkMode,
              activeColor: Colors.blueAccent,
              onChanged: (value) =>
                  ref.read(themeProvider.notifier).toggleTheme(),
            ),
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 8),
          _buildSettingsTile(
            context,
            icon: CupertinoIcons.square_grid_2x2,
            title: l10n.gridLayout,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildChoiceChip(
                  label: '2',
                  isSelected: settings.gridColumns == 2,
                  onSelect: () => settingsNotifier.setGridColumns(2),
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(width: 8),
                _buildChoiceChip(
                  label: '3',
                  isSelected: settings.gridColumns == 3,
                  onSelect: () => settingsNotifier.setGridColumns(3),
                  isDarkMode: isDarkMode,
                ),
              ],
            ),
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 8),
          _buildSettingsTile(
            context,
            icon: CupertinoIcons.globe,
            title: l10n.language,
            trailing: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: settings.language,
                dropdownColor: isDarkMode ? Colors.grey[900] : Colors.white,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 13,
                ),
                items:
                    {
                      'English': 'English',
                      'Spanish': 'Español',
                      'French': 'Français',
                      'Hindi': 'हिन्दी',
                      'Japanese': '日本語',
                    }.entries.map((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    settingsNotifier.setLanguage(value);
                  }
                },
              ),
            ),
            isDarkMode: isDarkMode,
          ),

          const SizedBox(height: 30),

          // Automation Section
          _buildSectionHeader(context, l10n.automation, isDarkMode),
          const SizedBox(height: 10),
          _buildSettingsTile(
            context,
            icon: CupertinoIcons.refresh_thick,
            title: l10n.autoChangeWallpaper,
            subtitle: l10n.cyclesFavorites,
            trailing: Switch.adaptive(
              value: settings.autoChangeEnabled,
              activeColor: Colors.purpleAccent,
              onChanged: (value) {
                if (value && ref.read(favoritesProvider).isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.addFavoritesFirst),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  return;
                }
                settingsNotifier.setAutoChangeEnabled(value);
              },
            ),
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 8),
          _buildSettingsTile(
            context,
            icon: CupertinoIcons.add_circled,
            title: l10n.addYourPhotos,
            subtitle: l10n.addPhotosRotation,
            trailing: const Icon(
              CupertinoIcons.chevron_right,
              size: 16,
              color: Colors.grey,
            ),
            onTap: () => _pickAndAddPhotos(context, ref),
            isDarkMode: isDarkMode,
          ),
          if (settings.autoChangeEnabled) ...[
            if (settings.lastAutoChange > 0) ...[
              const SizedBox(height: 8),
              _buildSettingsTile(
                context,
                icon: CupertinoIcons.time,
                title: 'Last Auto Change',
                trailing: Text(
                  TimeOfDay.fromDateTime(
                    DateTime.fromMillisecondsSinceEpoch(
                      settings.lastAutoChange,
                    ),
                  ).format(context),
                  style: TextStyle(
                    color: isDarkMode ? Colors.white38 : Colors.black38,
                    fontSize: 13,
                  ),
                ),
                isDarkMode: isDarkMode,
              ),
            ],
            const SizedBox(height: 8),

            _buildSettingsTile(
              context,
              icon: CupertinoIcons.clock,
              title: l10n.changeEvery,
              trailing: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value:
                      [
                        60,
                        1200,
                        21600,
                        43200,
                        86400,
                        172800,
                        604800,
                      ].contains(settings.autoChangeFrequency)
                      ? settings.autoChangeFrequency
                      : 86400,
                  dropdownColor: isDarkMode ? Colors.grey[900] : Colors.white,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 13,
                  ),
                  items: [60, 1200, 21600, 43200, 86400, 172800, 604800].map((
                    int value,
                  ) {
                    String label;
                    if (value == 60) {
                      label = '1 Minute (Test)';
                    } else if (value == 1200) {
                      label = '20 Minutes';
                    } else if (value == 21600) {
                      label = '6 Hours';
                    } else if (value == 43200) {
                      label = '12 Hours';
                    } else if (value == 86400) {
                      label = 'Daily';
                    } else if (value < 604800) {
                      label = '${value ~/ 86400} Days';
                    } else {
                      label = '1 Week';
                    }

                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(label),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null)
                      settingsNotifier.setAutoChangeFrequency(value);
                  },
                ),
              ),
              isDarkMode: isDarkMode,
            ),
          ],

          const SizedBox(height: 30),

          // Performance Section
          _buildSectionHeader(context, l10n.performance, isDarkMode),
          const SizedBox(height: 10),
          _buildSettingsTile(
            context,
            icon: CupertinoIcons.gauge,
            title: l10n.dataSaver,
            trailing: Switch.adaptive(
              value: settings.dataSaver,
              activeColor: Colors.greenAccent,
              onChanged: (value) => settingsNotifier.setDataSaver(value),
            ),
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 8),
          _buildSettingsTile(
            context,
            icon: CupertinoIcons.trash,
            title: l10n.clearCache,
            trailing: const Icon(
              CupertinoIcons.chevron_right,
              size: 16,
              color: Colors.grey,
            ),
            isDarkMode: isDarkMode,
            onTap: () => _showClearCacheDialog(context),
          ),

          const SizedBox(height: 30),

          // Legal Section
          _buildSectionHeader(context, l10n.support, isDarkMode),
          const SizedBox(height: 10),
          _buildSettingsTile(
            context,
            icon: CupertinoIcons.shield_lefthalf_fill,
            title:
                'Privacy Policy', // Using literal since l10n might not have it yet
            trailing: const Icon(
              CupertinoIcons.chevron_right,
              size: 16,
              color: Colors.grey,
            ),
            isDarkMode: isDarkMode,
            onTap: () async {
              final Uri url = Uri.parse('https://sarankar.com/privacy');
              if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Could not open Privacy Policy'),
                    ),
                  );
                }
              }
            },
          ),
          const SizedBox(height: 8),
          _buildSettingsTile(
            context,
            icon: CupertinoIcons.heart,
            title: l10n.rateApp,
            trailing: const Icon(
              CupertinoIcons.chevron_right,
              size: 16,
              color: Colors.grey,
            ),
            isDarkMode: isDarkMode,
            onTap: () async {
              final Uri url = Uri.parse(
                'https://play.google.com/store/apps/details?id=com.amozea.wallpapers',
              );
              if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not open Play Store')),
                  );
                }
              }
            },
          ),
          const SizedBox(height: 8),
          _buildSettingsTile(
            context,
            icon: CupertinoIcons.doc_text,
            title: l10n.version,
            trailing: Text(
              '1.5.1',
              style: TextStyle(
                color: isDarkMode ? Colors.white38 : Colors.black38,
                fontSize: 13,
              ),
            ),
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                Text(
                  'Developed by',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white38 : Colors.black38,
                    fontSize: 10,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'SarankarDevelopers',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return CupertinoAlertDialog(
          title: Text(l10n.clearCache),
          content: Text(l10n.clearCacheDesc),
          actions: [
            CupertinoDialogAction(
              child: Text(l10n.cancel),
              onPressed: () => Navigator.pop(context),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.pop(context);
                _clearCache(context);
              },
              child: Text(l10n.clear),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    bool isDarkMode,
  ) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        color: isDarkMode ? Colors.white38 : Colors.black38,
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelect,
    required bool isDarkMode,
  }) {
    return GestureDetector(
      onTap: onSelect,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blueAccent
              : (isDarkMode
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDarkMode ? Colors.white70 : Colors.black54),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required Widget trailing,
    required bool isDarkMode,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDarkMode
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.02),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.03),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isDarkMode
                    ? Colors.white.withOpacity(0.8)
                    : Colors.black.withOpacity(0.6),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDarkMode
                          ? Colors.white.withOpacity(0.9)
                          : Colors.black.withOpacity(0.8),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white38 : Colors.black38,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

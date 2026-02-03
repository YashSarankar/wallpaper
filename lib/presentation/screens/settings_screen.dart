import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/wallpaper_provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _pickAndAddPhotos(BuildContext context, WidgetRef ref) async {
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added $count photos to rotation!'),
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

  Future<void> _clearCache(BuildContext context) async {
    try {
      final cacheDir = await getTemporaryDirectory();
      if (cacheDir.existsSync()) {
        cacheDir.deleteSync(recursive: true);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cache cleared successfully!')),
        );
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
          'Settings',
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
          _buildSectionHeader(context, 'Appearance', isDarkMode),
          const SizedBox(height: 10),
          _buildSettingsTile(
            context,
            icon: isDarkMode
                ? CupertinoIcons.moon_fill
                : CupertinoIcons.sun_max_fill,
            title: 'Dark Mode',
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
            title: 'Grid Layout',
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

          const SizedBox(height: 30),

          // Automation Section
          _buildSectionHeader(context, 'Automation', isDarkMode),
          const SizedBox(height: 10),
          _buildSettingsTile(
            context,
            icon: CupertinoIcons.refresh_thick,
            title: 'Auto Change Wallpaper',
            subtitle: 'Cycles through your Favorites',
            trailing: Switch.adaptive(
              value: settings.autoChangeEnabled,
              activeColor: Colors.purpleAccent,
              onChanged: (value) {
                if (value && ref.read(favoritesProvider).isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please add some wallpapers to Favorites first!',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
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
            title: 'Add Your Photos',
            subtitle: 'Add gallery images to rotation',
            trailing: const Icon(
              CupertinoIcons.chevron_right,
              size: 16,
              color: Colors.grey,
            ),
            onTap: () => _pickAndAddPhotos(context, ref),
            isDarkMode: isDarkMode,
          ),
          if (settings.autoChangeEnabled) ...[
            const SizedBox(height: 8),
            _buildSettingsTile(
              context,
              icon: CupertinoIcons.clock,
              title: 'Change Every',
              trailing: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value:
                      [
                        3600,
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
                  items: [3600, 21600, 43200, 86400, 172800, 604800].map((
                    int value,
                  ) {
                    String label;
                    if (value < 86400) {
                      label = '${value ~/ 3600} Hours';
                    } else if (value < 604800) {
                      label = '${value ~/ 86400} Days';
                    } else {
                      label = '1 Week';
                    }

                    if (value == 86400) label = 'Daily';

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
          _buildSectionHeader(context, 'Performance & Data', isDarkMode),
          const SizedBox(height: 10),
          _buildSettingsTile(
            context,
            icon: CupertinoIcons.gauge,
            title: 'Data Saver',
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
            title: 'Clear Cache',
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
          _buildSectionHeader(context, 'Support & Legal', isDarkMode),
          const SizedBox(height: 10),
          _buildSettingsTile(
            context,
            icon: CupertinoIcons.heart,
            title: 'Rate the App',
            trailing: const Icon(
              CupertinoIcons.chevron_right,
              size: 16,
              color: Colors.grey,
            ),
            isDarkMode: isDarkMode,
            onTap: () {}, // Implement Store link
          ),
          const SizedBox(height: 8),
          _buildSettingsTile(
            context,
            icon: CupertinoIcons.doc_text,
            title: 'Version',
            trailing: Text(
              '1.1.0',
              style: TextStyle(
                color: isDarkMode ? Colors.white38 : Colors.black38,
                fontSize: 13,
              ),
            ),
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'This will free up storage by removing temporary images. Wallpapers will reload on next view.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              _clearCache(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
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

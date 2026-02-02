import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/wallpaper_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
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
          _buildSectionHeader(context, 'Appearance', isDarkMode),
          const SizedBox(height: 10),
          _buildSettingsTile(
            context,
            icon: isDarkMode
                ? Icons.dark_mode_rounded
                : Icons.light_mode_rounded,
            title: 'Dark Mode',
            trailing: Switch.adaptive(
              value: isDarkMode,
              activeColor: Colors.blueAccent,
              onChanged: (value) {
                ref.read(themeProvider.notifier).toggleTheme();
              },
            ),
            isDarkMode: isDarkMode,
          ),
          const Divider(height: 30),
          _buildSectionHeader(context, 'About', isDarkMode),
          const SizedBox(height: 10),
          _buildSettingsTile(
            context,
            icon: Icons.info_outline_rounded,
            title: 'Version',
            trailing: Text(
              '1.0.0',
              style: TextStyle(
                color: isDarkMode ? Colors.white38 : Colors.black38,
              ),
            ),
            isDarkMode: isDarkMode,
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
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget trailing,
    required bool isDarkMode,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDarkMode
                  ? Colors.white70
                  : Colors.black.withOpacity(0.7),
              size: 22,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

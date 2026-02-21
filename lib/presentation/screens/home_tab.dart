import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../providers/wallpaper_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/wallpaper_card.dart';

import 'package:wallpaper/l10n/app_localizations.dart';

final homeSubTabProvider = StateProvider<int>((ref) => 0);

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSubTab = ref.watch(homeSubTabProvider);
    final displayedWallpapers = selectedSubTab == 0
        ? ref.watch(randomWallpapersProvider)
        : selectedSubTab == 1
        ? ref.watch(latestWallpapersProvider)
        : ref.watch(liveWallpapersProvider);
    final isDarkMode = ref.watch(themeProvider);
    final gridColumns = ref.watch(
      settingsProvider.select((s) => s.gridColumns),
    );
    final wallpapersAsync = ref.watch(wallpapersProvider);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // Top Gap for Custom AppBar
        SizedBox(height: MediaQuery.of(context).padding.top + 70),

        // Premium Sub-Tab Selector (Fixed at top)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.white10 : Colors.grey[200],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Stack(
              children: [
                // Sliding Indicator
                AnimatedAlign(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOutCubic,
                  alignment: selectedSubTab == 0
                      ? Alignment.centerLeft
                      : selectedSubTab == 1
                      ? Alignment.center
                      : Alignment.centerRight,
                  child: FractionallySizedBox(
                    widthFactor: 1 / 3,
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.white24 : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          if (!isDarkMode)
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Tab Buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildSubNavItem(ref, l10n.random, 0, isDarkMode),
                    ),
                    Expanded(
                      child: _buildSubNavItem(ref, l10n.latest, 1, isDarkMode),
                    ),
                    Expanded(
                      child: _buildSubNavItem(ref, l10n.live, 2, isDarkMode),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Grid Content
        Expanded(
          child: wallpapersAsync.maybeWhen(
            data: (categories) {
              if (displayedWallpapers.isEmpty) {
                return Center(child: Text(l10n.noWallpapersFound));
              }
              return MasonryGridView.count(
                padding: const EdgeInsets.fromLTRB(16, 5, 16, 110),
                physics: const BouncingScrollPhysics(),
                crossAxisCount: gridColumns,
                mainAxisSpacing: gridColumns == 2 ? 12 : 8,
                crossAxisSpacing: gridColumns == 2 ? 12 : 8,
                itemCount: displayedWallpapers.length,
                itemBuilder: (context, index) {
                  return WallpaperCard(wallpaper: displayedWallpapers[index]);
                },
              );
            },
            orElse: () => isDarkMode
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : const Center(
                    child: CircularProgressIndicator(color: Colors.black),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubNavItem(
    WidgetRef ref,
    String label,
    int index,
    bool isDarkMode,
  ) {
    final selectedSubTab = ref.watch(homeSubTabProvider);
    final isSelected = selectedSubTab == index;

    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          ref.read(homeSubTabProvider.notifier).state = index;
          HapticFeedback.lightImpact();
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? (isDarkMode ? Colors.white : Colors.black)
                : (isDarkMode ? Colors.white38 : Colors.black38),
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 15,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }
}

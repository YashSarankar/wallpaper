import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../providers/wallpaper_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/wallpaper_card.dart';

final homeSubTabProvider = StateProvider<int>((ref) => 0);

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSubTab = ref.watch(homeSubTabProvider);
    final randomWallpapers = ref.watch(randomWallpapersProvider);
    final latestWallpapers = ref.watch(latestWallpapersProvider);
    final isDarkMode = ref.watch(themeProvider);
    final settings = ref.watch(settingsProvider);
    final color = isDarkMode ? Colors.white : Colors.black;
    final wallpapersAsync = ref.watch(wallpapersProvider);

    final displayedWallpapers = selectedSubTab == 0
        ? latestWallpapers
        : randomWallpapers;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        const SliverToBoxAdapter(
          child: SizedBox(height: 95),
        ), // Reduced from 110
        // Premium Sub-Tab Selector
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ), // Reduced from 20/10
            child: Container(
              height: 44, // Reduced from 50
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
                        : Alignment.centerRight,
                    child: FractionallySizedBox(
                      widthFactor: 0.5,
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
                        child: _buildSubNavItem(ref, 'Latest', 0, isDarkMode),
                      ),
                      Expanded(
                        child: _buildSubNavItem(ref, 'Random', 1, isDarkMode),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        wallpapersAsync.when(
          data: (categories) {
            if (displayedWallpapers.isEmpty) {
              return const SliverFillRemaining(
                child: Center(child: Text('No wallpapers found')),
              );
            }
            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 5, 16, 120),
              sliver: SliverMasonryGrid.count(
                crossAxisCount: settings.gridColumns,
                mainAxisSpacing: settings.gridColumns == 2 ? 12 : 8,
                crossAxisSpacing: settings.gridColumns == 2 ? 12 : 8,
                itemBuilder: (context, index) {
                  return WallpaperCard(wallpaper: displayedWallpapers[index]);
                },
                childCount: displayedWallpapers.length,
              ),
            );
          },
          loading: () => const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (err, stack) => SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.wifi_exclamationmark,
                    size: 60,
                    color: color.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'LOOKS LIKE THE SERVER IS SLEEPING',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: color.withOpacity(0.5),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  CupertinoButton(
                    color: color,
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    borderRadius: BorderRadius.circular(100),
                    child: Text(
                      'WAKE UP',
                      style: TextStyle(
                        color: isDarkMode ? Colors.black : Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                    onPressed: () {
                      ref.invalidate(wallpapersProvider);
                      HapticFeedback.mediumImpact();
                    },
                  ),
                ],
              ),
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
          HapticFeedback.lightImpact(); // Added haptic feel
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

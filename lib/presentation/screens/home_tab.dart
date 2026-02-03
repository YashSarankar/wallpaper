import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../providers/wallpaper_provider.dart';
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
    final color = isDarkMode ? Colors.white : Colors.black;

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

        if (displayedWallpapers.isEmpty)
          SliverFillRemaining(
            child: Center(child: CircularProgressIndicator(color: color)),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              16,
              5,
              16,
              120,
            ), // Reduced horizontal and top padding
            sliver: SliverMasonryGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12, // Reduced from 20
              crossAxisSpacing: 12, // Reduced from 20
              itemBuilder: (context, index) {
                return WallpaperCard(wallpaper: displayedWallpapers[index]);
              },
              childCount: displayedWallpapers.length,
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

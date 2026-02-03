import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../providers/wallpaper_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/wallpaper_card.dart';

class TrendingTab extends ConsumerWidget {
  const TrendingTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendingWallpapers = ref.watch(trendingWallpapersProvider);
    final isDarkMode = ref.watch(themeProvider);
    final settings = ref.watch(settingsProvider);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: 95)),
        if (trendingWallpapers.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.flame,
                    size: 64,
                    color: isDarkMode ? Colors.white24 : Colors.black12,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No trending wallpapers yet',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white60 : Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 5, 16, 120),
            sliver: SliverMasonryGrid.count(
              crossAxisCount: settings.gridColumns,
              mainAxisSpacing: settings.gridColumns == 2 ? 12 : 8,
              crossAxisSpacing: settings.gridColumns == 2 ? 12 : 8,
              itemBuilder: (context, index) {
                return WallpaperCard(wallpaper: trendingWallpapers[index]);
              },
              childCount: trendingWallpapers.length,
            ),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../providers/wallpaper_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/wallpaper_card.dart';

import 'package:wallpaper/l10n/app_localizations.dart';

class TrendingTab extends ConsumerWidget {
  const TrendingTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendingWallpapers = ref.watch(trendingWallpapersProvider);
    final isDarkMode = ref.watch(themeProvider);
    final gridColumns = ref.watch(
      settingsProvider.select((s) => s.gridColumns),
    );
    final l10n = AppLocalizations.of(context)!;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(height: MediaQuery.of(context).padding.top + 70),
        ),
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
                    l10n.noTrending,
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
              crossAxisCount: gridColumns,
              mainAxisSpacing: gridColumns == 2 ? 12 : 8,
              crossAxisSpacing: gridColumns == 2 ? 12 : 8,
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

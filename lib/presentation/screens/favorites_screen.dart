import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../providers/wallpaper_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/wallpaper_card.dart';

import 'package:wallpaper/l10n/app_localizations.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final isDarkMode = ref.watch(themeProvider);
    final settings = ref.watch(settingsProvider);
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
          l10n.favorites,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.heart,
                    size: 64,
                    color: isDarkMode ? Colors.white24 : Colors.black12,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noFavorites,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white60 : Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : MasonryGridView.count(
              padding: const EdgeInsets.fromLTRB(16, 5, 16, 40),
              crossAxisCount: settings.gridColumns,
              mainAxisSpacing: settings.gridColumns == 2 ? 12 : 8,
              crossAxisSpacing: settings.gridColumns == 2 ? 12 : 8,
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final wallpaper = favorites[index];
                return WallpaperCard(wallpaper: wallpaper);
              },
            ),
    );
  }
}

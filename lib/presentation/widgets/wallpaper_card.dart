import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/wallpaper_model.dart';
import '../providers/wallpaper_provider.dart';
import '../providers/settings_provider.dart';
import '../screens/wallpaper_preview_screen.dart';
import 'universal_image.dart';

class WallpaperCard extends ConsumerWidget {
  final WallpaperModel wallpaper;

  const WallpaperCard({super.key, required this.wallpaper});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final isFav = favorites.any((w) => w.id == wallpaper.id);
    final settings = ref.watch(settingsProvider);

    return GestureDetector(
      onTap: () {
        final heroTag = '${wallpaper.id}_${context.hashCode}';
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (context, animation, secondaryAnimation) =>
                WallpaperPreviewScreen(wallpaper: wallpaper, heroTag: heroTag),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              Hero(
                tag: '${wallpaper.id}_${context.hashCode}',
                child: AspectRatio(
                  aspectRatio: 0.7,
                  child: UniversalImage(
                    path: settings.dataSaver
                        ? (wallpaper.lowUrl ?? wallpaper.url)
                        : (wallpaper.midUrl ?? wallpaper.url),
                    thumbnailUrl: wallpaper.lowUrl,
                    fit: BoxFit.cover,
                    borderRadius: 28,
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () => ref
                      .read(favoritesProvider.notifier)
                      .toggleFavorite(wallpaper),
                  child: ClipOval(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFav
                              ? CupertinoIcons.heart_fill
                              : CupertinoIcons.heart,
                          color: isFav ? Colors.red : Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

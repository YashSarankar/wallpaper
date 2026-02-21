import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../data/models/wallpaper_model.dart';
import '../providers/settings_provider.dart';
import '../providers/favorites_provider.dart';
import '../screens/wallpaper_preview_screen.dart';
import '../../utils/wallpaper_helper.dart';
import 'universal_image.dart';

class WallpaperCard extends ConsumerStatefulWidget {
  final WallpaperModel wallpaper;

  const WallpaperCard({super.key, required this.wallpaper});

  @override
  ConsumerState<WallpaperCard> createState() => _WallpaperCardState();
}

class _WallpaperCardState extends ConsumerState<WallpaperCard> {
  bool _isNavigating = false;
  VideoPlayerController? _videoController;
  bool _videoReady = false;

  bool get _isLive =>
      widget.wallpaper.type == 'animated' &&
      widget.wallpaper.videoUrl != null &&
      widget.wallpaper.videoUrl!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (_isLive) {
      _initVideo();
    }
  }

  Future<void> _initVideo() async {
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.wallpaper.videoUrl!),
    );
    _videoController = controller;
    try {
      await controller.initialize();
      if (!mounted) return;
      controller.setLooping(true);
      controller.setVolume(0);
      controller.play();
      setState(() => _videoReady = true);
    } catch (_) {
      // If video fails, fall through to thumbnail image
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(favoritesProvider);
    final isFav = favorites.any((w) => w.id == widget.wallpaper.id);
    final dataSaver = ref.watch(settingsProvider.select((s) => s.dataSaver));
    final isLive = _isLive;

    return GestureDetector(
      onTap: () {
        if (_isNavigating) return;

        // Skip preview screen for live wallpapers as requested
        if (isLive) {
          WallpaperHelper.setLiveWallpaper(context, widget.wallpaper, ref);
          return;
        }

        _isNavigating = true;
        final heroTag = '${widget.wallpaper.id}_${context.hashCode}';
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (context, animation, secondaryAnimation) =>
                WallpaperPreviewScreen(
                  wallpaper: widget.wallpaper,
                  heroTag: heroTag,
                ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          ),
        ).then((_) {
          if (mounted) {
            setState(() => _isNavigating = false);
            // Resume video playback when returning to grid
            if (_isLive && _videoReady) {
              _videoController?.play();
            }
          }
        });
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
              // Media layer: video for live, image for static
              Hero(
                tag: '${widget.wallpaper.id}_${context.hashCode}',
                child: AspectRatio(
                  aspectRatio: 0.7,
                  child: isLive && _videoReady && _videoController != null
                      ? FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _videoController!.value.size.width,
                            height: _videoController!.value.size.height,
                            child: VideoPlayer(_videoController!),
                          ),
                        )
                      : UniversalImage(
                          path: dataSaver
                              ? (widget.wallpaper.lowUrl ??
                                    widget.wallpaper.url)
                              : (widget.wallpaper.midUrl ??
                                    widget.wallpaper.url),
                          thumbnailUrl: widget.wallpaper.lowUrl,
                          fit: BoxFit.cover,
                          borderRadius: 28,
                          cacheWidth: 400,
                        ),
                ),
              ),

              // LIVE badge for animated wallpapers
              if (isLive)
                Positioned(
                  top: 10,
                  left: 10,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.75),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.play_circle_fill,
                              color: Colors.white,
                              size: 10,
                            ),
                            SizedBox(width: 3),
                            Text(
                              'LIVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // Heart button (hidden for live wallpapers — cannot be favourited)
              if (!isLive)
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () => ref
                        .read(favoritesProvider.notifier)
                        .toggleFavorite(widget.wallpaper),
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

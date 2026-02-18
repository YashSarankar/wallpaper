import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:async_wallpaper/async_wallpaper.dart';

import '../../data/models/wallpaper_model.dart';
import '../providers/wallpaper_provider.dart';
import '../providers/settings_provider.dart';
import '../screens/wallpaper_preview_screen.dart';
import 'universal_image.dart';

class WallpaperCard extends ConsumerStatefulWidget {
  final WallpaperModel wallpaper;

  const WallpaperCard({super.key, required this.wallpaper});

  @override
  ConsumerState<WallpaperCard> createState() => _WallpaperCardState();
}

class _WallpaperCardState extends ConsumerState<WallpaperCard> {
  bool _isNavigating = false;
  bool _isApplying = false;
  double? _progress;
  static const platform = MethodChannel('com.amozea.wallpapers/wallpaper');

  Future<void> _applyLiveWallpaper() async {
    if (_isApplying) return;
    setState(() {
      _isApplying = true;
      _progress = 0.05;
    });

    try {
      final url = widget.wallpaper.videoUrl;
      if (url == null) return;

      final client = http.Client();
      final request = http.Request('GET', Uri.parse(url));
      final response = await client.send(request);

      final contentLength = response.contentLength ?? 0;
      int receivedBytes = 0;

      final dir = await getTemporaryDirectory();
      final fileName = url.split('/').last.split('?').first;
      final path = '${dir.path}/$fileName';
      final file = File(path);
      final sink = file.openWrite();

      await response.stream.listen((chunk) {
        receivedBytes += chunk.length;
        sink.add(chunk);
        if (contentLength > 0 && mounted) {
          setState(() {
            _progress = receivedBytes / contentLength;
          });
        }
      }, cancelOnError: true).asFuture();

      await sink.close();
      client.close();

      if (mounted) {
        setState(() => _progress = null);
        try {
          // 1. Prepare the wallpaper using the plugin (it sets the video path for the service)
          await AsyncWallpaper.setLiveWallpaper(filePath: file.path);

          // 2. Launch our custom native picker that catches the result and brings the app back
          await platform.invokeMethod('setLiveWallpaper', {'path': file.path});
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: $e')));
          }
        }
      }
    } catch (e) {
      debugPrint('Error applying live wallpaper from card: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Download failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isApplying = false;
          _progress = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(favoritesProvider);
    final isFav = favorites.any((w) => w.id == widget.wallpaper.id);
    final settings = ref.watch(settingsProvider);

    return GestureDetector(
      onTap: () {
        if (_isNavigating || _isApplying) return;

        if (widget.wallpaper.type == 'animated') {
          _applyLiveWallpaper();
          HapticFeedback.mediumImpact();
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
              Hero(
                tag: '${widget.wallpaper.id}_${context.hashCode}',
                child: AspectRatio(
                  aspectRatio: 0.7,
                  child: UniversalImage(
                    path: settings.dataSaver
                        ? (widget.wallpaper.lowUrl ?? widget.wallpaper.url)
                        : (widget.wallpaper.midUrl ?? widget.wallpaper.url),
                    thumbnailUrl: widget.wallpaper.lowUrl,
                    fit: BoxFit.cover,
                    borderRadius: 28,
                    cacheWidth: 400,
                  ),
                ),
              ),
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
              if (widget.wallpaper.type == 'animated')
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.play_circle_fill,
                              color: Colors.white,
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'LIVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              if (_isApplying)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CupertinoActivityIndicator(
                            color: Colors.white,
                            radius: 12,
                          ),
                          if (_progress != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              '${(_progress! * 100).toInt()}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
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

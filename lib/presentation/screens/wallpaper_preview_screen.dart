import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../data/models/wallpaper_model.dart';
import '../widgets/universal_image.dart';
import '../providers/wallpaper_provider.dart';

class WallpaperPreviewScreen extends ConsumerStatefulWidget {
  final WallpaperModel wallpaper;

  const WallpaperPreviewScreen({super.key, required this.wallpaper});

  @override
  ConsumerState<WallpaperPreviewScreen> createState() =>
      _WallpaperPreviewScreenState();
}

class _WallpaperPreviewScreenState
    extends ConsumerState<WallpaperPreviewScreen> {
  bool _isSetting = false;
  double? _progress;
  bool _showPreviewUI = true;
  static const platform = MethodChannel('com.example.wallpaper/wallpaper');

  String get _highResUrl {
    String url = widget.wallpaper.url;
    if (url.contains('unsplash.com')) {
      // Remove restricted width/quality and boost it for preview
      url = url.replaceAll(RegExp(r'&w=\d+'), '&w=2400');
      url = url.replaceAll(RegExp(r'&q=\d+'), '&q=100');
    }
    return url;
  }

  Future<File?> _downloadFile(String url) async {
    setState(() => _progress = 0.0);
    try {
      final client = http.Client();
      final request = http.Request('GET', Uri.parse(url));
      final response = await client.send(request);

      if (response.statusCode != 200) {
        throw Exception('Failed to download file: ${response.statusCode}');
      }

      final contentLength = response.contentLength ?? 0;
      int receivedBytes = 0;

      final dir = await getTemporaryDirectory();
      final fileName = url.split('/').last;
      final path = '${dir.path}/$fileName';
      final file = File(path);
      final sink = file.openWrite();

      await response.stream
          .listen(
            (chunk) {
              receivedBytes += chunk.length;
              sink.add(chunk);
              if (contentLength > 0) {
                setState(() {
                  _progress = receivedBytes / contentLength;
                });
              }
            },
            onDone: () async {
              await sink.close();
              client.close();
            },
            onError: (e) {
              sink.close();
              client.close();
              throw e;
            },
            cancelOnError: true,
          )
          .asFuture();

      return file;
    } catch (e) {
      debugPrint('Error downloading file: $e');
      return null;
    } finally {
      if (mounted) {
        setState(() => _progress = null);
      }
    }
  }

  Future<void> _setWallpaper(int location) async {
    setState(() => _isSetting = true);
    try {
      final file = await _downloadFile(widget.wallpaper.url);
      if (file != null) {
        try {
          final result = await platform.invokeMethod('setWallpaper', {
            'path': file.path,
            'location': location,
          });

          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Wallpaper Set: $result')));
          }
        } on PlatformException catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to set wallpaper: ${e.message}')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSetting = false);
    }
  }

  Future<void> _downloadWallpaper() async {
    debugPrint('Starting download process for: ${widget.wallpaper.url}');
    if (Platform.isAndroid) {
      final status = await [Permission.storage, Permission.photos].request();
      debugPrint('Permission status: $status');
    }

    if (!mounted) return;

    try {
      final url = _highResUrl;
      setState(() => _progress = 0.01);

      final file = await _downloadFile(url);
      if (file != null) {
        debugPrint('Temporary file downloaded to: ${file.path}');
        String savePath;
        if (Platform.isAndroid) {
          final directory = Directory('/storage/emulated/0/Download');
          if (!await directory.exists()) {
            await directory.create(recursive: true);
          }
          final extension = url.split('.').last.split('?').first;
          final fileName =
              'Wallpaper_${widget.wallpaper.id}_${DateTime.now().millisecondsSinceEpoch}.$extension';
          savePath = '${directory.path}/$fileName';
        } else {
          final appDir = await getApplicationDocumentsDirectory();
          savePath = '${appDir.path}/${url.split('/').last}';
        }

        debugPrint('Attempting to copy file to: $savePath');
        final savedFile = await file.copy(savePath);
        debugPrint(
          'File saved successfully: ${savedFile.path}, exists: ${await savedFile.exists()}',
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Download complete! Opening...')),
          );

          await Future.delayed(const Duration(milliseconds: 800));

          try {
            debugPrint('Invoking native openFile for: $savePath');
            final result = await platform.invokeMethod('openFile', {
              'path': savePath,
            });
            debugPrint('Native openFile result: $result');
          } on PlatformException catch (e) {
            debugPrint('Native openFile error: ${e.message}');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Could not open file: ${e.message}')),
              );
            }
          }
        }
      } else {
        throw Exception('File download failed (result was null)');
      }
    } catch (e) {
      debugPrint('General download error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Download error: $e')));
      }
    } finally {
      if (mounted) setState(() => _progress = null);
    }
  }

  Future<void> _shareWallpaper() async {
    final file = await _downloadFile(widget.wallpaper.url);
    if (file != null) {
      final newPath =
          '${file.parent.path}/${file.uri.pathSegments.last.replaceAll(RegExp(r'\.[^.]+$'), '')}.png';
      final pngFile = await file.copy(newPath);

      await Share.shareXFiles([
        XFile(pngFile.path, mimeType: 'image/png'),
      ], text: 'Check out this wallpaper!');
    }
  }

  void _showSetWallpaperOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Set Wallpaper',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(CupertinoIcons.home, color: Colors.white),
                title: const Text(
                  'Home Screen',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _setWallpaper(1);
                },
              ),
              ListTile(
                leading: const Icon(CupertinoIcons.lock, color: Colors.white),
                title: const Text(
                  'Lock Screen',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _setWallpaper(2);
                },
              ),
              ListTile(
                leading: const Icon(
                  CupertinoIcons.device_phone_portrait,
                  color: Colors.white,
                ),
                title: const Text(
                  'Both Screens',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _setWallpaper(3);
                },
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFav = ref
        .watch(favoritesProvider.notifier)
        .isFavorite(widget.wallpaper.id);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Image with Zoom
          Positioned.fill(
            child: InteractiveViewer(
              minScale: 1.0,
              maxScale: 3.0,
              boundaryMargin: EdgeInsets.zero,
              child: Hero(
                tag: widget.wallpaper.id,
                child: UniversalImage(
                  path: _highResUrl,
                  thumbnailUrl: widget.wallpaper.lowUrl,
                  fit: BoxFit.cover,
                  placeholder: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  errorWidget: const Center(
                    child: Icon(
                      CupertinoIcons.exclamationmark_circle,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Tap to Toggle UI
          Positioned.fill(
            child: GestureDetector(
              onTap: () => setState(() => _showPreviewUI = !_showPreviewUI),
            ),
          ),

          // iOS Style Lock Screen Preview Overlay
          if (_showPreviewUI)
            Positioned(
              top: MediaQuery.of(context).padding.top + 60,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Column(
                  children: [
                    Text(
                      _getTime(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 80,
                        fontWeight: FontWeight.w200,
                        shadows: [
                          Shadow(blurRadius: 20, color: Colors.black45),
                        ],
                      ),
                    ),
                    Text(
                      _getDate(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        shadows: [
                          Shadow(blurRadius: 20, color: Colors.black45),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Top Action Bar (iOS Style)
          if (_showPreviewUI)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top,
                  left: 10,
                  right: 10,
                  bottom: 10,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        CupertinoIcons.back,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    IconButton(
                      icon: const Icon(
                        CupertinoIcons.share,
                        color: Colors.white,
                      ),
                      onPressed: _shareWallpaper,
                    ),
                  ],
                ),
              ),
            ),

          // Bottom Glassmorphic Actions
          if (_showPreviewUI)
            Positioned(
              bottom: 40,
              left: 30,
              right: 30,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    height: 80,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildIconButton(
                          icon: CupertinoIcons.cloud_download,
                          label: 'Download',
                          onTap: _progress != null ? null : _downloadWallpaper,
                          isLoading: _progress != null,
                        ),
                        _buildSetButton(),
                        _buildIconButton(
                          icon: isFav
                              ? CupertinoIcons.heart_fill
                              : CupertinoIcons.heart,
                          label: 'Favorite',
                          color: isFav ? Colors.redAccent : Colors.white,
                          onTap: () => ref
                              .read(favoritesProvider.notifier)
                              .toggleFavorite(widget.wallpaper),
                        ),
                        _buildIconButton(
                          icon: _showPreviewUI
                              ? CupertinoIcons.eye_slash
                              : CupertinoIcons.eye,
                          label: 'Preview',
                          onTap: () =>
                              setState(() => _showPreviewUI = !_showPreviewUI),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Progress Overlay
          if (_progress != null)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: _progress,
                            minHeight: 8,
                            backgroundColor: Colors.white24,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Downloading ${(_progress! * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    bool isLoading = false,
    Color color = Colors.white,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(icon, color: color, size: 28),

            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetButton() {
    return ElevatedButton(
      onPressed: _isSetting ? null : _showSetWallpaperOptions,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        elevation: 0,
      ),
      child: _isSetting
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.black,
              ),
            )
          : const Text(
              'Set',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
    );
  }

  String _getTime() {
    final now = DateTime.now();
    return '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
  }

  String _getDate() {
    final now = DateTime.now();
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }
}

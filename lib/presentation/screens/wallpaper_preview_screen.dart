import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/models/wallpaper_model.dart';
import '../widgets/universal_image.dart';
import '../providers/wallpaper_provider.dart';

import 'package:wallpaper/l10n/app_localizations.dart';

class WallpaperPreviewScreen extends ConsumerStatefulWidget {
  final WallpaperModel? wallpaper;
  final File? localFile;
  final String? heroTag;

  const WallpaperPreviewScreen({
    super.key,
    this.wallpaper,
    this.localFile,
    this.heroTag,
  }) : assert(wallpaper != null || localFile != null);

  @override
  ConsumerState<WallpaperPreviewScreen> createState() =>
      _WallpaperPreviewScreenState();
}

class _WallpaperPreviewScreenState
    extends ConsumerState<WallpaperPreviewScreen> {
  bool _isSetting = false;
  double? _progress;
  bool _showPreviewUI = true;
  static const platform = MethodChannel('com.amozea.wallpapers/wallpaper');

  String get _highResUrl {
    if (widget.localFile != null) return widget.localFile!.path;
    String url = widget.wallpaper!.url;
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
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isSetting = true);
    try {
      File? file;
      if (widget.localFile != null) {
        file = widget.localFile;
      } else {
        file = await _downloadFile(_highResUrl);
      }

      if (file != null) {
        try {
          // 1=Home, 2=Lock, 3=Both.
          await platform.invokeMethod('setWallpaper', {
            'path': file.path,
            'location': location,
          });

          // Result is void so we assume success if no error
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.wallpaperSet)));
          }
        } on PlatformException catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${l10n.failedToSet}: ${e.message}')),
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
    if (widget.localFile != null) return;
    final l10n = AppLocalizations.of(context)!;

    debugPrint('Starting download process for: ${widget.wallpaper!.url}');
    // Manual permission requests removed to follow Privacy-First guidelines.
    // Modern Android handles file saving/picking via secure system pickers.

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
              'Wallpaper_${widget.wallpaper!.id}_${DateTime.now().millisecondsSinceEpoch}.$extension';
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.downloadComplete)));

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
    if (widget.localFile != null) return; // Already on device
    final l10n = AppLocalizations.of(context)!;
    final file = await _downloadFile(_highResUrl);
    if (file != null) {
      final newPath =
          '${file.parent.path}/${file.uri.pathSegments.last.replaceAll(RegExp(r'\.[^.]+$'), '')}.png';
      final pngFile = await file.copy(newPath);

      await Share.shareXFiles([
        XFile(pngFile.path, mimeType: 'image/png'),
      ], text: l10n.checkOutWallpaper);
    }
  }

  void _showSetWallpaperOptions() {
    final l10n = AppLocalizations.of(context)!;
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  l10n.setWallpaper,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(CupertinoIcons.home, color: Colors.white),
                title: Text(
                  l10n.homeScreen,
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _setWallpaper(1);
                },
              ),
              ListTile(
                leading: const Icon(CupertinoIcons.lock, color: Colors.white),
                title: Text(
                  l10n.lockScreen,
                  style: const TextStyle(color: Colors.white),
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
                title: Text(
                  l10n.bothScreens,
                  style: const TextStyle(color: Colors.white),
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
    final isLocal = widget.localFile != null;
    final favorites = ref.watch(favoritesProvider);
    final l10n = AppLocalizations.of(context)!;
    final isFav = isLocal
        ? favorites.any(
            (w) => w.id == 'local_${widget.localFile!.path.hashCode}',
          )
        : favorites.any((w) => w.id == widget.wallpaper!.id);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
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
                  tag:
                      widget.heroTag ??
                      (isLocal ? 'local' : widget.wallpaper!.id),
                  child: UniversalImage(
                    path: _highResUrl,
                    thumbnailUrl: isLocal ? null : widget.wallpaper!.lowUrl,
                    fit: BoxFit.cover,
                    placeholder: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                    errorWidget: const Center(
                      child: Icon(
                        CupertinoIcons.exclamationmark_circle,
                        color: Colors.white24,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Tap to Toggle UI Overlay (Transparent layer)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _showPreviewUI = !_showPreviewUI),
              ),
            ),

            // Top Header (Back & Share)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutBack,
              top: _showPreviewUI ? 0 : -100,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 10,
                  left: 16,
                  right: 16,
                  bottom: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildBlurButton(
                      icon: CupertinoIcons.back,
                      onTap: () => Navigator.pop(context),
                    ),
                    _buildBlurButton(
                      icon: CupertinoIcons.share,
                      onTap: _shareWallpaper,
                    ),
                  ],
                ),
              ),
            ),

            // iOS Style Lock Screen Preview (Time & Date)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              top: _showPreviewUI
                  ? MediaQuery.of(context).padding.top + 70
                  : -200,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _showPreviewUI ? 1.0 : 0.0,
                child: IgnorePointer(
                  child: Column(
                    children: [
                      Text(
                        _getTime(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 86,
                          fontWeight: FontWeight.w200,
                          letterSpacing: -2,
                          shadows: [
                            Shadow(
                              blurRadius: 30,
                              color: Colors.black45,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _getDate().toUpperCase(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                          shadows: const [
                            Shadow(blurRadius: 20, color: Colors.black45),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Action Bar (Integrated)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutBack,
              bottom: _showPreviewUI ? 40 : -120,
              left: 20,
              right: 20,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(35),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                    child: Container(
                      height: 70,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(35),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isLocal)
                            _buildActionIcon(
                              icon: CupertinoIcons.cloud_download,
                              onTap: _progress != null
                                  ? null
                                  : _downloadWallpaper,
                              isLoading: _progress != null,
                            ),
                          if (!isLocal) const SizedBox(width: 4),
                          _buildSetAction(l10n),
                          if (!isLocal) const SizedBox(width: 4),
                          _buildActionIcon(
                            icon: isFav
                                ? CupertinoIcons.heart_fill
                                : CupertinoIcons.heart,
                            activeColor: Colors.redAccent,
                            isActive: isFav,
                            onTap: () {
                              if (isLocal) {
                                ref
                                    .read(favoritesProvider.notifier)
                                    .toggleLocalFavorite(widget.localFile!);
                              } else {
                                ref
                                    .read(favoritesProvider.notifier)
                                    .toggleFavorite(widget.wallpaper!);
                              }
                              HapticFeedback.mediumImpact();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Progress Overlay
            if (_progress != null)
              Positioned(
                bottom: 120,
                left: 50,
                right: 50,
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: _progress,
                        minHeight: 4,
                        backgroundColor: Colors.white10,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${l10n.downloading} ${(_progress! * 100).toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlurButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildActionIcon({
    required IconData icon,
    required VoidCallback? onTap,
    bool isLoading = false,
    bool isActive = false,
    Color activeColor = Colors.white,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 58,
        height: 58,
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Icon(
                  icon,
                  color: isActive ? activeColor : Colors.white.withOpacity(0.9),
                  size: 26,
                ),
        ),
      ),
    );
  }

  Widget _buildSetAction(AppLocalizations l10n) {
    return GestureDetector(
      onTap: _isSetting ? null : _showSetWallpaperOptions,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        height: 54,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(27),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: _isSetting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black,
                  ),
                )
              : Text(
                  l10n.apply,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 1.2,
                  ),
                ),
        ),
      ),
    );
  }

  String _getTime() {
    final now = DateTime.now();
    final hour = now.hour > 12
        ? now.hour - 12
        : (now.hour == 0 ? 12 : now.hour);
    return '$hour:${now.minute.toString().padLeft(2, '0')}';
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

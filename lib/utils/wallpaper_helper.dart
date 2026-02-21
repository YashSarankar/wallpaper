import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../presentation/providers/live_wallpaper_provider.dart';
import '../../data/models/wallpaper_model.dart';
import 'package:flutter/services.dart';

class WallpaperHelper {
  static Future<void> setLiveWallpaper(
    BuildContext context,
    WallpaperModel wallpaper,
    WidgetRef ref,
  ) async {
    final videoUrl = wallpaper.videoUrl;
    if (videoUrl == null || videoUrl.isEmpty) return;

    final notifier = ref.read(liveWallpaperProvider.notifier);
    notifier.setDownloading(true);

    // Show a premium looking progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final state = ref.watch(liveWallpaperProvider);
          return PopScope(
            canPop: false,
            child: AlertDialog(
              backgroundColor: Colors.black.withOpacity(0.9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
                side: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 0.5,
                ),
              ),
              contentPadding: const EdgeInsets.all(30),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: CircularProgressIndicator(
                          value: state.downloadProgress > 0
                              ? state.downloadProgress
                              : null,
                          strokeWidth: 6,
                          color: Colors.blueAccent,
                          backgroundColor: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      if (state.downloadProgress > 0)
                        Text(
                          "${(state.downloadProgress * 100).toInt()}%",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "Preparing Live Wallpaper",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Preparing high-quality video preview...",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    try {
      final client = http.Client();
      final request = http.Request('GET', Uri.parse(videoUrl));
      final response = await client.send(request);

      final contentLength = response.contentLength ?? 0;
      int receivedBytes = 0;

      final dir = await getTemporaryDirectory();
      // Use ID in filename to avoid collision but keep it stable for the session
      final file = File('${dir.path}/live_temp_${wallpaper.id}.mp4');
      final sink = file.openWrite();

      await response.stream
          .listen(
            (chunk) {
              receivedBytes += chunk.length;
              sink.add(chunk);
              if (contentLength > 0) {
                notifier.setDownloading(
                  true,
                  progress: receivedBytes / contentLength,
                );
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

      // Save to stable location
      String savePath;
      final directory = await getApplicationDocumentsDirectory();
      final wpDir = Directory('${directory.path}/live_wallpapers');
      if (!await wpDir.exists()) {
        await wpDir.create(recursive: true);
      }
      final ext = videoUrl.split('.').last.split('?').first;
      final fileName =
          'LiveWallpaper_${wallpaper.id}.${ext.isNotEmpty ? ext : 'mp4'}';
      savePath = '${wpDir.path}/$fileName';

      // Copy to final location (don't delete original yet, we'll cleanup later)
      await file.copy(savePath);

      if (context.mounted) {
        Navigator.pop(context); // Close dialog
        notifier.setDownloading(false);
        await notifier.setPending(wallpaper.id);

        const platform = MethodChannel('com.amozea.wallpapers/wallpaper');
        await platform.invokeMethod('setLiveWallpaper', {'path': savePath});
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close dialog
        notifier.setDownloading(false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

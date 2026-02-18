import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UniversalImage extends StatelessWidget {
  final String path;
  final String? thumbnailUrl;
  final BoxFit fit;
  final double? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final FilterQuality filterQuality;
  final int? cacheWidth;
  final int? cacheHeight;
  final Alignment alignment;

  const UniversalImage({
    super.key,
    required this.path,
    this.thumbnailUrl,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.filterQuality = FilterQuality.high,
    this.cacheWidth,
    this.cacheHeight,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    if (path.startsWith('http')) {
      imageWidget = CachedNetworkImage(
        imageUrl: path,
        fit: fit,
        filterQuality: filterQuality,
        memCacheWidth: cacheWidth,
        memCacheHeight: cacheHeight,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
              fit: fit,
              alignment: alignment,
              filterQuality: filterQuality,
            ),
          ),
        ),
        fadeInDuration: const Duration(milliseconds: 500),
        fadeOutDuration: const Duration(milliseconds: 300),
        placeholder: (context, url) =>
            placeholder ??
            (thumbnailUrl != null && thumbnailUrl != path
                ? CachedNetworkImage(
                    imageUrl: thumbnailUrl!,
                    fit: fit,
                    alignment: alignment,
                    filterQuality: filterQuality,
                    // DO NOT set memCacheWidth here to ensure it hits the home screen cache
                    placeholder: (context, url) => _buildShimmerPlaceholder(),
                  )
                : _buildShimmerPlaceholder()),
        errorWidget: (context, url, error) =>
            errorWidget ?? _buildErrorPlaceholder(),
      );
    } else if (File(path).existsSync()) {
      imageWidget = Image.file(
        File(path),
        fit: fit,
        filterQuality: filterQuality,
        cacheWidth: cacheWidth,
        cacheHeight: cacheHeight,
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? _buildErrorPlaceholder();
        },
      );
    } else {
      imageWidget = Image.asset(
        path,
        fit: fit,
        filterQuality: filterQuality,
        cacheWidth: cacheWidth,
        cacheHeight: cacheHeight,
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? _buildErrorPlaceholder();
        },
      );
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius!),
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildShimmerPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.black12),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.grey[100],
      child: const Center(
        child: Icon(CupertinoIcons.photo, color: Colors.black12, size: 32),
      ),
    );
  }
}

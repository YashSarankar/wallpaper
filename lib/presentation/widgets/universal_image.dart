import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UniversalImage extends StatelessWidget {
  final String path;
  final String? thumbnailUrl;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const UniversalImage({
    super.key,
    required this.path,
    this.thumbnailUrl,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (path.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: path,
        fit: fit,
        fadeInDuration: const Duration(milliseconds: 500),
        fadeOutDuration: const Duration(milliseconds: 300),
        placeholder: (context, url) =>
            placeholder ??
            (thumbnailUrl != null
                ? CachedNetworkImage(
                    imageUrl: thumbnailUrl!,
                    fit: fit,
                    placeholder: (context, url) => _buildShimmerPlaceholder(),
                  )
                : _buildShimmerPlaceholder()),
        errorWidget: (context, url, error) =>
            errorWidget ?? _buildErrorPlaceholder(),
      );
    } else {
      return Image.asset(
        path,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? _buildErrorPlaceholder();
        },
      );
    }
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
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Colors.black12,
          size: 32,
        ),
      ),
    );
  }
}

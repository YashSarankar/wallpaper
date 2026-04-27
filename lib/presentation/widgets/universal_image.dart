import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';

/// A WhatsApp-style progressive image loader.
///
/// Loading order:
///   Frame 0 (synchronous, zero network): BlurHash → instant blurred preview
///   Frame 1 (lowUrl arrives):  fade over BlurHash
///   Frame 2 (thumbnailUrl/midUrl arrives): fade over low
///   Frame 3 (path/originalUrl arrives): fade over mid   [optional, for preview screen]
///
/// No grey backgrounds. No CircularProgressIndicator. No blank frames.
class UniversalImage extends StatefulWidget {
  final String path;
  final String? thumbnailUrl; // mid-res
  final String? lowThumbnailUrl; // low-res
  final String? blurHash; // instant synchronous first frame
  final BoxFit fit;
  final double? borderRadius;
  final FilterQuality filterQuality;
  final int? cacheWidth;
  final Alignment alignment;

  const UniversalImage({
    super.key,
    required this.path,
    this.thumbnailUrl,
    this.lowThumbnailUrl,
    this.blurHash,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.filterQuality = FilterQuality.high,
    this.cacheWidth,
    this.alignment = Alignment.center,
  });

  @override
  State<UniversalImage> createState() => _UniversalImageState();
}

class _UniversalImageState extends State<UniversalImage> {
  // Each stage index represents how far we've loaded.
  // -1 = only showing BlurHash, 0+ = network layers loaded.
  int _loadedUpTo = -1;
  List<String> _netLayers = [];
  int _sequenceId = 0;

  @override
  void initState() {
    super.initState();
    _setupLayers();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _initLoading();
    });
  }

  @override
  void didUpdateWidget(covariant UniversalImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path ||
        oldWidget.thumbnailUrl != widget.thumbnailUrl ||
        oldWidget.lowThumbnailUrl != widget.lowThumbnailUrl ||
        oldWidget.blurHash != widget.blurHash) {
      _setupLayers();
      _initLoading();
    }
  }

  void _setupLayers() {
    // Build prioritized layer list: low → mid → original
    _netLayers = [
      if (widget.lowThumbnailUrl != null && widget.lowThumbnailUrl!.isNotEmpty)
        widget.lowThumbnailUrl!,
      if (widget.thumbnailUrl != null &&
          widget.thumbnailUrl!.isNotEmpty &&
          widget.thumbnailUrl != widget.lowThumbnailUrl)
        widget.thumbnailUrl!,
      if (widget.path.isNotEmpty &&
          widget.path != widget.thumbnailUrl &&
          widget.path != widget.lowThumbnailUrl)
        widget.path,
    ];

    // Identify layers already in memory/disk cache
    // We'll let _loadStages handle identifying and revealing cached layers
    // sequentially to avoid manual ImageStream handle management.
    _loadedUpTo = -1;
  }

  void _initLoading() {
    _sequenceId++;
    final mySeq = _sequenceId;

    // Begin staged loading for remaining layers
    // (This part uses context so it stays in post-frame callback)
    _loadStages(mySeq);
  }

  Future<void> _loadStages(int seqId) async {
    for (int i = 0; i < _netLayers.length; i++) {
      if (!mounted || _sequenceId != seqId) return;

      // Skip layers already identified as cached in _init
      if (i <= _loadedUpTo) continue;

      final url = _netLayers[i];

      try {
        // Use precacheImage: the official, safe way to ensure an image is ready
        // without manually touching raw ImageStream handles which can cause
        // "Cannot clone a disposed image" errors.
        await precacheImage(
          CachedNetworkImageProvider(url, maxWidth: widget.cacheWidth),
          context,
          onError: (e, s) {},
        );
      } catch (e) {
        // Silence errors here; we'll handle them in the UI layer if needed.
        // We want to continue to the next (likely higher-res) layer anyway.
      }

      if (!mounted || _sequenceId != seqId) return;

      // Reveal this layer — the BlurHash beneath will be covered by a smooth fade
      setState(() => _loadedUpTo = i);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (widget.path.startsWith('http')) {
      content = _buildProgressiveStack();
    } else if (File(widget.path).existsSync()) {
      content = Image.file(
        File(widget.path),
        fit: widget.fit,
        alignment: widget.alignment,
        filterQuality: widget.filterQuality,
        cacheWidth: widget.cacheWidth,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      );
    } else {
      content = Image.asset(
        widget.path,
        fit: widget.fit,
        alignment: widget.alignment,
        filterQuality: widget.filterQuality,
        cacheWidth: widget.cacheWidth,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      );
    }

    if (widget.borderRadius != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius!),
        child: content,
      );
    }
    return content;
  }

  Widget _buildProgressiveStack() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ─── Layer 0: BlurHash ─────────────────────────────────────────
        // Only show if no network layers are visible yet.
        if (_loadedUpTo < 0)
          widget.blurHash != null && widget.blurHash!.isNotEmpty
              ? BlurHash(hash: widget.blurHash!)
              : const ColoredBox(color: Colors.black12),

        // ─── Network layers ───────────────────────────────────────────
        // PRUNING LOGIC: Only show the current layer and the one immediately below it.
        // This prevents "Cannot clone a disposed image" crashes by ensuring 
        // we don't have 4-5 high-res layers in memory simultaneously.
        for (int i = 0; i < _netLayers.length; i++)
          if (i == _loadedUpTo || (i == _loadedUpTo - 1 && _loadedUpTo > 0))
            _FadeInLayer(
              key: ValueKey(_netLayers[i]),
              url: _netLayers[i],
              fit: widget.fit,
              alignment: widget.alignment,
              filterQuality: i == _netLayers.length - 1
                  ? widget.filterQuality
                  : FilterQuality.low,
              cacheWidth: widget.cacheWidth,
              duration: i == _netLayers.length - 1
                  ? const Duration(milliseconds: 1200)
                  : const Duration(milliseconds: 400),
            ),
      ],
    );
  }
}

/// A stateless widget that renders a CachedNetworkImage layer and
/// fades it in once (since it's only added to the tree after load is complete).
/// A stateless widget that renders a CachedNetworkImage layer and
/// fades it in once (since it's only added to the tree after load is complete).
class _FadeInLayer extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final Alignment alignment;
  final FilterQuality filterQuality;
  final int? cacheWidth;
  final Duration duration;

  const _FadeInLayer({
    super.key,
    required this.url,
    required this.fit,
    required this.alignment,
    required this.filterQuality,
    this.cacheWidth,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Image(
      image: CachedNetworkImageProvider(url, maxWidth: cacheWidth),
      fit: fit,
      alignment: alignment,
      filterQuality: filterQuality,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      // 🔥 The built-in, stable way to handle fade-ins and cache detection.
      // Eliminates the need for manual AnimationControllers and ImageStreamListeners.
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: duration,
          curve: Curves.easeOut,
          child: child,
        );
      },
    );
  }
}


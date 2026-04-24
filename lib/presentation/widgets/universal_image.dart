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
  late List<String> _netLayers;
  int _sequenceId = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didUpdateWidget(covariant UniversalImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path ||
        oldWidget.thumbnailUrl != widget.thumbnailUrl ||
        oldWidget.lowThumbnailUrl != widget.lowThumbnailUrl ||
        oldWidget.blurHash != widget.blurHash) {
      _init();
    }
  }

  void _init() {
    _sequenceId++;
    final mySeq = _sequenceId;
    
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

    // 🔥 SYNC CACHE CHECK: Identify layers already in memory/disk cache 
    // to avoid starting from BlurHash if we already have better data.
    int highestCached = -1;
    for (int i = 0; i < _netLayers.length; i++) {
      final provider = CachedNetworkImageProvider(
        _netLayers[i], 
        maxWidth: widget.cacheWidth,
      );
      final stream = provider.resolve(ImageConfiguration.empty);
      bool isSync = false;
      final listener = ImageStreamListener((_, bool sync) {
        isSync = sync;
      });
      stream.addListener(listener);
      stream.removeListener(listener);
      
      if (isSync) {
        highestCached = i;
      } else {
        // If this layer isn't cached, don't check higher ones yet 
        // to maintain the progressive loading order.
        break;
      }
    }

    _loadedUpTo = highestCached;

    // Begin staged loading for remaining layers
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
        // Synchronous — renders in the FIRST frame from an embedded string.
        // No network call. Covers the entire card with a blurred color impression.
        if (widget.blurHash != null && widget.blurHash!.isNotEmpty)
          BlurHash(hash: widget.blurHash!)
        else
          // Fallback if no blurHash: solid black (AMOLED) — not grey, not a spinner
          const ColoredBox(color: Colors.black12),

        // ─── Network layers ───────────────────────────────────────────
        // Each one fades in atop the previous layer after its bytes are ready.
        for (int i = 0; i < _netLayers.length; i++)
          if (i <= _loadedUpTo)
            _FadeInLayer(
              key: ValueKey(_netLayers[i]),
              url: _netLayers[i],
              fit: widget.fit,
              alignment: widget.alignment,
              filterQuality: i == _netLayers.length - 1
                  ? widget.filterQuality
                  : FilterQuality.low,
              cacheWidth: widget.cacheWidth,
              // Use a much longer fade for the final high-res layer (Layer 2+)
              // to make the transition from Mid-res to 4K feel cinematic and smooth.
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
class _FadeInLayer extends StatefulWidget {
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
  State<_FadeInLayer> createState() => _FadeInLayerState();
}

class _FadeInLayerState extends State<_FadeInLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  bool _isLoadedSync = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);

    // 🔥 PRE-CHECK: If the image is already in Flutter's memory cache, 
    // we should show it INSTANTLY (value=1.0) to avoid any flicker.
    _checkCache();
  }

  void _checkCache() {
    final provider = CachedNetworkImageProvider(
      widget.url,
      maxWidth: widget.cacheWidth,
    );
    
    final ImageStream stream = provider.resolve(ImageConfiguration.empty);
    stream.addListener(
      ImageStreamListener((ImageInfo info, bool synchronousCall) {
        if (synchronousCall && mounted) {
          _isLoadedSync = true;
          _ctrl.value = 1.0;
        } else if (mounted) {
          _ctrl.forward();
        }
      }),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Image(
        image: CachedNetworkImageProvider(
          widget.url,
          maxWidth: widget.cacheWidth,
        ),
        fit: widget.fit,
        alignment: widget.alignment,
        filterQuality: widget.filterQuality,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      ),
    );
  }
}

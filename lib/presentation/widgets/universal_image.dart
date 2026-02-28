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
    _loadedUpTo = -1; // Start at BlurHash only

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

    // Begin staged loading immediately
    _loadStages(mySeq);
  }

  Future<void> _loadStages(int seqId) async {
    for (int i = 0; i < _netLayers.length; i++) {
      if (!mounted || _sequenceId != seqId) return;

      final url = _netLayers[i];
      final provider = CachedNetworkImageProvider(
        url,
        maxWidth: widget.cacheWidth,
      );

      final completer = Completer<void>();
      final stream = provider.resolve(ImageConfiguration.empty);
      late ImageStreamListener listener;
      listener = ImageStreamListener(
        (_, __) {
          if (!completer.isCompleted) completer.complete();
        },
        onError: (_, __) {
          if (!completer.isCompleted) completer.complete();
        },
      );
      stream.addListener(listener);
      await completer.future;
      stream.removeListener(listener);

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

  const _FadeInLayer({
    super.key,
    required this.url,
    required this.fit,
    required this.alignment,
    required this.filterQuality,
    this.cacheWidth,
  });

  @override
  State<_FadeInLayer> createState() => _FadeInLayerState();
}

class _FadeInLayerState extends State<_FadeInLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    // Since this widget is only added to the tree AFTER the image is in cache,
    // we start the fade immediately on mount.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _ctrl.forward();
    });
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

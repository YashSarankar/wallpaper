import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../core/ads/ad_config.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  AdSize? _adSize;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load ad once we have the context needed for adaptive size
    if (!_isLoaded && _bannerAd == null) {
      _loadAd();
    }
  }

  Future<void> _loadAd() async {
    // 🔥 PRODUCTION FIX: Standard banners often fail to fill on modern screens.
    // Adaptive banners request the best-fitting ad for the device width.
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
          MediaQuery.of(context).size.width.truncate(),
        );

    if (size == null) return;

    _bannerAd = BannerAd(
      adUnitId: AdConfig.bannerAdUnitId,
      request: const AdRequest(),
      size: size,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
            _isLoaded = true;
            _adSize = size;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoaded && _bannerAd != null && _adSize != null) {
      return Container(
        alignment: Alignment.center,
        width: _adSize!.width.toDouble(),
        height: _adSize!.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }
    return const SizedBox.shrink();
  }
}

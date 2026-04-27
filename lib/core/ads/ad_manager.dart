import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ad_config.dart';

final adManagerProvider = Provider<AdManager>((ref) {
  return AdManager();
});

class AdManager {
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  int _interstitialLoadAttempts = 0;
  int _rewardedLoadAttempts = 0;
  int _wallpaperClickCount = 0;

  static const int maxFailedLoadAttempts = 3;

  bool get isRewardedAdReady => _rewardedAd != null;

  // Initialize and preload ads
  void init() {
    _loadInterstitialAd();
    _loadRewardedAd();
  }

  // --- Interstitial Ads ---

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdConfig.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialLoadAttempts = 0;
        },
        onAdFailedToLoad: (error) {
          _interstitialLoadAttempts++;
          _interstitialAd = null;

          // Exponential backoff: 2s, 4s, 8s... up to 60s
          final retryDelay = Duration(
            seconds: (1 << _interstitialLoadAttempts).clamp(2, 60),
          );
          Future.delayed(retryDelay, _loadInterstitialAd);
        },
      ),
    );
  }

  void showInterstitialAd({required VoidCallback onAdDismissed}) {
    _wallpaperClickCount++;

    // Only show every N times (Frequency Capping)
    if (_wallpaperClickCount % AdConfig.interstitialFrequency != 0) {
      onAdDismissed();
      return;
    }

    if (_interstitialAd == null) {
      onAdDismissed();
      _loadInterstitialAd();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadInterstitialAd();
        onAdDismissed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _loadInterstitialAd();
        onAdDismissed();
      },
    );

    _interstitialAd!.show();
    _interstitialAd = null;
  }

  // --- Rewarded Ads ---

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: AdConfig.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _rewardedLoadAttempts = 0;
        },
        onAdFailedToLoad: (error) {
          _rewardedLoadAttempts++;
          _rewardedAd = null;

          // Exponential backoff
          final retryDelay = Duration(
            seconds: (1 << _rewardedLoadAttempts).clamp(2, 60),
          );
          Future.delayed(retryDelay, _loadRewardedAd);
        },
      ),
    );
  }

  void showRewardedAd({
    required Function onRewardEarned,
    VoidCallback? onAdShowed,
    VoidCallback? onAdDismissed,
  }) {
    if (_rewardedAd == null) {
      onAdShowed?.call();
      onRewardEarned();
      _loadRewardedAd();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadRewardedAd();
        onAdDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _loadRewardedAd();
        onRewardEarned(); // Let them have the reward if it failed to show
      },
    );

    onAdShowed?.call();
    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        onRewardEarned();
      },
    );
    _rewardedAd = null;
  }

  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdHelper {
  RewardedAd? _rewardedAd;
  int _numRewardedLoadAttempts = 0;
  static const int maxFailedLoadAttempts = 3;

  String get _adUnitId {
    if (Platform.isAndroid) {
      // Real Ad Unit ID for Android Rewarded Ad
      return 'ca-app-pub-5747718526576102/2513004612';
    } else if (Platform.isIOS) {
      // Test Ad Unit ID for iOS Rewarded Ad
      return 'ca-app-pub-3940256099942544/1712485313';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  void loadRewardedAd({VoidCallback? onLoaded, VoidCallback? onFailed}) {
    RewardedAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          debugPrint('$ad loaded.');
          _rewardedAd = ad;
          _numRewardedLoadAttempts = 0;
          onLoaded?.call();
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('RewardedAd failed to load: $error');
          _rewardedAd = null;
          _numRewardedLoadAttempts += 1;
          if (_numRewardedLoadAttempts < maxFailedLoadAttempts) {
            loadRewardedAd(onLoaded: onLoaded, onFailed: onFailed);
          } else {
            onFailed?.call();
          }
        },
      ),
    );
  }

  void showRewardedAd({
    required Function onRewardEarned,
    Function? onDismissed,
  }) {
    if (_rewardedAd == null) {
      debugPrint('Warning: attempt to show rewarded ad before loaded.');
      // If ad is not ready, we can either try to load it or just let the user proceed
      // For now, let's just proceed so user is not blocked
      onRewardEarned();
      loadRewardedAd(); // Load for next time
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) {
        debugPrint('ad onAdShowedFullScreenContent.');
      },
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        debugPrint('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        loadRewardedAd();
        if (onDismissed != null) onDismissed();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        loadRewardedAd();
        // Fallback: allow action if ad fails
        onRewardEarned();
      },
    );

    _rewardedAd!.setImmersiveMode(true);
    _rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        debugPrint(
          '$ad with reward $RewardItem(${reward.amount}, ${reward.type})',
        );
        onRewardEarned();
      },
    );
    _rewardedAd = null;
  }

  void dispose() {
    _rewardedAd?.dispose();
  }
}

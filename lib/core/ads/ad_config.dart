import 'dart:io';

class AdConfig {
  // Real AdMob Ad Unit IDs for production
  
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-9441953606119572/5196134317';
    } else if (Platform.isIOS) {
      // Test ID for iOS as no real one provided yet
      return 'ca-app-pub-3940256099942544/2934735716'; 
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-9441953606119572/5711139632';
    } else if (Platform.isIOS) {
      // Test ID for iOS
      return 'ca-app-pub-3940256099942544/4411468910';
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-9441953606119572/4398057966';
    } else if (Platform.isIOS) {
      // Test ID for iOS
      return 'ca-app-pub-3940256099942544/1712485313';
    }
    throw UnsupportedError('Unsupported platform');
  }

  // Frequency Capping: Show interstitial every N wallpaper views
  static const int interstitialFrequency = 5; 
}

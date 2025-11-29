import 'package:downvid/core/utils/app_constants.dart';

class AdManager {
  // production id
  // static String appIdProd = 'ca-app-pub-9521754657463723~6023697578';
  // static String bannerIdProd = 'ca-app-pub-9521754657463723/5025841483';
  // static String interstitialIdProd = 'ca-app-pub-9521754657463723/9771370894';
  // static String rewardIdProd = 'ca-app-pub-9521754657463723/6231111945';
  // static String nativeIdProd = 'ca-app-pub-9521754657463723/5720445243';

/// Test Ids
static String get appId => AppConstants.showTestAds
      ? 'ca-app-pub-3940256099942544~3347511713'
      // prod id
      : 'ca-app-pub-9521754657463723~6023697578'; // ← Tumhara real App ID

  static String get bannerIdAndroid => AppConstants.showTestAds
      ? 'ca-app-pub-3940256099942544/6300978111'
      // prod id
      : 'ca-app-pub-9521754657463723/5025841483';

  static String get interstitialIdAndroid => AppConstants.showTestAds
      ? 'ca-app-pub-3940256099942544/1033173712'
      // prod id
      : 'ca-app-pub-9521754657463723/9771370894';

  static String get rewardIdAndroid => AppConstants.showTestAds
      ? 'ca-app-pub-3940256099942544/5224354917'
      // prod id
      : 'ca-app-pub-9521754657463723/6231111945';

  static String get nativeIdAndroid => AppConstants.showTestAds
      ? 'ca-app-pub-3940256099942544/2247696110'
      // prod id
      : 'ca-app-pub-9521754657463723/5720445243';

  // // not shown anywhere
  // static String interstitialRewardedIdAndroid = (AppConstants.showTestAds)
  //     ? 'ca-app-pub-3940256099942544/5354046379'
  //     : rewardIdProd;

  // test id for iOS
  static String bannerIdiOS = 'ca-app-pub-3940256099942544/6300978111';
  static String interstitialIdiOS = 'ca-app-pub-3940256099942544/1033173712';
  static String interstitialRewardedIdiOS = 'ca-app-pub-3940256099942544/6978759866';
  static String rewardIdiOS = 'ca-app-pub-3940256099942544/5224354917';
  static String nativeIdiOS = 'ca-app-pub-3940256099942544/2247696110';
}

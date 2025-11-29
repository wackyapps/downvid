// lib/providers/ad_provider/ad_provider.dart
import 'dart:async';
import 'dart:io';
import 'package:downvid/core/utils/app_constants.dart';
import 'package:downvid/services/admob/admanager.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdProvider extends ChangeNotifier {
  RewardedAd? _rewardedAd;
  static const AdRequest request = AdRequest(nonPersonalizedAds: true);
  int _numRewardedLoadAttempts = 0;
  static int maxFailedLoadAttempts = 3;

  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;

  // Rewarded Ad
  bool _loadedRewardedAd = false;
  bool get loadedRewardedAd => _loadedRewardedAd;
  set loadedRewardedAd(bool value) {
    _loadedRewardedAd = value;
    debugPrint('REWARDED AD LOADED: $value');
    notifyListeners();
  }

  // Interstitial Ad
  bool _loadedInterstitialAd = false;
  bool get loadedInterstitialAd => _loadedInterstitialAd;
  set loadedInterstitialAd(bool value) {
    _loadedInterstitialAd = value;
    debugPrint('INTERSTITIAL AD LOADED: $value');
    notifyListeners();
  }

  Timer? _interstitialTimer;
  bool _isInterstitialAvailable = false;
  bool get isInterstitialAvailable => _isInterstitialAvailable;
  set isInterstitialAvailable(bool value) {
    _isInterstitialAvailable = value;
    debugPrint('INTERSTITIAL AD AVAILABLE: $value');
    notifyListeners();
  }

  int _counter = 0;

AdProvider() {
  debugPrint('AdProvider: Initializing...');
  _createInterstitialAd();
  _createRewardedAd();
  
  // Pehla interstitial ad turant available banao
  // Taaki app open karte hi ads dikh sake
  Future.delayed(Duration.zero, () {
    isInterstitialAvailable = true;
    debugPrint('FIRST INTERSTITIAL AD FORCE AVAILABLE FOR TESTING/EARLY SHOW');
  });
}

  String get rewardedAdUnitId => Platform.isAndroid
      ? AdManager.rewardIdAndroid
      : AdManager.rewardIdiOS;

  String get interstitialAdUnitId => Platform.isAndroid
      ? AdManager.interstitialIdAndroid
      : AdManager.interstitialIdiOS;

  // REWARDED AD
  void _createRewardedAd() {
    debugPrint('REWARDED AD: Loading... (Attempt: $_numRewardedLoadAttempts)');
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: request,
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('REWARDED AD: LOADED SUCCESSFULLY!');
          _rewardedAd = ad;
          _numRewardedLoadAttempts = 0;
          loadedRewardedAd = true;
        },
        onAdFailedToLoad: (error) {
          debugPrint('REWARDED AD: FAILED TO LOAD → $error');
          loadedRewardedAd = false;
          _numRewardedLoadAttempts++;
          if (_numRewardedLoadAttempts < maxFailedLoadAttempts) {
            Future.delayed(const Duration(seconds: 2), _createRewardedAd);
          }
        },
      ),
    );
  }

  // INTERSTITIAL AD
  void _createInterstitialAd() {
    debugPrint('INTERSTITIAL AD: Loading... (Attempt: $_numInterstitialLoadAttempts)');
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: request,
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('INTERSTITIAL AD: LOADED SUCCESSFULLY!');
          _interstitialAd = ad;
          _numInterstitialLoadAttempts = 0;
          _interstitialAd!.setImmersiveMode(true);
          loadedInterstitialAd = true;
          _startInterstitialTimer();
        },
        onAdFailedToLoad: (error) {
          debugPrint('INTERSTITIAL AD: FAILED TO LOAD → $error');
          loadedInterstitialAd = false;
          isInterstitialAvailable = false;
          _numInterstitialLoadAttempts++;
          if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
            Future.delayed(const Duration(seconds: 3), _createInterstitialAd);
          }
        },
      ),
    );
  }

  void _startInterstitialTimer() {
    _interstitialTimer?.cancel();
    _counter++;
    debugPrint('INTERSTITIAL TIMER: Started #$_counter (${AppConstants.interstitialAdShowingInterval}s)');
    _interstitialTimer = Timer(
      const Duration(seconds: AppConstants.interstitialAdShowingInterval),
      () {
        debugPrint('INTERSTITIAL TIMER: AD NOW AVAILABLE! #$_counter');
        isInterstitialAvailable = true;
      },
    );
  }

  void showInterstitialAd({
    required Function(InterstitialAd) onAdShowedFullScreen,
    required Function(InterstitialAd) onAdDismissedFullScreen,
    required Function(InterstitialAd, dynamic) onAdFailedToShowFullScreen,
  }) {
    if (_interstitialAd == null) {
      debugPrint('INTERSTITIAL AD: NOT LOADED — Cannot show');
      return;
    }
    if (!_isInterstitialAvailable) {
      debugPrint('INTERSTITIAL AD: NOT AVAILABLE YET — Timer running');
      return;
    }

    debugPrint('INTERSTITIAL AD: SHOWING NOW!');
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('INTERSTITIAL AD: DISPLAYED ON SCREEN');
        onAdShowedFullScreen(ad);
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('INTERSTITIAL AD: DISMISSED BY USER');
        ad.dispose();
        _createInterstitialAd();
        onAdDismissedFullScreen(ad);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('INTERSTITIAL AD: FAILED TO SHOW → $error');
        ad.dispose();
        _createInterstitialAd();
        onAdFailedToShowFullScreen(ad, error);
      },
    );

    _interstitialAd!.show();
    isInterstitialAvailable = false;
    _interstitialAd = null;
  }

  @override
  void dispose() {
    debugPrint('AdProvider: Disposing all ads...');
    _rewardedAd?.dispose();
    _interstitialAd?.dispose();
    // _rewardedAd.dispose();
    _interstitialTimer?.cancel();
    super.dispose();
  }
}
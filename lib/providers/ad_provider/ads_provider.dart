// lib/providers/ad_provider/ad_provider.dart
import 'dart:async';
import 'dart:io';
import 'package:downvid/core/utils/app_constants.dart';
import 'package:downvid/services/admob/admanager.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdProvider extends ChangeNotifier {
  RewardedAd? _rewardedAd;
  static const AdRequest request = AdRequest();
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

  NativeAd? _nativeAd;
  bool _nativeAdIsLoaded = false;
  bool get nativeAdIsLoaded => _nativeAdIsLoaded;

  AdProvider() {
    debugPrint('AdProvider: Initializing...');
    _requestConsentAndInitialize();
  }

  void _requestConsentAndInitialize() {
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () async {
        if (await ConsentInformation.instance.isConsentFormAvailable()) {
          _loadConsentForm();
        } else {
          _initializeAds();
        }
      },
      (FormError error) => _initializeAds(),
    );
  }

  void _loadConsentForm() {
    ConsentForm.loadConsentForm(
      (ConsentForm consentForm) async {
        var status = await ConsentInformation.instance.getConsentStatus();
        if (status == ConsentStatus.required) {
          consentForm.show((FormError? formError) => _initializeAds());
        } else {
          _initializeAds();
        }
      },
      (FormError formError) => _initializeAds(),
    );
  }

  void _initializeAds() {
    MobileAds.instance.initialize().then((status) {
      debugPrint('📱 MobileAds initialized: ${status.adapterStatuses}');
      Future.delayed(Duration.zero, () {
        isInterstitialAvailable = true;
        debugPrint('FIRST INTERSTITIAL AD FORCE AVAILABLE FOR TESTING/EARLY SHOW');
      });
    });
  }

 void loadAdsOnFirstUse() {
    // Load only ONE ad type initially, stagger the rest
    if (!_loadedInterstitialAd) {
      _createInterstitialAd();
    }
    
    // Delay rewarded and native ads
    Future.delayed(const Duration(seconds: 3), () {
      if (!_loadedRewardedAd) {
        _createRewardedAd();
      }
    });
    
    // Future.delayed(const Duration(seconds: 5), () {
    //   if (!_nativeAdIsLoaded) {
    //     // _loadNativeAd();
    //   }
    // });
  }

  String get rewardedAdUnitId =>
      Platform.isAndroid ? AdManager.rewardIdAndroid : AdManager.rewardIdiOS;

  String get interstitialAdUnitId => Platform.isAndroid
      ? AdManager.interstitialIdAndroid
      : AdManager.interstitialIdiOS;

  String get nativeAdUnitId =>
      Platform.isAndroid ? AdManager.nativeIdAndroid : AdManager.nativeIdiOS;

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
    debugPrint(
      'INTERSTITIAL AD: Loading... (Attempt: $_numInterstitialLoadAttempts)',
    );
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
    debugPrint(
      'INTERSTITIAL TIMER: Started #$_counter (${AppConstants.interstitialAdShowingInterval}s)',
    );
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

  void _loadNativeAd() {
    debugPrint('Native Ad: Loading...');

    _nativeAd = NativeAd(
      adUnitId: nativeAdUnitId,
      factoryId:
          'listTile', // TODO: Replace with your own factory ID (from AdMob registration)
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          debugPrint('Native Ad loaded successfully!');
          _nativeAdIsLoaded = true;
          notifyListeners();
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Native Ad failed to load: $error');
          ad.dispose();
          _nativeAdIsLoaded = false;
          notifyListeners();
        },
      ),
      request: const AdRequest(),
      customOptions: {'custom-option-1': 'custom-value-1'}, // Optional
    );

    _nativeAd!.load();
  }

  // Getter for loaded native ad (use in widgets)
  NativeAd? get nativeAd => _nativeAdIsLoaded ? _nativeAd : null;

  void loadNativeAd() {
  if (_nativeAdIsLoaded) return; // Avoid duplicate load

  _nativeAd = NativeAd(
    adUnitId: nativeAdUnitId,
    factoryId: 'listTile',
    listener: NativeAdListener(
      onAdLoaded: (ad) {
        _nativeAdIsLoaded = true;
        notifyListeners();
      },
      onAdFailedToLoad: (ad, error) {
        ad.dispose();
        _nativeAdIsLoaded = false;
        notifyListeners();
      },
    ),
    request: const AdRequest(),
  )..load();
}

  @override
  void dispose() {
    debugPrint('AdProvider: Disposing all ads...');
    _rewardedAd?.dispose();
    _interstitialAd?.dispose();
    _nativeAd?.dispose();
    _interstitialTimer?.cancel();
    super.dispose();
  }
}

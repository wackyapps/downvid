import 'package:downvid/providers/ad_provider/ads_provider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:downvid/models/video_meta_model/video_model.dart';
import 'package:downvid/services/fdown_service/fbdown_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Fetching metadata states
enum FetchingState { idle, fetching, fetched, errorFetching }

// Downloadingt states
enum DownloadingState { idle, downloading, completed, errorDownloading }

class HomeAndDownloadProvider extends ChangeNotifier {
  final FbDownService _downloadService = GetIt.I<FbDownService>();
  String _url = '';
  VideoMetaDataModel? videoMetaDataModel;
  FetchingState fetchingState = FetchingState.idle;
  double downloadProgress = 0.0;
  String? errorMessage;
  bool _isDownloading = false;
  bool get isDownloading => _isDownloading;

  void startDownload() {
    _isDownloading = true;
    downloadProgress = 0.0;
    notifyListeners();
  }

  void finishDownload() {
    _isDownloading = false;
    downloadProgress = 1.0;
    notifyListeners();
  }

  String get url => _url;
  set url(String value) {
    _url = value;
    notifyListeners();
  }

  int _selectedLinkIndex = 0;
  int get selectedLinkIndex => _selectedLinkIndex;
  set selectedLinkIndex(int value) {
    _selectedLinkIndex = value;
    notifyListeners();
  }

  /// Fetch metadata for a provided URL.
  Future<VideoMetaDataModel?> fetchVideoMetaData({
    required BuildContext context,
    required String url,
  }) async {
    fetchingState = FetchingState.fetching;
    errorMessage = null;
    notifyListeners();

    try {
      // Ensure the webview is on home page
      // _downloadService.ensureWebViewOnHomePage(context);
      // Call the FbDownService and pass the real context.
      final meta = await _downloadService.fetchVideoMetaData(url, context);

      if (meta != null) {
        videoMetaDataModel = meta;
        fetchingState = FetchingState.fetched;
      } else {
        fetchingState = FetchingState.errorFetching;
        errorMessage = 'Failed to fetch video metadata';
      }
    } catch (e) {
      fetchingState = FetchingState.errorFetching;
      errorMessage = 'Error: $e';
      Fluttertoast.showToast(msg: errorMessage!);
    }

    notifyListeners();
    return videoMetaDataModel;
  }

  // Future<void> downloadVideo({
  //   required String userUrl,
  //   required int selectedLinkIndex,
  //   required BuildContext context, // ← ADD CONTEXT HERE
  // }) async {
  //   if (videoMetaDataModel == null) return;

  //   await _downloadService.downloadVideo(
  //     meta: videoMetaDataModel!,
  //     selectedLinkIndex: selectedLinkIndex,
  //     userUrl: userUrl,
  //     onProgress: (progress) {
  //       downloadProgress = progress;
  //       notifyListeners();
  //     },
  //     onComplete: (filePath) async {
  //       downloadProgress = 1.0;
  //       notifyListeners();

  //       // SUCCESS → SHOW INTERSTITIAL AFTER EVERY 3RD DOWNLOAD
  //       final prefs = await SharedPreferences.getInstance();
  //       int totalDownloads = (prefs.getInt('total_downloads') ?? 0) + 1;
  //       await prefs.setInt('total_downloads', totalDownloads);

  //       if (totalDownloads % 3 == 0) {
  //         final adProvider = Provider.of<AdProvider>(context, listen: false);
  //         adProvider.showInterstitialAd(
  //           onAdShowedFullScreen: (ad) {},
  //           onAdDismissedFullScreen: (ad) {},
  //           onAdFailedToShowFullScreen: (ad, error) {},
  //         );
  //       }
  //     },
  //     onError: (error) {
  //       errorMessage = error;
  //       Fluttertoast.showToast(msg: 'Download failed: $error');
  //       notifyListeners();
  //     },
  //   );
  // }

  Future<void> downloadVideo({
    required String userUrl,
    required int selectedLinkIndex,
    required BuildContext context,
  }) async {
    if (videoMetaDataModel == null || isDownloading) return;

    startDownload(); // ← Start flag

    await _downloadService.downloadVideo(
      meta: videoMetaDataModel!,
      selectedLinkIndex: selectedLinkIndex,
      userUrl: userUrl,
      onProgress: (progress) {
        downloadProgress = progress;
        notifyListeners();
      },
      onComplete: (filePath) async {
        finishDownload();
        // Show success toast
        Fluttertoast.showToast(
          msg: "Download completed!",
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        // Show ad logic...
        final prefs = await SharedPreferences.getInstance();
        int totalDownloads = (prefs.getInt('total_downloads') ?? 0) + 1;
        await prefs.setInt('total_downloads', totalDownloads);
        if (totalDownloads % 3 == 0) {
          final adProvider = Provider.of<AdProvider>(context, listen: false);
          if (adProvider.isInterstitialAvailable) {
            adProvider.showInterstitialAd(
              onAdShowedFullScreen: (_) {},
              onAdDismissedFullScreen: (_) {},
              onAdFailedToShowFullScreen: (_, error) {},
            );
          }
        }
      },
      onError: (error) {
        finishDownload();
        Fluttertoast.showToast(msg: 'Download failed: $error');
      },
    );
  }

  void reset() {
    _url = '';
    videoMetaDataModel = null;
    fetchingState = FetchingState.idle;
    downloadProgress = 0.0;
    errorMessage = null;
    notifyListeners();
  }
}

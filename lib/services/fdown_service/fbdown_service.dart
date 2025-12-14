// lib/services/fdown_service/fbdown_service.dart
import 'dart:convert';
import 'dart:io' show Directory, File;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:downvid/models/video_meta_model/video_model.dart';
import 'package:downvid/models/video_downloaded_model/video_downloaded_model.dart';
import 'package:downvid/services/object_box/object_box_service.dart';
import 'package:downvid/service_locator.dart';

/// FbDownService
/// - Responsible for scraping fdown.net results via an embedded WebViewController
/// - After a successful scrape it will update HomeAndDownloadProvider and open the bottom sheet
class FbDownService {
  WebViewController? _controller;

  /// Toggle to show WebView overlay (for debugging)
  static const bool showWebView = true;

  /// Initialize a WebViewController with sensible settings
  Future initWebView() async {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
          'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36')
      ..setBackgroundColor(const Color(0x00000000))
      ..enableZoom(true)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) => debugPrint('WebView START → $url'),
          onPageFinished: (url) => debugPrint('WebView FINISH → $url'),
          onWebResourceError: (e) => debugPrint(
              'WebView ERROR: ${e.description} (code ${e.errorCode})'),
        ),
      );

    await _controller?.loadRequest(Uri.parse('https://fdown.net/'));
  }

  Future<void> goHome() async {
    try {
      // If controller not initialized, initialize it
      if (_controller == null) {
        debugPrint(
            'FbDownService.goHome → Controller is null. Initializing WebView...');
        await initWebView();
      }

      // Navigate back to homepage
      await _controller!.loadRequest(Uri.parse('https://fdown.net/'));
      debugPrint('FbDownService.goHome → Navigated to fdown.net homepage');
    } catch (e, st) {
      debugPrint('FbDownService.goHome ERROR → $e\n$st');
    }
  }

  Future<VideoMetaDataModel?> fetchVideoMetaData(
      String userUrl, BuildContext context) async {
    if (userUrl.isEmpty) return null;

    try {
      // Wait for the form to appear
      await _waitForForm();

      // Fill input and submit
      await _fillAndSubmit(userUrl);

      // Try to scrape repeatedly from the same page (some layouts render dynamically)
      VideoMetaDataModel? meta;
      const attempts = 8;
      const delayMs = 900;

      for (int i = 0; i < attempts; i++) {
        meta = await _scrapeDownloadPage();
        if (meta != null && meta.videoLinks.isNotEmpty) break;
        await Future.delayed(const Duration(milliseconds: delayMs));
      }

      // Fallback: if nothing found, wait for navigation to download.php (legacy)
      if (meta == null || meta.videoLinks.isEmpty) {
        try {
          final resultPage = await _waitForResultPage(maxAttempts: 20);
          if (resultPage.contains('error=')) {
            Fluttertoast.showToast(
                msg: 'This video is private or not supported.');
            return null;
          }
          meta = await _scrapeDownloadPage();
        } catch (e) {
          debugPrint('FbDownService error waiting for result page: $e');
          Fluttertoast.showToast(msg: 'Failed to process URL');
          return null;
        }
      }

      // If still nothing => no downloadable video
      if (meta == null || meta.videoLinks.isEmpty) {
        Fluttertoast.showToast(msg: 'No downloadable video found.');
        return null;
      }

      // ✅ Log successful metadata
      debugPrint(
          '[FbDownService] ✅ Metadata fetched successfully for URL: $userUrl');

      // ✅ Reset WebView back to home immediately
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          await goHome();
          debugPrint(
              '[FbDownService] 🌐 WebView reset to home page successfully.');
        } catch (e, st) {
          debugPrint('[FbDownService] ⚠️ Failed to reset WebView: $e\n$st');
        }
      });

      // ✅ Return meta to provider (which handles UI updates + bottom sheet)
      return meta;
    } catch (e, st) {
      debugPrint('FbDownService error: $e\n$st');
      Fluttertoast.showToast(msg: 'Failed to process URL');
      return null;
    }
  }

  Future<void> _waitForForm({int maxAttempts = 20}) async {
    for (int i = 0; i < maxAttempts; i++) {
      final ok = await _controller!.runJavaScriptReturningResult('''
        (function(){
          return !!document.querySelector('input[name="URLz"]') &&
                 !!document.querySelector('.btn.btn-primary.input-lg');
        })();
      ''');
      if (ok == true) return;
      await Future.delayed(const Duration(milliseconds: 400));
    }
    throw Exception('Form not found on fdown.net');
  }

  Future<void> _fillAndSubmit(String url) async {
    // debugger();

    final js = '''
      (function(){
        const inp = document.querySelector('input[name="URLz"]');
        const btn = document.querySelector('.btn.btn-primary.input-lg');
        if (!inp || !btn) return false;
        inp.value = decodeURIComponent("${Uri.encodeComponent(url)}");
        btn.click();
        return true;
      })();
    ''';
    final ok = await _controller!.runJavaScriptReturningResult(js);
    if (ok != true) throw Exception('Submit failed');
  }

  Future<String> _waitForResultPage({int maxAttempts = 40}) async {
    for (int i = 0; i < maxAttempts; i++) {


      // check during debug
      final url = (await _controller!.currentUrl()) ?? '';



      if (url.contains('download.php') || url.contains('error=')) {
        return url;
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }
    throw Exception('Did not reach download.php or error page');
  }

Future<VideoMetaDataModel?> _scrapeDownloadPage() async {
  // debugger();

  try {
    final raw = await _controller!.runJavaScriptReturningResult('''
      (function(){
        const title = document.querySelector('meta[property="og:title"]')?.content ||
                      document.querySelector('title')?.innerText || 'Untitled Video';

        let thumb = document.querySelector('meta[property="og:image"]')?.content || '';
        if (!thumb) {
          const img = document.querySelector('img.lib-img-show');
          if (img && img.src) thumb = img.src;
        }

        let duration = '';
        const descEls = document.querySelectorAll('.lib-row.lib-desc');
        for (const el of descEls) {
          const txt = el.textContent.trim();
          if (/Duration/i.test(txt)) {
            duration = txt.replace(/.*Duration[:\\s]*/i, '').trim();
            break;
          }
        }

        const links = [];
        const anchors = document.querySelectorAll('a');
        for (let a of anchors) {
          const txt = (a.textContent || '').toLowerCase();
          const href = a.href || '';
          if (txt.includes('download') && href.includes('.mp4')) {
            const quality = txt.includes('hd') ? 'HD' : 'SD';
            links.push({href, quality});
          }
        }

        return JSON.stringify({title, thumb, duration, links});
      })();
    ''');

    // Parse JSON string
    String jsonString = raw.toString();
    if (jsonString.startsWith('"') && jsonString.endsWith('"')) {
      jsonString = jsonString.substring(1, jsonString.length - 1);
    }
    jsonString = jsonString.replaceAll(r'\"', '"').replaceAll(r'\\', r'\\');

    final Map<String, dynamic> data = jsonDecode(jsonString);
    final List<dynamic> linkList = data['links'] ?? [];

    // Convert to VideoLinkModel
    final videoLinks = linkList
        .map((e) => VideoLinkModel(
              link: (e['href'] ?? '') as String,
              quality: (e['quality'] ?? 'SD') as String,
              type: 'mp4',
            ))
        .where((link) => link.link.isNotEmpty)
        .toList();

    // Return properly initialized model — no late, no double assignment
    return VideoMetaDataModel(
      title: data['title'] ?? 'Untitled Video',
      description: '',
      duration: data['duration'] ?? 'Unknown',
      thumbnail: data['thumb'] ?? '',
      videoLinks: videoLinks,
      hasScrappingError: videoLinks.isEmpty, // ← Only set here, never again
    );

  } catch (e, st) {
    debugPrint('❌ Error scraping download page: $e\n$st');
    return null;
  }
}

Future<void> downloadVideo({
  required VideoMetaDataModel meta,
  required int selectedLinkIndex,
  required String userUrl,
  required Function(double) onProgress,
  required Function(String) onComplete,
  required Function(String) onError,
}) async {
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(minutes: 30),
    sendTimeout: const Duration(seconds: 30),
    followRedirects: true,
    maxRedirects: 10,
    persistentConnection: true,
    receiveDataWhenStatusError: true,
  
  ));

  try {
    final link = meta.videoLinks[selectedLinkIndex];
    final safeTitle = (meta.title ?? "Video")
        .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')
        .trim();
    final fileName = '${safeTitle}_${DateTime.now().millisecondsSinceEpoch}.mp4';

    // REQUEST ALL FILES ACCESS (this is the ONLY thing that works on Android 13+)
    if (await Permission.videos.isDenied) {
      final status = await Permission.videos.request();
      if (!status.isGranted) {
        Fluttertoast.showToast(
          msg: "Media Storage permission required",
          backgroundColor: Colors.red.shade700,
        );
        onError("Permission denied");
        return;
      }
    }

    // Create folder
    final dir = Directory('/storage/emulated/0/Download/DownVid');
    if (!await dir.exists()) await dir.create(recursive: true);

    final filePath = '${dir.path}/$fileName';

    debugPrint("Downloading to: $filePath");

    // Direct download
DateTime? lastUpdateTime;
    double lastReportedProgress = 0.0;

    await dio.download(
      link.link,
      filePath,
      onReceiveProgress: (received, total) {
        if (total <= 0) return;

        final double progress = received / total;
        final DateTime now = DateTime.now();

        // Update only if:
        // - At least 1% progress changed OR
        // - 500ms passed since last update
        final bool progressChangedEnough = (progress - lastReportedProgress).abs() >= 0.01;
        final bool timePassed = lastUpdateTime == null || now.difference(lastUpdateTime!).inMilliseconds >= 500;

        if (progressChangedEnough || timePassed) {
          onProgress(progress);
          lastReportedProgress = progress;
          lastUpdateTime = now;
        }
      },
      options: Options(
        headers: {
          'User-Agent': 'Mozilla/5.0 (Linux; Android 14; Pixel 9 Pro Build/AP2A.241205.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/131.0.6738.108 Mobile Safari/537.36',
          'Referer': 'https://fdown.net/',
          'Origin': 'https://fdown.net',
          'Accept': '*/*',
          'Connection': 'keep-alive',
        },
      ),
    );

    final file = File(filePath);
    if (!await file.exists()) {
      onError("File not saved");
      return;
    }

    final sizeMB = (await file.length()) / (1024 * 1024);

    // Save to ObjectBox
    getIt<ObjectBox>().store.box<VideoDownloadedModel>().put(VideoDownloadedModel(
      title: meta.title ?? "Untitled Video",
      thumbnail: meta.thumbnail ?? "",
      videoSocialUrl: link.link,
      videoPath: filePath,
      videoType: "mp4",
      videoQuality: link.quality,
      videoFileSize: "${sizeMB.toStringAsFixed(2)} MB",
      videoDuration: meta.duration ?? "Unknown",
      videoDownloadedDate: DateTime.now(),
      originalUrl: userUrl,
    ));

    Fluttertoast.showToast(
      msg: "Saved → Downloads",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green.shade600,
      textColor: Colors.white,
      fontSize: 16.0,
    );

    onComplete(filePath);

  } catch (e, st) {
    debugPrint("Download error: $e\n$st");
    Fluttertoast.showToast(msg: "Download failed");
    onError(e.toString());
  }
}

  // -----------------------------
  // Optional debug WebView widget
  // -----------------------------
  Widget? get debugWebView {
    if (!showWebView || _controller == null) return null;
    return SizedBox(
        height: 90.h, child: WebViewWidget(controller: _controller!));
  }
}
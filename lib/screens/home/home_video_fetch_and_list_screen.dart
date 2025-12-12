import 'package:downvid/core/utils/helper.dart';
import 'package:downvid/services/admob/native_ad_widget.dart';
import 'package:listen_sharing_intent/listen_sharing_intent.dart';
import 'package:downvid/providers/home_download_provider/home_download_provider.dart';
import 'package:downvid/screens/home/video_download_meta_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomeVideoFetchAndListScreen extends StatefulWidget {
  const HomeVideoFetchAndListScreen({super.key});

  @override
  State<HomeVideoFetchAndListScreen> createState() =>
      _HomeVideoFetchAndListScreenState();
}

class _HomeVideoFetchAndListScreenState
    extends State<HomeVideoFetchAndListScreen>
    with WidgetsBindingObserver {
  // 👈 Add observer mixin

  late HomeAndDownloadProvider _homeAndDownloadProvider;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 👇 Delay to ensure context is available

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _homeAndDownloadProvider = Provider.of<HomeAndDownloadProvider>(
        context,
        listen: false,
      );
      // _controller.text = "https://www.facebook.com/share/r/17baJM8urB/";
      _checkClipboardForFacebookUrl();
      _initShareListener(); // 👈 updated
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 👇 Detect when app comes to foreground
    if (state == AppLifecycleState.resumed) {
      _checkClipboardForFacebookUrl();
    }
  }

  void _initShareListener() {
    // 🔄 Listen for new shared content while app is in memory
    ReceiveSharingIntent.instance.getMediaStream().listen(
      (List<SharedMediaFile> sharedFiles) {
        if (sharedFiles.isNotEmpty) {
          for (var file in sharedFiles) {
            if (file.type == SharedMediaType.text && file.path.isNotEmpty) {
              _handleSharedUrl(file.path);
              break;
            }
          }
        }
      },
      onError: (err) {
        debugPrint("Error in getMediaStream: $err");
      },
    );

    // 🧩 Handle content shared when app was launched from closed state
    ReceiveSharingIntent.instance
        .getInitialMedia()
        .then((List<SharedMediaFile> sharedFiles) {
          if (sharedFiles.isNotEmpty) {
            for (var file in sharedFiles) {
              if (file.type == SharedMediaType.text && file.path.isNotEmpty) {
                _handleSharedUrl(file.path);
                break;
              }
            }
          }
        })
        .catchError((err) {
          debugPrint("Error in getInitialMedia: $err");
        });
  }

  // Future<void> _handleSharedUrl(String sharedText) async {
  //   // ← YEHI LINE ADD KAR DO — extra spaces aur empty parts hata do
  //   final cleanText = sharedText.trim().replaceAll(RegExp(r'\s+'), ' ');

  //   if (!SocialUrlUtilities.isValidVideoUrl(cleanText)) {
  //     debugPrint("Invalid URL received via share: $cleanText");
  //     return;
  //   }

  //   final parsedUrl = SocialUrlUtilities.getFacebookUrl(cleanText);
  //   _homeAndDownloadProvider.url = parsedUrl;
  //   _controller.text = cleanText;

  //   _showLoadingDialog(context);

  //   try {
  //     final videoModel = await _homeAndDownloadProvider.fetchVideoMetaData(
  //       context: context,
  //       url: parsedUrl,
  //     );

  //     _dismissLoadingDialog();

  //     if (videoModel != null && videoModel.videoLinks.isNotEmpty) {
  //       bottomVideoMetaBottomSheet(
  //         context: context,
  //         sheetHeight: 70.0.h,
  //         userUrl: cleanText,
  //       );
  //     } else {
  //       Fluttertoast.showToast(msg: 'No downloadable video found');
  //     }
  //   } catch (e) {
  //     _dismissLoadingDialog();
  //     Fluttertoast.showToast(msg: 'Error: $e');
  //   }
  // }

  Future<void> _handleSharedUrl(String sharedText) async {
    // final cleanUrl = sharedText
    //     .replaceAll('\u2028', '')
    //     .replaceAll('\r', '')
    //     .replaceAll('\n', '')
    //     .trim();

    // debugPrint("RAW LENGTH: ${sharedText.length}");
    // debugPrint("CLEAN LENGTH: ${cleanUrl.length}");
    // debugPrint("CLEAN URL: $cleanUrl");

    // if (!SocialUrlUtilities.isValidVideoUrl(cleanUrl)) {
    //   debugPrint("Invalid URL after cleaning");
    //   return;
    // }

    /**
   * Yahan par humne URL ko clean kar diya hai aur phir use parse karke
   * HomeAndDownloadProvider mein set kar diya hai. Baad mein hum video metadata
   */

    // final parsedUrl = SocialUrlUtilities.getFacebookUrl(cleanUrl);
    // final parsedUrl = sharedText; // Yahan par aap apna URL parsing logic laga sakte hain

    // _controller.text = cleanUrl;
    _controller.text = sharedText;
    // _homeAndDownloadProvider.url = parsedUrl;
    _homeAndDownloadProvider.url = sharedText;

    _showLoadingDialog(context);

    try {
      final videoModel = await _homeAndDownloadProvider.fetchVideoMetaData(
        context: context,
        url: sharedText,
      );

      _dismissLoadingDialog();

      if (videoModel != null && videoModel.videoLinks.isNotEmpty) {
        bottomVideoMetaBottomSheet(
          context: context,
          sheetHeight: 70.0.h,
          userUrl: sharedText,
        );
      } else {
        Fluttertoast.showToast(msg: 'No downloadable video found');
      }
    } catch (e) {
      _dismissLoadingDialog();
      Fluttertoast.showToast(msg: 'Error: $e');
    }
  }

  /// ✅ Automatically checks clipboard and pastes Facebook URLs
  Future<void> _checkClipboardForFacebookUrl() async {
    try {
      final clipboardData = await Clipboard.getData('text/plain');
      final clipboardText = clipboardData?.text?.trim() ?? '';

      if (clipboardText.isEmpty) return;

      // Simple Facebook URL detection
      final regex = RegExp(
        r'(https?:\/\/(?:www\.)?(?:facebook|fb)\.com\/[^\s]+)',
        caseSensitive: false,
      );

      final match = regex.firstMatch(clipboardText);
      if (match != null) {
        final fbUrl = match.group(0)!;

        // Only auto-paste if TextField is empty
        if (_controller.text.isEmpty) {
          _controller.text = fbUrl;
          _homeAndDownloadProvider.url = SocialUrlUtilities.getFacebookUrl(
            fbUrl,
          );
          setState(() {});
          Fluttertoast.showToast(
            msg: 'Facebook link pasted automatically',
            toastLength: Toast.LENGTH_SHORT,
          );
        }
      }
    } catch (e) {
      debugPrint('Clipboard check failed: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // 👈 Remove observer
    super.dispose();
  }

  // 🧩 rest of your code remains exactly the same...

  // 🌀 Simple reusable loader dialog
  void _showLoadingDialog(
    BuildContext context, {
    String message = "Fetching video data.\nPlease wait...",
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (_) => Center(
        child: Container(
          width: 60.w,
          padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 3.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                strokeWidth: 3,
                color: Color(0xFF3B82F6),
              ),
              SizedBox(height: 2.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _dismissLoadingDialog() {
    if (Navigator.canPop(context)) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === Paste Field + Buttons ===
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _controller,
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          _homeAndDownloadProvider.url =
                              SocialUrlUtilities.getFacebookUrl(value);
                        }
                        setState(() {});
                      },
                      cursorColor: Colors.black,
                      style: const TextStyle(fontSize: 15),
                      decoration: const InputDecoration(
                        hintText: 'Paste link to download',
                        hintStyle: TextStyle(color: Colors.black45),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.5.h),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Paste Button
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final clipboardData = await Clipboard.getData(
                        'text/plain',
                      );
                      if (clipboardData != null &&
                          clipboardData.text!.isNotEmpty) {
                        _controller.text = clipboardData.text!;
                        _homeAndDownloadProvider.url =
                            SocialUrlUtilities.getFacebookUrl(
                              clipboardData.text!,
                            );
                        setState(() {});
                      } else {
                        Fluttertoast.showToast(
                          msg: 'No link found in clipboard',
                        );
                      }
                    },
                    child: Container(
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9E7FC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Paste Link',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                // Download Button
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final url = _controller.text.trim();
                      if (url.isEmpty) {
                        Fluttertoast.showToast(msg: 'Please enter a video URL');
                        return;
                      }
                      _showLoadingDialog(context);
                      try {
                        final videoModel = await _homeAndDownloadProvider
                            .fetchVideoMetaData(context: context, url: url);
                        _dismissLoadingDialog();
                        if (videoModel != null &&
                            (!videoModel.hasScrappingError)) {
                          bottomVideoMetaBottomSheet(
                            context: context,
                            sheetHeight: 70.0.h,
                            userUrl: _controller.text.trim(),
                          );
                        } else {
                          Fluttertoast.showToast(
                            msg: 'Failed to fetch video metadata',
                          );
                        }
                      } catch (e) {
                        _dismissLoadingDialog();
                        Fluttertoast.showToast(
                          msg: 'Error fetching metadata: $e',
                        );
                      }
                    },
                    child: Container(
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Download',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 4.h), // Space before ad
            // BANNER AD HERE — PERFECT POSITION
            const Center(child: NativeAdWidget()),

            // SizedBox(height: 38.h),

            // "How to Download" Section
            const Divider(height: 12, endIndent: 50.0, indent: 50.0),
            const Text(
              "How to Download",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 1.h),

            _buildStep(1, "Open Facebook and Copy link video"),
            _buildStep(
              2,
              "Open “DownVid” and Press Paste to Paste the link of the video",
            ),
            _buildStep(
              3,
              "Press Download and Choose the quality of the video you want to download",
            ),
            _buildStep(4, "Done! The download will start automatically."),
            // SizedBox(height: 5.h), // Extra bottom space
          ],
        ),
      ),
    );
  }

  /// ✅ Helper Widget for Steps
  Widget _buildStep(int number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF3B82F6), width: 2),
            ),
            child: Text(
              number.toString(),
              style: const TextStyle(
                color: Color(0xFF3B82F6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14.5,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

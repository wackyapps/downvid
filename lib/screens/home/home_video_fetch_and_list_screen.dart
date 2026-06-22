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
  late HomeAndDownloadProvider _homeAndDownloadProvider;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _homeAndDownloadProvider = Provider.of<HomeAndDownloadProvider>(
        context,
        listen: false,
      );
      _checkClipboardForFacebookUrl();
      _initShareListener();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkClipboardForFacebookUrl();
    }
  }

  void _initShareListener() {
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

  Future<void> _handleSharedUrl(String sharedText) async {
    _controller.text = sharedText;
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

  Future<void> _checkClipboardForFacebookUrl() async {
    try {
      final clipboardData = await Clipboard.getData('text/plain');
      final clipboardText = clipboardData?.text?.trim() ?? '';

      if (clipboardText.isEmpty) return;

      final regex = RegExp(
        r'(https?:\/\/(?:www\.)?(?:facebook|fb)\.com\/[^\s]+)',
        caseSensitive: false,
      );

      final match = regex.firstMatch(clipboardText);
      if (match != null) {
        final fbUrl = match.group(0)!;

        if (_controller.text.isEmpty) {
          _controller.text = fbUrl;
          _homeAndDownloadProvider.url = SocialUrlUtilities.getFacebookUrl(fbUrl);
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
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _showLoadingDialog(BuildContext context, {String message = "Fetching video data.\nPlease wait..."}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (_) => Center(
        child: Container(
          width: 70.w,
          padding: EdgeInsets.symmetric(vertical: 3.5.h, horizontal: 4.w),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(strokeWidth: 4, color: Color(0xFF2563EB)),
              SizedBox(height: 3.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.none,
                ),
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

  // NEW: Dynamic Button Logic
  void _onDynamicButtonPressed() async {
    final url = _controller.text.trim();

    if (url.isEmpty) {
      // Paste Action
      final clipboardData = await Clipboard.getData('text/plain');
      if (clipboardData != null && clipboardData.text!.trim().isNotEmpty) {
        _controller.text = clipboardData.text!.trim();
        _homeAndDownloadProvider.url = SocialUrlUtilities.getFacebookUrl(clipboardData.text!);
        setState(() {});
      } else {
        Fluttertoast.showToast(msg: 'No link found in clipboard');
      }
    } else {
      // Download Action
      _showLoadingDialog(context);
      try {
        final videoModel = await _homeAndDownloadProvider.fetchVideoMetaData(
          context: context,
          url: url,
        );
        _dismissLoadingDialog();
        if (videoModel != null && !videoModel.hasScrappingError) {
          bottomVideoMetaBottomSheet(
            context: context,
            sheetHeight: 70.0.h,
            userUrl: url,
          );
        } else {
          Fluttertoast.showToast(msg: 'Failed to fetch video metadata');
        }
      } catch (e) {
        _dismissLoadingDialog();
        Fluttertoast.showToast(msg: 'Error fetching metadata: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasUrl = _controller.text.trim().isNotEmpty;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFF3B82F6) : const Color(0xFF2563EB);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === Paste Field ===
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Icon(Icons.link_rounded, color: Colors.grey, size: 24),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          _homeAndDownloadProvider.url = SocialUrlUtilities.getFacebookUrl(value);
                        }
                        setState(() {}); // Trigger button update
                      },
                      cursorColor: primaryColor,
                      style: TextStyle(
                        fontSize: 15,
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Paste link to download...',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.white30 : Colors.black38,
                          fontWeight: FontWeight.w400,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  if (hasUrl)
                    IconButton(
                      icon: const Icon(Icons.clear_rounded, color: Colors.grey),
                      onPressed: () {
                        _controller.clear();
                        _homeAndDownloadProvider.url = "";
                        setState(() {});
                      },
                    ),
                ],
              ),
            ),
            SizedBox(height: 2.h),

            // === DYNAMIC SINGLE BUTTON ===
            SizedBox(
              width: double.infinity,
              height: 6.5.h,
              child: GestureDetector(
                onTap: _onDynamicButtonPressed,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: hasUrl
                        ? LinearGradient(
                            colors: isDark
                                ? [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)]
                                : [const Color(0xFF2563EB), const Color(0xFF3B82F6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: hasUrl
                        ? null
                        : (isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF)),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: hasUrl
                        ? [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Text(
                    hasUrl ? 'Download' : 'Paste Link',
                    style: TextStyle(
                      color: hasUrl ? Colors.white : primaryColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 12.h),

            // "How to Download" Container Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.03),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.help_outline_rounded,
                          color: primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "How to Download",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : Colors.black87,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(color: isDark ? Colors.white10 : Colors.black12, height: 1),
                  const SizedBox(height: 12),

                  _buildStep(context, 1, "Open Facebook and copy the link of the video of your choice."),
                  _buildStep(context, 2, "Open DownVid. The link will be automatically pasted, or you can paste it manually."),
                  _buildStep(context, 3, "Press Download and choose the quality you want."),
                  _buildStep(context, 4, "You're done! The download will start automatically."),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context, int number, String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFF3B82F6) : const Color(0xFF2563EB);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Text(
              number.toString(),
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
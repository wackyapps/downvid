// DownloadedListScreen.dart
import 'package:downvid/providers/ad_provider/ads_provider.dart';
import 'package:downvid/providers/downloaded_video_list_provider/downloaded_video_list_provider.dart';
import 'package:downvid/screens/downloaded/widgets/video_list_item_widget.dart';
import 'package:downvid/service_locator.dart';
import 'package:downvid/services/admob/native_ad_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class DownloadedListScreen extends StatefulWidget {
  final bool fromDrawer;
  const DownloadedListScreen({super.key, this.fromDrawer = false});

  @override
  State<DownloadedListScreen> createState() => _DownloadedListScreenState();
}

class _DownloadedListScreenState extends State<DownloadedListScreen> {
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getIt<DownloadedVideoListProvider>().loadDownloadedVideos(forceRefresh: true);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoaded) {
      _hasLoaded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Provider.of<DownloadedVideoListProvider>(
            context,
            listen: false,
          ).loadDownloadedVideos();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.fromDrawer
          ? PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: Theme.of(context).brightness == Brightness.dark
                          ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                          : [const Color(0xFF2563EB), const Color(0xFF3B82F6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 26),
                  onPressed: () async {
                    final adProvider = Provider.of<AdProvider>(
                      context,
                      listen: false,
                    );

                    if (adProvider.isInterstitialAvailable &&
                        adProvider.loadedInterstitialAd) {
                      debugPrint('BACK FROM DOWNLOADS → SHOWING INTERSTITIAL');

                      adProvider.showInterstitialAd(
                        onAdShowedFullScreen: (ad) {},
                        onAdDismissedFullScreen: (ad) {
                          if (mounted) Navigator.pop(context);
                        },
                        onAdFailedToShowFullScreen: (ad, error) {
                          if (mounted) Navigator.pop(context);
                        },
                      );
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
                title: const Text(
                  "All Videos",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            )
          : null,
      body: Consumer<DownloadedVideoListProvider>(
        builder: (context, provider, child) {
          final videos = provider.downloadedVideos;

          return RefreshIndicator(
            onRefresh: () async {
              provider.loadDownloadedVideos();
              await Future.delayed(const Duration(milliseconds: 800));
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Refreshed"),
                    duration: Duration(milliseconds: 800),
                  ),
                );
              }
            },
            child: videos.isEmpty
                ? _buildEmptyState()
                : _buildVideoListWithAds(videos: videos),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white60 : const Color(0xFF738BAB);
    final primaryColor = isDark ? const Color(0xFF3B82F6) : const Color(0xFF2563EB);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.cloud_download_outlined,
                          size: 72,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "No Saved Videos",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Videos you download will appear here.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // MAIN CHANGE — NATIVE ADS EVERY 4 VIDEOS
  Widget _buildVideoListWithAds({required List<dynamic> videos}) {
    // SHOW AD AS SOON AS 3+ VIDEOS ARE LOADED (NO NEED PULL TO REFRESH)
    if (videos.length >= 3) {
      Future.microtask(() {
        final adProvider = Provider.of<AdProvider>(context, listen: false);
        if (adProvider.isInterstitialAvailable &&
            adProvider.loadedInterstitialAd) {
          debugPrint('DOWNLOADS SCREEN: 3+ videos → SHOWING INTERSTITIAL');
          adProvider.showInterstitialAd(
            onAdShowedFullScreen: (ad) {},
            onAdDismissedFullScreen: (ad) {},
            onAdFailedToShowFullScreen: (ad, error) {},
          );
        }
      });
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 2.0.h, horizontal: 3.0.w),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: videos.length + (videos.length ~/ 4),
      itemBuilder: (context, index) {
        final videoIndex = index - (index ~/ 5);
        if (index > 3 && (index - 3) % 5 == 0) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: NativeAdWidget(),
          );
        }
        if (videoIndex < videos.length) {
          return VideoListItemWidget(videoDownloadedModel: videos[videoIndex]);
        }
        return const SizedBox.shrink();
      },
    );
  }
}

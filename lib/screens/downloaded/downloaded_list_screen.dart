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
                backgroundColor: const Color(0xFF3B82F6),
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () async {
                    final adProvider = Provider.of<AdProvider>(
                      context,
                      listen: false,
                    );

                    if (adProvider.isInterstitialAvailable &&
                        adProvider.loadedInterstitialAd) {
                      debugPrint('BACK FROM DOWNLOADS → SHOWING INTERSTITIAL');

                      // Ad show karo, aur sirf dismiss hone ke baad back jao
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
                      // Agar ad nahi ready → turant back
                      Navigator.pop(context);
                    }
                  },
                ),
                title: Text(
                  "All videos",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 18.sp,
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
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/icon/empty_folder.png', width: 160),
                    const SizedBox(height: 16),
                    Text(
                      "No video history",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF738BAB)
                      ),
                    ),
                    const SizedBox(height: 400),
                  ],
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

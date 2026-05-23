import 'package:downvid/models/video_downloaded_model/video_downloaded_model.dart';
import 'package:downvid/providers/ad_provider/ads_provider.dart';
import 'package:downvid/providers/downloaded_video_list_provider/downloaded_video_list_provider.dart';
import 'package:downvid/screens/video_player_screen/video_player_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';

class VideoListItemWidget extends StatelessWidget {
  final VideoDownloadedModel videoDownloadedModel;
  const VideoListItemWidget({super.key, required this.videoDownloadedModel});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(bottom: 1.0.h),
        child: Column(children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // thumbnail
            Stack(children: [
              Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: NetworkImage(videoDownloadedModel.thumbnail),
                          fit: BoxFit.cover))),
              Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        color: Colors.black38.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(5)),
                    child: Text(videoDownloadedModel.videoDuration,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: Colors.white)),
                  ))
            ]),
            // title
            Expanded(
                child: Container(
                    margin: const EdgeInsets.only(left: 10),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(videoDownloadedModel.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(fontSize: 16.sp)),
                          const SizedBox(height: 8),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(videoDownloadedModel.videoQuality,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium),
                                const SizedBox(width: 5),
                                Text(videoDownloadedModel.videoFileSize,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium),
                                const SizedBox(width: 5),
                                Text(
                                    videoDownloadedModel
                                        .getFormattedDownloadedDate(),
                                    style:
                                        Theme.of(context).textTheme.bodyMedium)
                              ]),
                          // Row(
                          //     mainAxisAlignment: MainAxisAlignment.center,
                          //     children: [
                          //       // play icon
                          //       const SizedBox(width: 5),
                          //       IconButton(
                          //           onPressed: () {
                          //             // Navigate to player screen
                          //             // use an existing property from the model as the video path
                          //             // final String videoPath =
                          //             // videoDownloadedModel.videoPath;
                          //             Navigator.push(
                          //               context,
                          //               MaterialPageRoute(
                          //                 builder: (_) => VideoPlayerScreen(
                          //                     video: videoDownloadedModel),
                          //               ),
                          //             );
                          //           },
                          //           icon: const Icon(Icons.play_circle_outlined,
                          //               size: 28, color: Color(0xFF3B82F6))),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // play icon
                                const SizedBox(width: 5),
                                IconButton(
                                    onPressed: () async {
                                      final adProvider = Provider.of<AdProvider>(
                                        context,
                                        listen: false,
                                      );

                                      // Show interstitial ad before opening player
                                      if (adProvider.isInterstitialAvailable &&
                                          adProvider.loadedInterstitialAd) {
                                        adProvider.showInterstitialAd(
                                          onAdShowedFullScreen: (_) {},
                                          onAdDismissedFullScreen: (_) {
                                            // Navigate after ad is closed
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => VideoPlayerScreen(
                                                    video: videoDownloadedModel),
                                              ),
                                            );
                                          },
                                          onAdFailedToShowFullScreen: (_, error) {
                                            // If ad fails, navigate directly
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => VideoPlayerScreen(
                                                    video: videoDownloadedModel),
                                              ),
                                            );
                                          },
                                        );
                                      } else {
                                        // No ad available → direct navigation
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => VideoPlayerScreen(
                                                video: videoDownloadedModel),
                                          ),
                                        );
                                      }
                                    },
                                    icon: const Icon(Icons.play_circle_outlined,
                                        size: 28, color: Color(0xFF3B82F6))),
                                // info icon
                                // IconButton(
                                //     onPressed: () {},
                                //     icon: const Icon(Icons.info_outline_rounded,
                                //         size: 28, color: Color(0xFF3B82F6))),
                                // const SizedBox(width: 5),
                                // share icon
                                IconButton(
                                    onPressed: () {
                                      final originalUrl =
                                          (videoDownloadedModel.originalUrl)
                                              .trim();
                                      final fallbackUrl = videoDownloadedModel
                                          .videoSocialUrl
                                          .trim();

                                      final urlToShare =
                                          originalUrl.isNotEmpty &&
                                                  Uri.tryParse(originalUrl)
                                                          ?.hasScheme ==
                                                      true
                                              ? originalUrl
                                              : fallbackUrl;

                                      Share.share(urlToShare,
                                          subject: 'Check out this video!');
                                    },
                                    icon: const Icon(Icons.share_outlined,
                                        size: 28, color: Color(0xFF3B82F6))),
                                const SizedBox(width: 5),
                                // delete icon
                                IconButton(
                                    onPressed: () {
                                      context
                                          .read<DownloadedVideoListProvider>()
                                          .deleteVideo(
                                              videoDownloadedModel, context);
                                    },
                                    icon: const Icon(Icons.delete_outline,
                                        size: 28, color: Color(0xFF3B82F6))),
                                const SizedBox(width: 5)
                              ])
                        ])))
          ]),
          const Divider(),
        ]));
  }
}

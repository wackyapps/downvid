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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final primaryColor = isDark ? const Color(0xFF3B82F6) : const Color(0xFF2563EB);

    return Container(
      margin: EdgeInsets.only(bottom: 2.0.h),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail with custom roundings and shadow
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    videoDownloadedModel.thumbnail,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 90,
                      height: 90,
                      color: isDark ? const Color(0xFF0F172A) : Colors.grey[200],
                      child: const Icon(Icons.broken_image, size: 30, color: Colors.grey),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      videoDownloadedModel.videoDuration,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),

            // Metadata / Title / Actions
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    videoDownloadedModel.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Metadata Badges (Quality, Size, Date)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildMetaBadge(context, videoDownloadedModel.videoQuality.toUpperCase()),
                        const SizedBox(width: 6),
                        _buildMetaBadge(context, videoDownloadedModel.videoFileSize),
                        const SizedBox(width: 6),
                        _buildMetaBadge(context, videoDownloadedModel.getFormattedDownloadedDate()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Action Buttons Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Play button
                      _buildActionButton(
                        context,
                        icon: Icons.play_arrow_rounded,
                        color: primaryColor,
                        onTap: () async {
                          final adProvider = Provider.of<AdProvider>(
                            context,
                            listen: false,
                          );

                          if (adProvider.isInterstitialAvailable &&
                              adProvider.loadedInterstitialAd) {
                            adProvider.showInterstitialAd(
                              onAdShowedFullScreen: (_) {},
                              onAdDismissedFullScreen: (_) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => VideoPlayerScreen(
                                      video: videoDownloadedModel,
                                    ),
                                  ),
                                );
                              },
                              onAdFailedToShowFullScreen: (_, error) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => VideoPlayerScreen(
                                      video: videoDownloadedModel,
                                    ),
                                  ),
                                );
                              },
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => VideoPlayerScreen(
                                  video: videoDownloadedModel,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(width: 8),

                      // Share button
                      _buildActionButton(
                        context,
                        icon: Icons.share_rounded,
                        color: isDark ? Colors.white70 : Colors.black54,
                        onTap: () async {
                          final filePath = videoDownloadedModel.videoPath.trim();
                          final file = XFile(filePath);
                          await Share.shareXFiles([
                            file,
                          ], text: 'Check out this video!');
                        },
                      ),
                      const SizedBox(width: 8),

                      // Delete button
                      _buildActionButton(
                        context,
                        icon: Icons.delete_outline_rounded,
                        color: Colors.redAccent,
                        onTap: () {
                          context
                              .read<DownloadedVideoListProvider>()
                              .deleteVideo(videoDownloadedModel, context);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaBadge(BuildContext context, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white60 : Colors.black54,
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }
}

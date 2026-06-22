// lib/screens/video_player_screen/video_player_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:downvid/models/video_downloaded_model/video_downloaded_model.dart';
import 'package:downvid/services/video_service/video_playback_service.dart';
import 'package:downvid/providers/video_player_provider/video_player_provider.dart';

class VideoPlayerScreen extends StatelessWidget {
  final VideoDownloadedModel video;
  const VideoPlayerScreen({required this.video, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          video.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: FutureBuilder<String>(
        future: VideoPlaybackService.instance.getValidVideoPath(video),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ChangeNotifierProvider(
              create: (_) => VideoPlayerProvider()..play(snapshot.data!),
              child: const _VideoPlayerBody(),
            );
          }
          if (snapshot.hasError) {
            return const _ErrorView();
          }
          return const _LoadingView();
        },
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// MAIN PLAYER BODY – NO OVERFLOW GUARANTEED
// ──────────────────────────────────────────────────────────────
class _VideoPlayerBody extends StatelessWidget {
  const _VideoPlayerBody();

  @override
  Widget build(BuildContext context) {
    return Consumer<VideoPlayerProvider>(
      builder: (context, player, child) {
        if (!player.isInitialized) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }

        final controller = player.controller!;

        return Column(
          children: [
            // 1. Video – takes only the space it needs
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: VideoPlayer(controller),
                ),
              ),
            ),

            // 2. Bottom Controls – FIXED HEIGHT, NEVER OVERFLOWS
            Material(
              color: Colors.black.withOpacity(0.6),
              child: SizedBox(
                height: 110, // Fixed safe height (works on all phones)
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Play/Pause Button – reduced size
                    IconButton(
                      iconSize: 50,
                      onPressed: player.toggle,
                      icon: Icon(
                        player.isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Progress bar – minimal padding
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: VideoProgressIndicator(
                        controller,
                        allowScrubbing: true,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        colors: const VideoProgressColors(
                          playedColor: Color(0xFF2563EB),
                          bufferedColor: Colors.white54,
                          backgroundColor: Colors.white24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Other States (Error / Loading)
// ──────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  const _ErrorView();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off, color: Colors.red, size: 80),
          SizedBox(height: 16),
          Text(
            "Video unavailable\nRe-download failed",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          SizedBox(height: 20),
          ElevatedButton(onPressed: null, child: Text("Back")),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 20),
          Text("Restoring video...", style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
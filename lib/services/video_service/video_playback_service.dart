// lib/services/video_playback_service.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:downvid/models/video_downloaded_model/video_downloaded_model.dart';

class VideoPlaybackService {
  // Singleton (optional but recommended)
  VideoPlaybackService._();
  static final VideoPlaybackService instance = VideoPlaybackService._();

  /// Returns a playable file path.
  /// - If local file exists → returns it (fast)
  /// - If missing → silently redownloads to temp folder and returns temp path
  Future<String> getValidVideoPath(VideoDownloadedModel video) async {
    final localPath = video.videoPath;
    final localFile = File(localPath);

    // Case 1: File exists and has decent size → use it immediately
    if (await localFile.exists()) {
      final length = await localFile.length();
      if (length > 1024) { // > 1 KB (avoid corrupted 0-byte files)
        return localPath;
      }
    }

    // Case 2: File missing or corrupted → redownload to temp directory
    debugPrint("Local file missing or empty: $localPath → redownloading...");

    final tempDir = await getTemporaryDirectory();
    final fileName = localPath.split('/').last;
    final tempPath = '${tempDir.path}/$fileName';
    final tempFile = File(tempPath);

    try {
      await Dio().download(
        video.videoSocialUrl, // original direct MP4 link you saved
        tempPath,
        options: Options(
          headers: {
            'User-Agent':
                'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36',
          },
        ),
      );

      if (await tempFile.exists() && await tempFile.length() > 1024) {
        debugPrint("Redownloaded successfully to temp: $tempPath");
        return tempPath;
      } else {
        throw Exception("Redownloaded file is empty or invalid");
      }
    } catch (e) {
      debugPrint("Redownload failed: $e");
      // Optionally delete failed temp file
      if (await tempFile.exists()) await tempFile.delete();
      rethrow;
    }
  }
}
// lib/models/video_downloaded_model/video_downloaded_model.dart

import 'package:intl/intl.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class VideoDownloadedModel {
  int id;
  String title;
  String thumbnail;
  String videoSocialUrl;        // ← this is currently the direct .mp4 link
  String videoPath;
  String videoType;
  String videoQuality;
  String videoFileSize;
  String videoDuration;
  DateTime videoDownloadedDate = DateTime.now();

  // ADD THIS NEW FIELD — the real Facebook/TikTok/etc link user pasted
  String originalUrl;  // ← NEW: the link user entered (e.g. https://fb.watch/xxx)

  String getFormattedDownloadedDate() {
    var inputFormat = DateFormat('dd/MM/yyyy');
    return inputFormat.format(videoDownloadedDate);
  }

  VideoDownloadedModel({
    this.id = 0,
    required this.title,
    required this.thumbnail,
    required this.videoSocialUrl,
    required this.videoPath,
    required this.videoType,
    required this.videoQuality,
    required this.videoFileSize,
    required this.videoDuration,
    required this.videoDownloadedDate,
    required this.originalUrl,  // ← make it required
  });
}
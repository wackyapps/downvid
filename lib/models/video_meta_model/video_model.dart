/**
 * Model representing video metadata including title, thumbnail, and video links.
 */
class VideoMetaDataModel {
  final String? title;
  final String? description;
  final String? duration;
  final String? thumbnail;
  final List<VideoLinkModel> videoLinks;
  final bool hasScrappingError;  // ← late final hata diya, ab normal bool

  VideoMetaDataModel({
    this.title,
    this.description,
    this.duration,
    this.thumbnail,
    required this.videoLinks,
    this.hasScrappingError = false, // default false
  });
}
/**
 * Model representing a video link with quality, link URL, and type.
 */

class VideoLinkModel {
  final String quality;
  final String link;
  final String type;

  VideoLinkModel({
    required this.link,
    required this.quality,
    required this.type,
  });
}

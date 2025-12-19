import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class SocialUrlUtilities {
  static bool isValidVideoUrl(String sampleUrl) {
    // Basic validation; improve later
    return sampleUrl.contains('facebook') ||
        sampleUrl.contains('instagram') ||
        sampleUrl.contains('youtube') ||
        sampleUrl.contains('tiktok');
  }

static String getFacebookUrl(String sampleUrl) {
  // Sabse pehle RTL characters hata do
  String clean = sampleUrl
      .replaceAll(RegExp(r'[\u200E\u200F\u202A-\u202E\u2028\r]'), '')
      .trim();

  final uri = Uri.tryParse(clean);
  if (uri == null) return clean;

  final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();

  // Reel format: /share/r/ID or /reel/ID
  if (segments.contains('r') || segments.contains('reel')) {
    final index = segments.indexWhere((s) => s == 'r' || s == 'reel') + 1;
    if (index < segments.length) {
      return 'https://www.facebook.com/reel/${segments[index]}';
    }
  }

  // Watch format: /share/v/ID or /watch/?v=ID
  if (segments.contains('v') || uri.queryParameters.containsKey('v')) {
    final videoId = segments.contains('v') 
        ? segments[segments.indexOf('v') + 1]
        : uri.queryParameters['v'];
    if (videoId != null) {
      return 'https://www.facebook.com/watch/?v=$videoId';
    }
  }

  // Fallback: m.facebook.com bana do (fdown.net better accept karta hai)
  return clean.replaceFirst('www.facebook.com', 'm.facebook.com');
}



  static bool isValidFBUrl(String sampleUrl) {
    List<String> splitUrl = sampleUrl.split('/');
    return splitUrl.contains('share') && (splitUrl.contains('v') || splitUrl.contains('r'));
  }

  static bool isValidTwitterUrl(String sampleUrl) {
    return sampleUrl.contains('twitter') || sampleUrl.contains('x.com');
  }

  static String getTwitterUrl(String sampleUrl) {
    return 'https://x.com/$sampleUrl';
  }

  static bool isValidInstagramUrl(String sampleUrl) {
    return sampleUrl.contains('reel');
  }

  static String getInstagramUrl(String sampleUrl) {
    return 'https://www.instagram.com/$sampleUrl';
  }

  static bool isValidYoutubeUrl(String sampleUrl) {
    return sampleUrl.contains('watch') && sampleUrl.contains('v=');
  }

  static String getYoutubeUrl(String sampleUrl) {
    return 'https://www.youtube.com/$sampleUrl';
  }
}

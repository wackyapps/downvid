class SocialUrlUtilities {
  static bool isValidVideoUrl(String sampleUrl) {
    // Basic validation; improve later
    return sampleUrl.contains('facebook') ||
        sampleUrl.contains('instagram') ||
        sampleUrl.contains('youtube') ||
        sampleUrl.contains('tiktok');
  }

static String getFacebookUrl(String sampleUrl) {
  final cleanUrl = sampleUrl.trim();
  final parts = cleanUrl.split('/').where((part) => part.isNotEmpty).toList();

  if (parts.contains('share') && parts.contains('r')) {
    final index = parts.indexOf('r') + 1;
    if (index < parts.length) {
      return 'https://www.facebook.com/reel/${parts[index]}';
    }
  } else if (parts.contains('share') && parts.contains('v')) {
    final index = parts.indexOf('v') + 1;
    if (index < parts.length) {
      return 'https://www.facebook.com/watch/?v=${parts[index].split('?').first}';
    }
  }
  return cleanUrl;
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
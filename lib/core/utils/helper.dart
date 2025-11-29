class SocialUrlUtilities {
  static bool isValidVideoUrl(String sampleUrl) {
    // Basic validation; improve later
    return sampleUrl.contains('facebook') ||
        sampleUrl.contains('instagram') ||
        sampleUrl.contains('youtube') ||
        sampleUrl.contains('tiktok');
  }

  static String getFacebookUrl(String sampleUrl) {
    /**
     * Input: https://www.facebook.com/share/r/1JXSaBjGdH/
     * Split: ["https:", "", "www.facebook.com", "share", "r", "1JXSaBjGdH", ""]
     * Output: https://www.facebook.com/reel/1JXSaBjGdH
     *
     * Input: https://www.facebook.com/share/v/QQH89wP2FKAR78sa/?mibextid=jmPrMh
     * Split: ["https:", "", "www.facebook.com", "share", "v", "QQH89wP2FKAR78sa", "?mibextid=jmPrMh"]
     * Output: https://www.facebook.com/watch/?v=QQH89wP2FKAR78sa
     */
    List<String> splitUrl = sampleUrl.split('/');
    print('Split URL: $splitUrl');
    if (splitUrl.contains('share') && splitUrl.contains('r')) {
      final videoIdIndex = splitUrl.indexOf('r') + 1;
      if (videoIdIndex < splitUrl.length) {
        return 'https://www.facebook.com/reel/${splitUrl[videoIdIndex]}';
      }
    } else if (splitUrl.contains('share') && splitUrl.contains('v')) {
      final videoIdIndex = splitUrl.indexOf('v') + 1;
      if (videoIdIndex < splitUrl.length) {
        return 'https://www.facebook.com/watch/?v=${splitUrl[videoIdIndex].split('?')[0]}';
      }
    }
    return sampleUrl; // Fallback to original if parsing fails
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
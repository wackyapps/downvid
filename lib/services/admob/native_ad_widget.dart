// native_ad_widget.dart
// import 'package:downvid/providers/ad_provider/ad_provider.dart';
import 'package:downvid/providers/ad_provider/ads_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

class NativeAdWidget extends StatelessWidget {
  const NativeAdWidget({super.key});

@override
  Widget build(BuildContext context) {
    final adProvider = Provider.of<AdProvider>(context, listen: false);
    // adProvider.loadNativeAd(); // First time load

    return Consumer<AdProvider>(
      builder: (context, adProvider, _) {
        final nativeAd = adProvider.nativeAd;

        if (nativeAd == null || !adProvider.nativeAdIsLoaded) {
          return const SizedBox(height: 370);
        }

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 6),
            ],
          ),
          height: 370,
          child: AdWidget(ad: nativeAd),
        );
      },
    );
  }
}
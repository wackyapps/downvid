import 'package:downvid/providers/ad_provider/ads_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final adProvider = Provider.of<AdProvider>(context, listen: false);
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) async {
        // Show interstitial ad BEFORE switching tab
        if (adProvider.isInterstitialAvailable && adProvider.loadedInterstitialAd) {
          adProvider.showInterstitialAd(
            onAdShowedFullScreen: (_) {},
            onAdDismissedFullScreen: (_) {
              // Switch tab AFTER ad is dismissed
              onTap(index);
            },
            onAdFailedToShowFullScreen: (_, error) {
              // If ad fails, switch tab anyway
              onTap(index);
            },
          );
        } else {
          // No ad available → switch tab directly
          onTap(index);
        }
      },
      backgroundColor: Colors.white,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home_rounded),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.download_outlined),
          activeIcon: Icon(Icons.download_rounded),
          label: "Downloads",
        ),
        // BottomNavigationBarItem(
        //   icon: Icon(Icons.settings_outlined),
        //   activeIcon: Icon(Icons.settings_rounded),
        //   label: "Settings",
        // ),
      ],
    );
  }
}

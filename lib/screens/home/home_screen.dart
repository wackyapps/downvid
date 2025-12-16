import 'package:downvid/providers/ad_provider/ads_provider.dart';
import 'package:downvid/screens/animated_bottom_nav_page/bottom_nav.dart';
import 'package:downvid/screens/appbar/appbar.dart';
import 'package:downvid/screens/downloaded/downloaded_list_screen.dart';
import 'package:downvid/screens/side_nav/side_nav.dart';
import 'package:flutter/material.dart';
import 'package:downvid/screens/home/home_video_fetch_and_list_screen.dart';
import 'package:get_it/get_it.dart';
import 'package:downvid/services/fdown_service/fbdown_service.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FbDownService fbDownService = GetIt.I<FbDownService>();
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeVideoFetchAndListScreen(),
    DownloadedListScreen(),
  ];

  final List<String> _titles = ["Home", "Downloads"];

 @override
  void initState() {
    super.initState();
    fbDownService.initWebView();

    // Ads load — first frame ke baad
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adProvider = Provider.of<AdProvider>(context, listen: false);
      adProvider.loadAdsOnFirstUse(); // New method
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: _titles[_selectedIndex]),
      drawer: const CustomDrawer(), // 👈 This enables the side nav to open
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNavBar(
  currentIndex: _selectedIndex,
  onTap: (index) {
    if (index == _selectedIndex) return;

    // NO AD — JUST SWITCH TAB
    setState(() {
      _selectedIndex = index;
    });
  },
),
    );
  }
}

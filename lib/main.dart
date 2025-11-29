import 'dart:io';
import 'package:downvid/providers/ad_provider/ads_provider.dart';
import 'package:downvid/providers/downloaded_video_list_provider/downloaded_video_list_provider.dart';
import 'package:downvid/providers/home_download_provider/home_download_provider.dart';
import 'package:downvid/providers/theme_provider/theme_provider.dart';
import 'package:downvid/screens/downloaded/downloaded_list_screen.dart';
import 'package:downvid/screens/home/home_screen.dart';
import 'package:downvid/screens/home/remove_ads/remove_ads_screen.dart';
import 'package:downvid/screens/setttings/languages_list_screen.dart';
import 'package:downvid/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  MobileAds.instance.initialize();

  try {
    await setupServiceLocator();
    print('Service locator setup complete');
  } catch (e) {
    print('Service locator setup failed: $e');
    return;
  }

  // initialize media store
 if (Platform.isAndroid) {
    MediaStore.appFolder = "DownVid";  // Creates /Download/DownVid
    await MediaStore.ensureInitialized();
  }

  if (Platform.isAndroid) {
    await Permission.storage.request();
  }

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ChangeNotifierProvider(create: (_) => AdProvider()),
    ChangeNotifierProvider(create: (context) => HomeAndDownloadProvider()),
    ChangeNotifierProvider(create: (_) => DownloadedVideoListProvider()),
  ], child: const MyApp()));

  // THIS IS THE ONLY SAFE PLACE TO LOAD
  WidgetsBinding.instance.addPostFrameCallback((_) {
    getIt<DownloadedVideoListProvider>().loadDownloadedVideos();
  });
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context); // Listen to changes

    return Sizer(builder: (context, orientation, deviceType) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'DownVid',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Colors.black,
          colorScheme: const ColorScheme.dark().copyWith(
            primary: Colors.blueAccent,
            secondary: Colors.blueAccent,
          ),
        ),
        themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light, // ⚡ Important
        initialRoute: "/home",
        routes: {
          '/home': (context) => const HomeScreen(),
          // '/settings': (context) => const SettingsListScreen(),
          '/downloaded': (context) => const DownloadedListScreen(),
          // '/how_to': (context) => const HowToSliderScree(),
          '/remove_ads': (context) => const RemoveAdsScreen(),
          '/languages': (context) => const LanguagesListScreen(),
        },
      );
    });
  }
}


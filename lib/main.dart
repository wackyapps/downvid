import 'dart:io';
import 'package:downvid/providers/ad_provider/ads_provider.dart';
import 'package:downvid/providers/downloaded_video_list_provider/downloaded_video_list_provider.dart';
import 'package:downvid/providers/home_download_provider/home_download_provider.dart';
import 'package:downvid/providers/theme_provider/theme_provider.dart';
import 'package:downvid/screens/downloaded/downloaded_list_screen.dart';
import 'package:downvid/screens/home/home_screen.dart';
import 'package:downvid/screens/home/remove_ads/remove_ads_screen.dart';
import 'package:background_downloader/background_downloader.dart';
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

  await FileDownloader().configure();

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
    MediaStore.appFolder = "DownVid"; // Creates /Download/DownVid
    await MediaStore.ensureInitialized();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AdProvider()),
        ChangeNotifierProvider(create: (context) => HomeAndDownloadProvider()),
        ChangeNotifierProvider(create: (_) => DownloadedVideoListProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(
      context,
    ); // Listen to changes

    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'DownVid',
          theme: ThemeData(
            useMaterial3: true,
            primaryColor: const Color(0xFF2563EB),
            scaffoldBackgroundColor: const Color(0xFFF8FAFC),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2563EB),
              primary: const Color(0xFF2563EB),
              secondary: const Color(0xFF3B82F6),
              background: const Color(0xFFF8FAFC),
              surface: Colors.white,
              brightness: Brightness.light,
            ),
            cardTheme: const CardThemeData(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            primaryColor: const Color(0xFF3B82F6),
            scaffoldBackgroundColor: const Color(0xFF0F172A),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 173, 192, 224),
              primary: const Color(0xFF3B82F6),
              secondary: const Color(0xFF60A5FA),
              background: const Color(0xFF0F172A),
              surface: const Color(0xFF1E293B),
              brightness: Brightness.dark,
            ),
            cardTheme: const CardThemeData(
              color: Color(0xFF1E293B),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
          ),
          themeMode: themeProvider.isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light,
          initialRoute: "/home",
          routes: {
            '/home': (context) => const HomeScreen(),
            '/downloaded': (context) => const DownloadedListScreen(),
          },
        );
      },
    );
  }
}

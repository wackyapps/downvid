// import 'dart:io';
// import 'package:DownVid/providers/theme_provider/theme_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:DownVid/core/utils/app_constants.dart';
// import 'package:DownVid/screens/how_to_slider/how_to_slider.dart';
// import 'package:flutter/material.dart';
// import 'package:in_app_review/in_app_review.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:url_launcher/url_launcher.dart';

// class SettingsListScreen extends StatefulWidget {
//   const SettingsListScreen({super.key});

//   @override
//   State<SettingsListScreen> createState() => _SettingsListScreenState();
// }

// class _SettingsListScreenState extends State<SettingsListScreen> {
//   bool _wifiOnly = false;
//   bool _downloadCompleteNotif = true;
//   bool _downloadFailedNotif = true;

//   final InAppReview inAppReview = InAppReview.instance;

//   @override
//   void initState() {
//     super.initState();
//     _loadSettings();
//   }

//   Future<void> _loadSettings() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _wifiOnly = prefs.getBool('wifiOnly') ?? false;
//     });
//   }

//   Future<void> _saveSetting(String key, bool value) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool(key, value);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final themeProvider = Provider.of<ThemeProvider>(context);

//     return Scaffold(
//       body: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//         child: ListView(
//           children: [
//             // Upgrade Section
//             Padding(
//               padding: const EdgeInsets.only(top: 8.0, bottom: 18.0),
//               child: Text("Upgrade", style: Theme.of(context).textTheme.labelLarge),
//             ),
//             ListTile(
//               leading: const Icon(Icons.block),
//               minLeadingWidth: 0,
//               contentPadding: const EdgeInsets.all(0),
//               title: Text("Remove Ads", style: Theme.of(context).textTheme.labelLarge),
//               onTap: () {},
//             ),

//             // Download Section
//             Padding(
//               padding: const EdgeInsets.only(top: 8.0, bottom: 18.0),
//               child: Text("Download", style: Theme.of(context).textTheme.labelLarge),
//             ),
//             SwitchListTile(
//               title: Text("Download with Wi-Fi only", style: Theme.of(context).textTheme.labelLarge),
//               secondary: const Icon(Icons.wifi),
//               value: _wifiOnly,
//               onChanged: (value) async {
//                 setState(() => _wifiOnly = value);
//                 await _saveSetting('wifiOnly', value);
//                 Fluttertoast.showToast(
//                   msg: value
//                       ? "Downloads will now work only on Wi-Fi"
//                       : "Downloads allowed on all networks",
//                 );
//               },
//             ),

//             // Interface Section
//             Padding(
//               padding: const EdgeInsets.only(top: 8.0, bottom: 18.0),
//               child: Text("Interface", style: Theme.of(context).textTheme.labelLarge),
//             ),
//             SwitchListTile(
//               title: const Text("Dark Mode"),
//               secondary: const Icon(Icons.dark_mode),
//               value: themeProvider.isDarkMode,
//               onChanged: (value) {
//                 themeProvider.toggleTheme(value);
//               },
//             ),

//             // Notifications Section
//             Padding(
//               padding: const EdgeInsets.only(top: 8.0, bottom: 18.0),
//               child: Text("Notifications", style: Theme.of(context).textTheme.labelLarge),
//             ),
//             SwitchListTile(
//               title: Text("Download completed notification", style: Theme.of(context).textTheme.labelLarge),
//               secondary: const Icon(Icons.notification_add_outlined),
//               value: _downloadCompleteNotif,
//               onChanged: (value) {
//                 setState(() => _downloadCompleteNotif = value);
//               },
//             ),
//             SwitchListTile(
//               title: Text("Download failed notification", style: Theme.of(context).textTheme.labelLarge),
//               secondary: const Icon(Icons.notification_important_outlined),
//               value: _downloadFailedNotif,
//               onChanged: (value) {
//                 setState(() => _downloadFailedNotif = value);
//               },
//             ),

//             // Other Section
//             Padding(
//               padding: const EdgeInsets.only(top: 8.0, bottom: 18.0),
//               child: Text("Other", style: Theme.of(context).textTheme.labelLarge),
//             ),
//             ListTile(
//               leading: const Icon(Icons.language),
//               minLeadingWidth: 0,
//               contentPadding: const EdgeInsets.all(0),
//               title: Text("Languages", style: Theme.of(context).textTheme.labelLarge),
//               onTap: () {
//                 Navigator.of(context).pushNamed('/languages');
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.star),
//               minLeadingWidth: 0,
//               contentPadding: const EdgeInsets.all(0),
//               title: Text("Rate Us", style: Theme.of(context).textTheme.labelLarge),
//               onTap: () {
//                 try {
//                   inAppReview.openStoreListing();
//                 } catch (e) {
//                   print("Error opening store listing: $e");
//                 }
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.feedback),
//               minLeadingWidth: 0,
//               contentPadding: const EdgeInsets.all(0),
//               title: Text("Feedback", style: Theme.of(context).textTheme.labelLarge),
//               onTap: () async {
//                 final url = Uri.parse(AppConstants.feedbackMessageString);
//                 if (await canLaunchUrl(url)) launchUrl(url);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.share),
//               minLeadingWidth: 0,
//               contentPadding: const EdgeInsets.all(0),
//               title: Text("Share", style: Theme.of(context).textTheme.labelLarge),
//               onTap: () async {
//                 if (Platform.isAndroid) {
//                   await Share.share(AppConstants.appShareText + AppConstants.googlePlayStoreUrl);
//                 } else if (Platform.isIOS || Platform.isMacOS) {
//                   await Share.share(AppConstants.appShareText + AppConstants.appleItunesStoreUrl);
//                 } else {
//                   await Share.share(AppConstants.appShareText + AppConstants.googlePlayStoreUrl);
//                 }
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.info_outline),
//               minLeadingWidth: 0,
//               contentPadding: const EdgeInsets.all(0),
//               title: Text("How to use", style: Theme.of(context).textTheme.labelLarge),
//               onTap: () {
//                 Navigator.push(context, MaterialPageRoute(builder: (_) => const HowToSliderScree()));
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

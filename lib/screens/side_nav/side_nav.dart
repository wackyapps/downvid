
import 'package:downvid/screens/downloaded/downloaded_list_screen.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:in_app_review/in_app_review.dart';
// ignore: depend_on_referenced_packages
import 'package:url_launcher/url_launcher.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final InAppReview inAppReview = InAppReview.instance;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drawer header with back arrow and title
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        size: 20, color: Colors.black87),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(width: 4),
                  // const Padding(
                  //   padding: EdgeInsets.fromLTRB(60.0, 0, 0, 0),
                  const Text(
                    "Settings",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2563EB), // Blue title color
                    ),
                  ),
                  // ),
                ],
              ),
              // const Divider(
              //   height: 15,
              //   endIndent: 50.0,
              //   indent: 50.0,

              // ),

              const SizedBox(height: 12),

              // Drawer menu items
              // _buildDrawerItem(
              //   icon: Icons.language,
              //   text: "Language",
              //   onTap: () => Navigator.pushNamed(context, '/languages'),
              // ),
              const SizedBox(height: 5),
              _buildDrawerItem(
                icon: Icons.star_border,
                text: "Rate Us",
                onTap: () {
                  try {
                    inAppReview.openStoreListing();
                  } catch (e) {
                    print("Error opening store listing: $e");
                  }
                },
              ),

              const SizedBox(height: 5),

              _buildDrawerItem(
                icon: Icons.feedback_outlined,
                text: "Feedback",
                onTap: () async {
                  final Uri url = Uri.parse(
                      'https://mail.google.com/mail/u/0/?view=cm&fs=1&to=ramiqwaqas@gmail.com&su=Feedback for DownVid&body=Hello,\n\nI love DownVid because...\n\nThank you!');

                  await launchUrl(url, mode: LaunchMode.externalApplication);
                },
              ),
              const SizedBox(height: 5),
              _buildDrawerItem(
                  icon: Icons.download_outlined,
                  text: "Downloads",
                  onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const DownloadedListScreen(fromDrawer: true),
                        ),
                      )),

              const SizedBox(height: 5),
              // _buildDrawerItem(
              //   icon: Icons.privacy_tip_outlined,
              //   text: "Privacy Policy",
              //   onTap: () => Navigator.pushNamed(context, '/privacy'),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: Colors.black87),
      title: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}

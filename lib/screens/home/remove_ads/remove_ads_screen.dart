import 'package:flutter/material.dart';

class RemoveAdsScreen extends StatefulWidget {
  const RemoveAdsScreen({super.key});

  @override
  State<RemoveAdsScreen> createState() => _RemoveAdsScreenState();
}

class _RemoveAdsScreenState extends State<RemoveAdsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
   
      body:
          // List view with settings
          ListView(
        children: const [
          Text("Remove Ads"),
          Text("Remove Ads"),
          Text("Remove Ads"),
          Text("Remove Ads"),
          Text("Remove Ads"),
        ],
      ),
    );
  }
}

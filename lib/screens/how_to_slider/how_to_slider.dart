import 'package:flutter/material.dart';

class HowToSliderScree extends StatefulWidget {
  const HowToSliderScree({super.key});

  @override
  State<HowToSliderScree> createState() => _HowToSliderScreeState();
}

class _HowToSliderScreeState extends State<HowToSliderScree> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    
      body:
          // List view with settings
          ListView(
        children: const [
          Text("How To"),
          Text("How To"),
          Text("How To"),
          Text("How To"),
          Text("How To"),
        ],
      ),
    );
  }
}

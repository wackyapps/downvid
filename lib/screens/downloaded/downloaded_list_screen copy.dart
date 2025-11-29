// import 'package:flutter/material.dart';
// import 'package:sizer/sizer.dart';
// // import 'package:DownVid/widgets/custom_app_bar.dart';   // <-- your existing AppBar

// class DownloadedListScreen extends StatelessWidget {
//   final bool fromDrawer;

//   const DownloadedListScreen({super.key, this.fromDrawer = false});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // ──────────────────────────────────────────────────────────────
//       //  Conditional AppBar – ONLY when opened from drawer
//       // ──────────────────────────────────────────────────────────────
//       appBar: fromDrawer
//           ? PreferredSize(
//               preferredSize: const Size.fromHeight(60),
//               child: AppBar(
//                   backgroundColor: const Color(0xFF3B82F6),
//                   elevation: 0,
//                   leading: IconButton(
//                     icon: const Icon(Icons.arrow_back, color: Colors.white),
//                     onPressed: () => Navigator.of(context).pop(),
//                   ),
//                   title: Text("All videos",
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.w600,
//                           fontSize: 18.sp)),
//                   centerTitle: false),
//             )
//           : null, // ← no AppBar → global one from HomeScreen stays

//       // ──────────────────────────────────────────────────────────────
//       //  Your existing body (list / empty state)
//       // ──────────────────────────────────────────────────────────────
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Image.asset(
//               'assets/icon/empty_folder.png', // <-- put your sad-folder image here
//               width: 160,
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               "No video history",
//               style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black),
//             ),
//             const SizedBox(height: 300),
//           ],
//         ),
//       ),
//     );
//   }
// }

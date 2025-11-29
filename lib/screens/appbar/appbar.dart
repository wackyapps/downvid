import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({super.key, required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF3B82F6),
      elevation: 0,
      titleSpacing: 16,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.white, size: 26),
        onPressed: () {
          // This ensures the drawer opens correctly regardless of where AppBar is used
          ScaffoldMessenger.of(context).clearSnackBars();
          Scaffold.maybeOf(context)?.openDrawer();
        },
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      // actions: [
      //   IconButton(
      //     icon: const Icon(
      //       Icons.diamond_outlined,
      //       color: Color(0xFFFFD700),
      //       size: 26,
      //     ),
      //     onPressed: () {
      //       Navigator.pushNamed(context, '/remove_ads');
      //     },
      //     tooltip: "Remove Ads",
      //   ),
      //   const SizedBox(width: 8),
      // ],
    );
  }
}

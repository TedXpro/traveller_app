import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight); // The height of the AppBar

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blue,
      title: Center(child: Image.asset('assets/hawir_logo.png', height: 80)),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () => _showNotification(context),
        ),
      ],
      leading: IconButton(
        icon: const Icon(Icons.account_circle),
        onPressed: () => _showUserProfile(context),
      ),
    );
  }

  void _showNotification(BuildContext context) {
    // Handle notification action here
    print('Notifications');
  }

  void _showUserProfile(BuildContext context) {
    // Handle user profile action here
    print('User Profile');
  }
}

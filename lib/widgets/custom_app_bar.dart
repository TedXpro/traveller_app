import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow for resizing
      backgroundColor: Colors.transparent, // Make background transparent
      builder: (BuildContext context) {
        return Align(
          alignment: Alignment.centerLeft, // Align to left
          child: Container(
            width: MediaQuery.of(context).size.width * 0.5, // 50% screen width
            margin: EdgeInsets.only(top: kToolbarHeight), // Start below app bar
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(10), // Optional rounded corners
                bottomRight: Radius.circular(10),
              ),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Wrap content
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage(
                    'assets/profile_placeholder.png',
                  ), // Replace with actual image
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Edit Profile'),
                  onTap: () {
                    Navigator.pop(context); // Close sheet
                    print('Edit Profile');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {
                    Navigator.pop(context); // Close sheet
                    print('Settings');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () {
                    Navigator.pop(context); // Close sheet
                    print('Logout');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

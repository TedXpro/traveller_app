import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traveller_app/providers/user_provider.dart';
import 'package:traveller_app/screens/map.dart';
import 'package:traveller_app/screens/settings.dart';
import 'package:traveller_app/screens/signin.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:traveller_app/screens/notification_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // Import Firebase Messaging

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(60.0);
}

class _CustomAppBarState extends State<CustomAppBar> {
  bool _hasUnreadNotifications = false;
RemoteMessage? _latestForegroundMessage; // Store the latest message

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      setState(() {
        _hasUnreadNotifications = true;
        _latestForegroundMessage = message; // Store the message
      });
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');
      if (message.notification != null) {
        print(
          'Message also contained a notification: ${message.notification!.body}',
        );
      }
    });
  }

  void _navigateToNotifications(BuildContext context) {
    setState(() {
      _hasUnreadNotifications = false;
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => NotificationScreen(
              foregroundMessage: _latestForegroundMessage, // Pass the message
            ),
      ),
    );
    _latestForegroundMessage =
        null; // Clear the stored message after navigation
  }

  _logout(BuildContext context) async {
    await Provider.of<UserProvider>(context, listen: false).clearUserData();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppBar(
      backgroundColor: const Color.fromRGBO(242, 246, 250, 0.658),
      title: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/hawir_logo.png', height: 60),
            const SizedBox(width: 8),
            Text(
              l10n.hawir,
              style: const TextStyle(
                fontSize: 20,
                color: Color.fromARGB(255, 233, 80, 24),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MapPage()),
            );
          },
          icon: const Icon(Icons.map),
        ),
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () => _navigateToNotifications(context),
            ),
            if (_hasUnreadNotifications)
              Positioned(
                top: 8.0,
                right: 8.0,
                child: Container(
                  width: 10.0,
                  height: 10.0,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ],
      leading: PopupMenuButton<String>(
        icon: const Icon(Icons.menu),
        onSelected: (String value) {
          if (value == 'edit') {
            print('Edit Profile');
          } else if (value == 'settings') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          } else if (value == 'logout') {
            _logout(context);
          }
        },
        itemBuilder:
            (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'edit',
                child: ListTile(
                  leading: const Icon(Icons.edit),
                  title: Text(l10n.editProfile),
                ),
              ),
              PopupMenuItem<String>(
                value: 'settings',
                child: ListTile(
                  leading: const Icon(Icons.settings),
                  title: Text(l10n.settings),
                ),
              ),
              PopupMenuItem<String>(
                value: 'logout',
                child: ListTile(
                  leading: const Icon(Icons.logout),
                  title: Text(l10n.logOut),
                ),
              ),
            ],
      ),
    );
  }
}

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
  // We no longer need to store the message here as navigation uses routes
  // RemoteMessage? _latestForegroundMessage;

  @override
  void initState() {
    super.initState();
    // Foreground message listener for the notification badge
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      setState(() {
        _hasUnreadNotifications = true;
        // You might want to store the message data temporarily if needed for the badge count or a summary,
        // but navigating with routes means the NotificationScreen gets the data via arguments.
      });
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');
      if (message.notification != null) {
        print(
          'Message also contained a notification: ${message.notification!.body}',
        );
      }
    });

    // Note: Handling opening the app from a notification (terminated/background)
    // is done in main.dart's setupInteractedMessage using the navigatorKey and routes.
    // This listener in the AppBar is primarily for updating the badge when
    // a notification arrives while the app is in the foreground.
  }

  void _navigateToNotifications(BuildContext context) {
    // Clear the unread state when the user navigates to the notification screen
    setState(() {
      _hasUnreadNotifications = false;
    });
    // Navigate using the route name defined in main.dart
    // The NotificationScreen will handle fetching/displaying notifications
    // from storage or passed arguments if applicable.
    Navigator.of(context).pushNamed('/notification');
  }

  _logout(BuildContext context) async {
    // Ensure the UserProvider is accessible
    await Provider.of<UserProvider>(context, listen: false).clearUserData();
    // Use pushReplacementNamed if you have a named route for SignInPage
    // Otherwise, the current MaterialPageRoute is fine
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appBarTheme = theme.appBarTheme;

    return AppBar(
      backgroundColor: appBarTheme.backgroundColor,
      title: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/hawir_logo.png', height: 60),
            const SizedBox(width: 8),
            Text(
              l10n.hawir,
              style: TextStyle(
                fontSize: 20,
                color: appBarTheme.foregroundColor,
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
            // TODO: Implement Edit Profile Navigation
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
                  leading: Icon(Icons.edit, color: colorScheme.onSurface),
                  title: Text(
                    l10n.editProfile,
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                ),
              ),
              // --- ADDING THE DIVIDER HERE ---
              const PopupMenuDivider(),
              // ---------------------------------
              PopupMenuItem<String>(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings, color: colorScheme.onSurface),
                  title: Text(
                    l10n.settings,
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                ),
              ),
              // --- ADDING ANOTHER DIVIDER ---
              const PopupMenuDivider(),
              // ------------------------------
              PopupMenuItem<String>(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout, color: colorScheme.onSurface),
                  title: Text(
                    l10n.logOut,
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                ),
              ),
            ],
      ),
    );
  }
}

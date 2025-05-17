import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traveller_app/providers/user_provider.dart';
import 'package:traveller_app/screens/map.dart'; // Assuming MapPage is here
import 'package:traveller_app/screens/settings.dart'; // Assuming SettingsScreen is here
import 'package:traveller_app/screens/signin.dart'; // Assuming SignInPage is here
import 'package:traveller_app/screens/edit_profile.dart'; // Assuming EditProfilePage is here
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
    await Provider.of<UserProvider>(
      context,
      listen: false,
    ).clearUserDataAndToken();
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
            // Ensure the asset path is correct
            Image.asset('assets/hawir_logo.png', height: 60),
            const SizedBox(width: 8),
            Text(
              l10n.hawir, // Localize the app name
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
            if (!context.mounted) return; // Check mounted before navigating
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MapPage()),
            );
          },
          icon: Icon(
            Icons.map,
            color: appBarTheme.actionsIconTheme?.color,
          ), // Use theme color
        ),
        Stack(
          children: [
            IconButton(
              icon: Icon(
                Icons.notifications,
                color: appBarTheme.actionsIconTheme?.color,
              ), // Use theme color
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
                    color: Colors.red, // Use a distinct color for the badge
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ],
      leading: PopupMenuButton<String>(
        icon: Icon(
          Icons.menu,
          color: appBarTheme.iconTheme?.color,
        ), // Use theme color for menu icon
        onSelected: (String value) {
          // Check mounted state before using context in async operations or navigation
          if (!context.mounted) return;

          if (value == 'edit') {
            // Access the UserProvider to get the user data
            final userProvider = Provider.of<UserProvider>(
              context,
              listen: false,
            );
            final user = userProvider.userData;

            // Only navigate if user data is available
            if (user != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfilePage(user: user),
                ), // Pass the user object
              );
              print('Navigating to Edit Profile');
            } else {
              print('User data not available for editing.');
              // Optionally show a message to the user that data is loading or unavailable
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('User data not loaded. Please try again.'),
                ),
              );
            }
          } else if (value == 'settings') {
            if (!context.mounted) return; // Check mounted before navigating
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
            print('Navigating to Settings');
          } else if (value == 'logout') {
            // No need for mounted check before calling _logout as it handles it internally
            _logout(context);
            print('Logging out');
          }
        },
        itemBuilder:
            (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'edit',
                child: ListTile(
                  leading: Icon(
                    Icons.edit,
                    color: colorScheme.onSurface,
                  ), // Use theme color
                  title: Text(
                    l10n.editProfile, // Localize
                    style: TextStyle(
                      color: colorScheme.onSurface,
                    ), // Use theme color
                  ),
                ),
              ),
              // --- ADDING THE DIVIDER HERE ---
              const PopupMenuDivider(),
              // ---------------------------------
              PopupMenuItem<String>(
                value: 'settings',
                child: ListTile(
                  leading: Icon(
                    Icons.settings,
                    color: colorScheme.onSurface,
                  ), // Use theme color
                  title: Text(
                    l10n.settings, // Localize
                    style: TextStyle(
                      color: colorScheme.onSurface,
                    ), // Use theme color
                  ),
                ),
              ),
              // --- ADDING ANOTHER DIVIDER ---
              const PopupMenuDivider(),
              // ------------------------------
              PopupMenuItem<String>(
                value: 'logout',
                child: ListTile(
                  leading: Icon(
                    Icons.logout,
                    color: colorScheme.onSurface,
                  ), // Use theme color
                  title: Text(
                    l10n.logOut, // Localize
                    style: TextStyle(
                      color: colorScheme.onSurface,
                    ), // Use theme color
                  ),
                ),
              ),
            ],
      ),
    );
  }
}

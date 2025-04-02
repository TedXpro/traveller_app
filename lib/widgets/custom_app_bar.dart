import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traveller_app/providers/user_provider.dart';
import 'package:traveller_app/screens/settings.dart';
import 'package:traveller_app/screens/signin.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import AppLocalizations

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(60.0);
}

class _CustomAppBarState extends State<CustomAppBar> {
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
      backgroundColor: Color.fromRGBO(242, 246, 250, 0.658),
      title: Center(
        // Center the title
        child: Row(
          mainAxisSize: MainAxisSize.min, // Wrap content tightly
          children: [
            Image.asset('assets/hawir_logo.png', height: 60),
            const SizedBox(width: 8), // Add spacing between logo and text
            Text(
              l10n.hawir,
              style: TextStyle(
                fontSize: 20,
                color: Color.fromARGB(255, 233, 80, 24),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.map)),
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () => _showNotification(context),
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
            ); // Navigate to SettingsScreen
          } else if (value == 'logout') {
            _logout(context);
          }
        },
        itemBuilder:
            (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit),
                  title: Text(l10n.editProfile),
                ),
              ),
              PopupMenuItem<String>(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text(l10n.settings),
                ),
              ),
              PopupMenuItem<String>(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text(l10n.logOut),
                ),
              ),
            ],
      ),
    );
  }

  void _showNotification(BuildContext context) {
    print('Notifications');
  }
}

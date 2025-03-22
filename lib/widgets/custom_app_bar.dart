import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traveller_app/providers/user_provider.dart';
import 'package:traveller_app/screens/signin.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  // Log out and clear user data from UserProvider
  _logout(BuildContext context) async {
    await Provider.of<UserProvider>(context, listen: false).clearUserData();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black26,
      title: Center(
        child: Row(
          children: [
            Image.asset('assets/hawir_logo.png', height: 80), 
            Text("Hawir", style: TextStyle(fontSize: 24, color: Colors.deepOrange)),
          ],
        )),
      actions: [
        IconButton(
          onPressed: (){}, 
          icon: const Icon(Icons.map)
        ),
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
    print('Notifications');
  }

  void _showUserProfile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.5,
            margin: EdgeInsets.only(top: kToolbarHeight),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                final userData = userProvider.userData;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CircleAvatar(
                      radius: 40,
                      backgroundImage:
                          userData?.profilePhoto != null
                              ? NetworkImage(userData!.profilePhoto!)
                                  as ImageProvider
                              : const AssetImage(
                                'assets/profile_placeholder.png',
                              ),
                    ),
                    const SizedBox(height: 16),
                    if (userData != null)
                      Text(
                        'Welcome, ${userData.firstName} ${userData.lastName}',
                      ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.edit),
                      title: const Text('Edit Profile'),
                      onTap: () {
                        Navigator.pop(context);
                        print('Edit Profile');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.settings),
                      title: const Text('Settings'),
                      onTap: () {
                        Navigator.pop(context);
                        print('Settings');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('Logout'),
                      onTap: () {
                        Navigator.pop(context);
                        _logout(context);
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

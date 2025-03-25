// profile_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traveller_app/providers/user_provider.dart';
import 'package:traveller_app/screens/edit_profile.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final user = userProvider.userData;
          if (user == null) {
            return const Center(child: Text('User data not loaded.'));
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 CircleAvatar(
                  radius: 50,
                  // Placeholder for profile picture (we'll implement upload later)
                  child: const Icon(Icons.person),
                ),
                const SizedBox(height: 16),
                Text('First Name: ${user.firstName}'),
                Text('Last Name: ${user.lastName}'),
                Text('Email: ${user.email}'),
                Text('Phone Number: ${user.phoneNumber}'),
                // Text('Address: ${user.address}'),
                // Text('Date of Birth: ${user.dateOfBirth}'),
                // Add more fields as needed
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to edit profile page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfilePage(user: user),
                      ),
                    );
                  },
                  child: const Text('Edit Profile'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

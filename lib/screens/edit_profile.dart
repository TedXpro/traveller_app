// edit_profile_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traveller_app/models/user.dart';
import 'package:traveller_app/providers/user_provider.dart';
import 'package:traveller_app/services/user_api_services.dart'; // Import UserService

class EditProfilePage extends StatefulWidget {
  final User user;

  const EditProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneNumberController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneNumberController = TextEditingController(
      text: widget.user.phoneNumber,
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  String? _phoneNumberError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                // Placeholder for profile picture (we'll implement upload later)
                child: const Icon(Icons.person),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
              ),
              TextField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _phoneNumberController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  errorText: _phoneNumberError, // Display error message here
                ),
              ),
              // Placeholder for password field (to be implemented later)
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _saveChanges(context);
                },
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveChanges(BuildContext context) async {
    final updatedUser = User(
      id: widget.user.id,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      loginPreference: widget.user.loginPreference,
      email: _emailController.text,
      phoneNumber: _phoneNumberController.text,
      profilePhoto: widget.user.profilePhoto,
      registrationDate: widget.user.registrationDate,
      verified: widget.user.verified,
      favouriteAgencies: widget.user.favouriteAgencies,
    );

    final userService = UserService();
    final errorMessage = await userService.updateUserProfile(updatedUser);

    if (errorMessage == null) {
      // Success
      final fetchedUser = await userService.getUserData(widget.user.id);
      if (fetchedUser != null) {
        Provider.of<UserProvider>(
          context,
          listen: false,
        ).setUserData(fetchedUser);
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Profile updated successfully, but failed to refetch data.',
            ),
          ),
        );
      }
    } else {
      // Error
      setState(() {
        _phoneNumberError = errorMessage; // Set the error message
      });
    }
  }
}

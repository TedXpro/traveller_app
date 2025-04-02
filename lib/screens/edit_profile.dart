import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traveller_app/models/change_credentials.dart';
import 'package:traveller_app/models/user.dart';
import 'package:traveller_app/models/user_profile.dart';
import 'package:traveller_app/providers/user_provider.dart';
import 'package:traveller_app/services/user_api_services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditProfilePage extends StatefulWidget {
  final User user;

  const EditProfilePage({super.key, required this.user});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneNumberController;

  bool _showPasswordFields = false;
  late TextEditingController _oldPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneNumberController = TextEditingController(
      text: widget.user.phoneNumber,
    );

    _oldPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _phoneNumberError;
  String? _passwordError;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 70,
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.person, size: 70),
            ),
            const SizedBox(height: 30),
            _buildTextField(_firstNameController, l10n.firstName),
            _buildTextField(_lastNameController, l10n.lastName),
            _buildTextField(
              _emailController,
              l10n.email,
              keyboardType: TextInputType.emailAddress,
            ),
            _buildTextField(
              _phoneNumberController,
              l10n.phoneNumber,
              keyboardType: TextInputType.phone,
              errorText: _phoneNumberError,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _showPasswordFields = !_showPasswordFields;
                });
              },
              child: Text(
                _showPasswordFields
                    ? l10n.hidePasswordChange
                    : l10n.changePassword,
              ),
            ),
            if (_showPasswordFields) ...[
              _buildTextField(
                _oldPasswordController,
                l10n.oldPassword,
                obscureText: true,
              ),
              _buildTextField(
                _newPasswordController,
                l10n.newPassword,
                obscureText: true,
              ),
              _buildTextField(
                _confirmPasswordController,
                l10n.confirmNewPassword,
                obscureText: true,
                errorText: _passwordError,
              ),
              ElevatedButton(
                onPressed: () {
                  _changePassword(context);
                },
                child: Text(l10n.changePassword),
              ),
            ],
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                _saveChanges(context);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
                textStyle: const TextStyle(fontSize: 18),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(l10n.saveChanges),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String labelText, {
    TextInputType keyboardType = TextInputType.text,
    String? errorText,
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          errorText: errorText,
        ),
      ),
    );
  }

  void _saveChanges(BuildContext context) async {
    final updatedUser = UserProfile(
      id: widget.user.id,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      profilePhoto: widget.user.profilePhoto,
      favouriteAgencies: widget.user.favouriteAgencies,
    );

    final userService = UserService();
    final errorMessage = await userService.updateUserProfile(updatedUser);

    if (errorMessage == null) {
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
      setState(() {
        _phoneNumberError = errorMessage;
      });
    }
  }

  void _changePassword(BuildContext context) async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() {
        _passwordError = 'Passwords do not match.';
      });
      return;
    }

    final changeCredential = ChangeCredential(
      email: widget.user.email,
      oldPassword: _oldPasswordController.text,
      newPassword: _newPasswordController.text,
    );

    final userService = UserService();
    final errorMessage = await userService.changeUserCredential(
      changeCredential,
    );

    if (errorMessage == null) {
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
      setState(() {
        _passwordError = errorMessage;
      });
    }
  }
}

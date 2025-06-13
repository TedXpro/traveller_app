// lib/screens/reset_password_page.dart
import 'package:flutter/material.dart';
import 'package:traveller_app/services/user_api_services.dart'; // Import your UserService
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import AppLocalizations
import 'package:traveller_app/screens/signin.dart'; // Import SignInPage for navigation
import 'package:traveller_app/utils/validation_utils.dart'; // Import your validation utils (contains isValidEmail and isPasswordSecure)

class ResetPasswordPage extends StatefulWidget {
  // This page needs the email the user entered in the previous step
  final String email;

  const ResetPasswordPage({super.key, required this.email});

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController(); // For confirmation
  bool _isLoading = false;
  bool _isNewPasswordVisible = false; // State for new password visibility
  bool _isConfirmPasswordVisible =
      false; // State for confirm password visibility

  @override
  void dispose() {
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Method to handle the password reset request
  void _handleResetPassword() async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Show a loading indicator while resetting password
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.resettingPassword),
          duration: const Duration(seconds: 10), // Keep visible for a bit
          backgroundColor: Colors.blueAccent, // Indicate ongoing process
        ), // Localize
      );

      try {
        final userService =
            UserService(); // Create an instance of your UserService

        // Call the reset password API method
        // isAgency flag is removed as per your confirmation.
        bool success = await userService.resetPassword(
          email: widget.email, // Use the email passed to the widget
          newPassword:
              _newPasswordController.text.trim(), // Get the new password
          code: _codeController.text.trim(), // Get the code
        );

        if (!mounted) return; // Check mounted after await
        ScaffoldMessenger.of(
          context,
        ).hideCurrentSnackBar(); // Hide the loading SnackBar

        if (success) {
          // Password reset successful
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.passwordResetSuccess)), // Localize
          );
          // Navigate back to the Sign In page and remove all previous routes
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const SignInPage()),
            (Route<dynamic> route) => false, // Remove all routes from the stack
          );
        } else {
          // Password reset failed (e.g., invalid code, email not found)
          // The backend should ideally return a specific error message in the response body.
          // For now, we show a generic failure message.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.passwordResetFailed)), // Localize
          );
        }
      } catch (e) {
        if (!mounted) return; // Check mounted after await
        ScaffoldMessenger.of(
          context,
        ).hideCurrentSnackBar(); // Hide the loading SnackBar
        // Handle network or other errors
        String errorMessage = l10n.unexpectedError;
        if (e is Exception) {
          // Catching generic Exception for broader error handling
          errorMessage =
              "${l10n.passwordResetError}: ${e.toString()}"; // Localize with error details
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
        print("Error resetting password: $e");
      } finally {
        if (!mounted) return; // Check mounted before setState
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.resetPasswordTitle), // Localize title
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow:
                  theme.brightness == Brightness.light
                      ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ]
                      : null,
            ),
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.resetPasswordPrompt(
                      widget.email,
                    ), // Localize prompt with email
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _codeController,
                    keyboardType:
                        TextInputType.number, // Code is likely numeric
                    decoration: InputDecoration(
                      labelText: l10n.codeLabel, // Localize label
                      border: OutlineInputBorder(
                        // Add a border for clarity
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.pleaseEnterCode; // Localize
                      }
                      // Add validation for 12-digit code length if needed
                      if (value.length != 12) {
                        return l10n.invalidCodeLength; // Localize
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _newPasswordController,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: !_isNewPasswordVisible,
                    decoration: InputDecoration(
                      labelText: l10n.newPasswordLabel, // Localize label
                      border: OutlineInputBorder(
                        // Add a border for clarity
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isNewPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isNewPasswordVisible = !_isNewPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.pleaseEnterNewPassword; // Localize
                      }
                      // Add password strength validation here
                      if (!isPasswordSecure(value)) {
                        return l10n.invalidPassword; // Localize
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _confirmPasswordController,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: !_isConfirmPasswordVisible,
                    decoration: InputDecoration(
                      labelText: l10n.confirmPasswordLabel, // Localize label
                      border: OutlineInputBorder(
                        // Add a border for clarity
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.pleaseConfirmPassword; // Localize
                      }
                      if (value != _newPasswordController.text) {
                        return l10n.passwordsDoNotMatch; // Localize
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                        onPressed: _handleResetPassword,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(
                            double.infinity,
                            50,
                          ), // Stretch button
                        ),
                        child: Text(l10n.resetPasswordButton), // Localize
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:traveller_app/models/user.dart';
import 'package:traveller_app/services/user_api_services.dart';
import 'package:traveller_app/screens/signin.dart';
import 'package:traveller_app/utils/validation_utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import AppLocalizations
import 'package:dio/dio.dart'; // Add this import if you're using Dio for HTTP requests

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final UserService _userService = UserService();

  // State variables for password visibility
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    // Clean up controllers
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp(BuildContext context) async {
    // Use a local l10n instance for safety within async function
    final l10n = AppLocalizations.of(context)!;

    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        // Check mounted before using context
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.passwordsDoNotMatch)));
        return;
      }

      final user = User(
        firstName: _firstNameController.text.trim(), // Trim whitespace
        lastName: _lastNameController.text.trim(), // Trim whitespace
        email:_emailController.text.trim(),
        password: _passwordController.text, // Don't trim password
      );

      try {
        final newUser = await _userService.signup(user);

        // Check mounted after await before using context
        if (!mounted) return;

        if (newUser != null) {
          _showVerificationDialog(context, l10n);
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.signUpFailed)));
        }
      } catch (e) {
        // Check mounted before using context
        if (!mounted) return;

        // --- DEBUGGING STEP: Print the exact error to console ---
        print('Raw signup error: $e');
        if (e is DioException) {
          print('DioException response data: ${e.response?.data}');
          print('DioException response status code: ${e.response?.statusCode}');
        }
        // --- END DEBUGGING STEP ---

        String friendlyMessage;
        String backendErrorMessage = '';

        // Extract the error message from DioException if applicable
        if (e is DioException && e.response?.data != null) {
          // Assuming backend sends {"error": "some message"}
          if (e.response!.data is Map &&
              e.response!.data.containsKey('error')) {
            backendErrorMessage =
                e.response!.data['error'].toString().toLowerCase();
          } else {
            backendErrorMessage = e.response!.data.toString().toLowerCase();
          }
        } else {
          backendErrorMessage = e.toString().toLowerCase();
        }

        if (backendErrorMessage.contains('user already exists')) {
          friendlyMessage = l10n.userAlreadyExists;
        } else if (backendErrorMessage.contains(
          'registration is waiting email verification',
        )) {
          friendlyMessage = l10n.registrationPendingVerification;
          _showVerificationDialog(
            context,
            l10n,
          ); // Re-show dialog for this specific case
        } else {
          // Generic error message for other unexpected errors
          // It's often better to show a more general "Something went wrong"
          // unless the raw error is truly helpful to the user.
          friendlyMessage =
              l10n.signUpFailedGeneric; // Use a more generic localized message
          print('Unhandled signup error: $e'); // Keep logging unhandled errors
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(friendlyMessage)));
      }
    }
  }

  void _showVerificationDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.verificationEmailSent),
          content: Text(l10n.verificationEmailContent),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.ok),
              onPressed: () {
                if (!mounted) return;
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => SignInPage()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 350,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow:
                  theme.brightness == Brightness.light
                      ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ]
                      : null,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.createAccount,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildInputField(l10n.firstName, _firstNameController, l10n),
                  _buildInputField(l10n.lastName, _lastNameController, l10n),
                  _buildInputField(l10n.email, _emailController, l10n),
                  _buildInputField(
                    l10n.password,
                    _passwordController,
                    l10n,
                    isPassword: true,
                    isVisible: _isPasswordVisible,
                    toggleVisibility: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  _buildInputField(
                    l10n.confirmPassword,
                    _confirmPasswordController,
                    l10n,
                    isPassword: true,
                    isVisible: _isConfirmPasswordVisible,
                    toggleVisibility: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _signUp(context),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Text(l10n.signUp),
                  ),
                  const SizedBox(height: 10),
                  const SizedBox(
                    height: 15,
                  ), // Adjusted spacing after removing Google button
                  _buildAlreadyHaveAccount(context, l10n, theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    AppLocalizations l10n, {
    bool isPassword = false,
    bool? isVisible,
    VoidCallback? toggleVisibility,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? !(isVisible ?? false) : false,
        keyboardType:
            isPassword
                ? TextInputType.visiblePassword
                : (label == l10n.email
                    ? TextInputType.emailAddress
                    : (label == l10n.phoneNumber
                        ? TextInputType.phone
                        : TextInputType.text)),
        decoration: InputDecoration(
          labelText: label,
          errorMaxLines: 3,
          suffixIcon:
              isPassword && toggleVisibility != null
                  ? IconButton(
                    icon: Icon(
                      isVisible == true
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: toggleVisibility,
                  )
                  : null,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return l10n.thisFieldRequired;
          }

          if (label == l10n.email && !isValidEmail(value)) {
            return l10n.validEmail;
          }

          if (label == l10n.phoneNumber && !isValidPhoneNumber(value)) {
            return l10n.validPhone;
          }

          if ((label == l10n.firstName || label == l10n.lastName) &&
              !isValidName(value)) {
            if (label == l10n.firstName && !isValidName(value)) {
              return l10n.validFirstName;
            }
            if (label == l10n.lastName && !isValidName(value)) {
              return l10n.validLastName;
            }
          }

          if (isPassword && !isPasswordSecure(value)) {
            return l10n.securePassword;
          }
          return null;
        },
      ),
    );
  }

  Widget _buildAlreadyHaveAccount(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            l10n.alreadyHaveAccount,
            style: theme.textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TextButton(
          onPressed: () {
            if (!mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SignInPage()),
            );
          },
          child: Text(l10n.signIn, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

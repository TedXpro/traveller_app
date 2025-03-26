// signin.dart
import 'dart:io'; // Keep this import for SocketException

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart'
    as http; // Keep this import for http client/socket exceptions
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traveller_app/models/email_credential.dart';
import 'package:traveller_app/models/login_response.dart';
import 'package:traveller_app/providers/user_provider.dart'; // Import UserProvider
import 'package:traveller_app/screens/forgot_password_email_dialog.dart';
import 'package:traveller_app/screens/main_screen.dart';
import 'package:traveller_app/screens/signup.dart';
import 'package:traveller_app/services/user_api_services.dart'; // Assuming UserService is here
import 'package:traveller_app/utils/validation_utils.dart'; // Assuming validation_utils is here
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import AppLocalizations
import 'package:traveller_app/screens/reset_password_page.dart'; // Import the ResetPasswordPage

// Assuming JwtDecoder is imported or available globally if needed for decoding token payload
// import 'package:jwt_decoder/jwt_decoder.dart'; // Example import if needed

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = false;
  bool _isPasswordVisible = false; // State variable for password visibility

  // Dispose controllers
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void handleLogin() async {
    // Use a local l10n instance for safety within async function
    // Check mounted early if needed
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        EmailCredential credentials = EmailCredential(
          email: _emailController.text.trim(),
          password:
              _passwordController.text
                  .trim(), // Do not trim password if exact match is needed
        );

        LoginResponse? loginResponse = await UserService().login(credentials);

        // --- IMPORTANT: Check mounted AFTER await before using context ---
        if (!mounted) return;
        // -------------------------------------------------------------------

        if (loginResponse != null) {
          final prefs = await SharedPreferences.getInstance();
          if (_rememberMe) {
            prefs.setString('rememberedEmail', _emailController.text.trim());
            // Note: Storing password in SharedPreferences is generally NOT recommended for security reasons.
            // Consider alternative secure storage or re-authenticating users.
            prefs.setString(
              'rememberedPassword',
              _passwordController.text.trim(), // Still not recommended
            );
          } else {
            prefs.remove('rememberedEmail');
            prefs.remove('rememberedPassword');
          }

          await Provider.of<UserProvider>(
            context,
            listen: false,
          ).setUserDataAndToken(
            loginResponse.user,
            loginResponse.token,
          ); // Pass both user and token
          // -------------------------------------------------

          // Check mounted before using context with Provider
          if (!mounted) return;
          // It's generally better to fetch initial data like destinations
          // in the MainScreen's initState using addPostFrameCallback,
          // as we discussed previously, to avoid setState during build.
          // Removing the direct call here. Ensure MainScreen handles this.
          // await Provider.of<DestinationProvider>(
          //   context,
          //   listen: false,
          // ).fetchDestinations();

          // Check mounted after await before using context
          if (!mounted) return;

          // Get FCM token after successful login
          String? fcmToken = await FirebaseMessaging.instance.getToken();

          // Check mounted after await before using context
          if (!mounted) return;

          if (fcmToken != null) {
            // Send the FCM token to your backend
            // Consider adding mounted check here if storeFCMToken is async and uses context
            // Ensure storeFCMToken accepts the JWT token for authentication if needed
            await UserService().storeFCMToken(
              userId: loginResponse.user.id!,
              fcmToken: fcmToken,
              jwtToken: loginResponse.token,
            );
          } else {
            print('Failed to get FCM token during login.');
            // Optionally handle this error
          }

          // Check mounted before navigating
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()),
          );
        } else {
          // Check mounted before showing SnackBar
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.incorrectEmailOrPassword)),
          );
        }
      } catch (e) {
        // Check mounted before using context
        if (!mounted) return;
        String errorMessage = l10n.unexpectedError;
        // Check exception types using the package:http alias
        if (e is http.ClientException || e is SocketException) {
          // SocketException is from dart:io, ensure import is correct
          errorMessage = l10n.networkError; // Localized network error
        } else {
          // Consider localizing other specific error types if needed
          // Ensure l10n.signInError exists and takes a String parameter
          // errorMessage = l10n.signInError(e.toString()); // Example if signInError takes param
          errorMessage = "${l10n.unexpectedError}: ${e.toString()}";
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
        print("Error: $e");
      } finally {
        // Check mounted before calling setState in finally
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      // If validation fails, stop loading animation if it was started
      if (_isLoading && mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Method to handle the "Forgot Password?" tap and API call
  void _handleForgotPassword(AppLocalizations l10n) async {
    // Show the email input dialog and wait for the result
    final String? email = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return const ForgotPasswordEmailDialog();
      },
    );

    // If an email was entered and returned from the dialog
    if (email != null && email.isNotEmpty) {
      print('Forgot password initiated for email: $email');

      // Show a loading indicator while requesting the code
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.requestingResetCode),
          duration: const Duration(seconds: 10), // Keep visible for a bit
          backgroundColor: Colors.blueAccent,
        ), // Localize
      );

      try {
        final userService = UserService();
        bool success = await userService.requestPasswordResetCode(
          email: email,
        ); // Adjust isAgency

        // Check mounted after await before using context
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).hideCurrentSnackBar(); // Hide the loading SnackBar

        if (success) {
          // Code request successful, navigate to the next page
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.forgotPasswordEmailSent(email)),
            ), // Localize success message
          );
          // Navigate to the ResetPasswordPage, passing the email
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ResetPasswordPage(email: email), // Pass email
            ),
          );
        } else {
          // Code request failed (e.g., email not found)
          // The backend should ideally return a specific error message in the response body.
          // For now, show a generic failure message.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.forgotPasswordRequestFailed),
            ), // Localize failure message
          );
        }
      } catch (e) {
        // Check mounted after await before using context
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).hideCurrentSnackBar(); // Hide the loading SnackBar
        // Handle network or other errors during the API call
        String errorMessage = l10n.unexpectedError;
        if (e is Exception) {
          // Catching generic Exception for broader error handling
          errorMessage =
              "${l10n.forgotPasswordRequestError}: ${e.toString()}"; // Localize with error details
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
        print("Error requesting password reset code: $e");
      }
    } else {
      print('Forgot password dialog cancelled or no email entered.');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadRememberedCredentials();
  }

  Future<void> _loadRememberedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    // Check mounted after await before calling setState
    if (!mounted) return;
    setState(() {
      _emailController.text = prefs.getString('rememberedEmail') ?? '';
      _passwordController.text = prefs.getString('rememberedPassword') ?? '';
      _rememberMe =
          prefs.getString('rememberedEmail') != null &&
          prefs
              .getString('rememberedEmail')!
              .isNotEmpty; // Check if email is not empty
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors:
                isDarkMode
                    ? [
                      Colors.grey.shade900,
                      Colors.grey.shade800,
                      Colors.grey.shade700,
                    ]
                    : [Colors.blue.shade50, Colors.white, Colors.white],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(32),
              margin: const EdgeInsets.all(20),
              width: MediaQuery.of(context).size.width * 0.9,
              constraints: const BoxConstraints(maxWidth: 500),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.account_circle,
                        size: 60,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.signIn,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: l10n.email,
                        prefixIcon: Icon(
                          Icons.email,
                          color: theme.colorScheme.primary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: theme.cardColor,
                      ),
                      validator: (value) => validateEmail(value, l10n),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: l10n.password,
                        prefixIcon: Icon(
                          Icons.lock,
                          color: theme.colorScheme.primary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: theme.cardColor,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: theme.colorScheme.primary,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: (value) => validatePassword(value, l10n),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value!;
                                });
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            Text(
                              l10n.rememberMe,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () => _handleForgotPassword(l10n),
                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
                          child: Text(
                            l10n.forgotPassword,
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                          onPressed: handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            minimumSize: const Size(double.infinity, 50),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            l10n.signIn,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: theme.dividerColor,
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            l10n.or,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: theme.dividerColor,
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.dontHaveAnAccount,
                          style: theme.textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: () {
                            if (!mounted) return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignUpPage(),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                          ),
                          child: Text(
                            l10n.signUp,
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Your existing email validation function (make sure it's accessible or copied here)
  String? validateEmail(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) {
      return l10n.pleaseEnterEmail; // Localized
    }
    // Assuming isValidEmail is a function in your validation_utils.dart
    if (!isValidEmail(value)) {
      return l10n.validEmail; // Localized
    }
    return null;
  }

  // Your existing password validation function (make sure it's accessible or copied here)
  String? validatePassword(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) {
      return l10n.pleaseEnterPassword; // Localized
    }
    // For sign-in, you might not need the full security check here, just that it's not empty.
    // If you want to add security check here, uncomment the line below and ensure isPasswordSecure is available.
    // if (!isPasswordSecure(value)) { return l10n.invalidPassword; } // Localize
    return null;
  }

  Widget _buildGoogleSignUpButton(AppLocalizations l10n) {
    // Access theme for potential future styling or consistency
    final theme = Theme.of(context);

    return ElevatedButton(
      // Keep specific Google branding colors and minimum size, others from theme
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white, // Google brand color
        foregroundColor: Colors.black, // Google brand color
        minimumSize: const Size(double.infinity, 50), // Keep specific size
        // Remove other style properties like padding, shape, elevation
        // as they are handled by the theme or the minimumSize implicitly
        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Example override
      ),
      onPressed: () {
        // TODO: Handle Google Sign Up
        print('Sign Up with Google');
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ensure Google logo asset exists and is correctly placed
          Image.asset('assets/google_logo.png', height: 20),
          const SizedBox(width: 10),
          // Text color is set by ElevatedButton.styleFrom foregroundColor
          Text(l10n.signUpWithGoogle), // Localized
        ],
      ),
    );
  }
}

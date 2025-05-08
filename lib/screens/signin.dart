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
import 'package:traveller_app/providers/destination_provider.dart';
import 'package:traveller_app/providers/user_provider.dart';
import 'package:traveller_app/screens/main_screen.dart';
import 'package:traveller_app/screens/signup.dart';
import 'package:traveller_app/services/user_api_services.dart';
import 'package:traveller_app/utils/validation_utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import AppLocalizations

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
          prefs.setString('authToken', loginResponse.token);

          // Check mounted before using context with Provider
          if (!mounted) return;
          Provider.of<UserProvider>(
            context,
            listen: false,
          ).setUserData(loginResponse.user);

          // Check mounted before using context with Provider
          if (!mounted) return;
          await Provider.of<DestinationProvider>(
            context,
            listen: false,
          ).fetchDestinations();

          // Check mounted after await before using context
          if (!mounted) return;

          // Get FCM token after successful login
          String? fcmToken = await FirebaseMessaging.instance.getToken();

          // Check mounted after await before using context
          if (!mounted) return;

          if (fcmToken != null) {
            // Send the FCM token to your backend
            // Consider adding mounted check here if storeFCMToken is async and uses context
            await UserService().storeFCMToken(
              userId: loginResponse.user.id!,
              fcmToken: fcmToken,
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
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
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.signIn,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    keyboardType:
                        TextInputType.emailAddress, // Correct keyboard type
                    decoration: InputDecoration(
                      labelText: l10n.email,
                      // Input decoration styling will pick up theme.inputDecorationTheme automatically
                      // border: OutlineInputBorder(), // Removed
                    ),
                    validator:
                        (value) => validateEmail(value, l10n), // Pass l10n
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _passwordController,
                    keyboardType:
                        TextInputType.visiblePassword, // Correct keyboard type
                    obscureText: !_isPasswordVisible, // Use state variable here
                    decoration: InputDecoration(
                      labelText: l10n.password, // Localized
                      // Input decoration styling will pick up theme.inputDecorationTheme automatically
                      // border: OutlineInputBorder(), // Removed
                      suffixIcon: IconButton(
                        // Add the toggle button
                        icon: Icon(
                          // Change icon based on password visibility
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          // Icon color will inherit from theme.inputDecorationTheme.suffixIconColor
                        ),
                        onPressed: () {
                          // Toggle the state variable
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator:
                        (value) => validatePassword(value, l10n), // Pass l10n
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Wrap the "Remember Me" row in Flexible
                      Flexible(
                        child: Row(
                          mainAxisSize:
                              MainAxisSize.min, // Use min size for inner row
                          children: [
                            // Checkbox styling will pick up theme.checkboxTheme automatically
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value!;
                                });
                              },
                            ),
                            // Use theme's text style and Flexible to prevent overflow
                            Flexible(
                              child: Text(
                                // Keep Flexible for text within the inner row
                                l10n.rememberMe,
                                style: theme.textTheme.bodyMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ), // Localized
                          ],
                        ),
                      ),
                      // Wrap the "Forgot Password?" TextButton in Flexible
                      Flexible(
                        child: TextButton(
                          onPressed: () {
                            // TODO: Implement forgot password functionality
                          },
                          child: Text(
                            l10n.forgotPassword,
                            overflow: TextOverflow.ellipsis,
                          ), // Localized
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _isLoading
                      ? const Center(
                        child: CircularProgressIndicator(),
                      ) // Progress indicator will use theme colors
                      : ElevatedButton(
                        onPressed: handleLogin,
                        // Set minimumSize to stretch the button horizontally
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          // Theme's background, foreground, shape, padding will apply
                          // if not explicitly set here.
                          // e.g. backgroundColor: theme.elevatedButtonTheme.style?.backgroundColor?.resolve({MaterialState.pressed}),
                          // It's often simplest to let the theme handle these entirely
                          // unless a specific override (like size or branded color) is needed.
                        ),
                        child: Text(l10n.signIn), // Localized
                      ),
                  const SizedBox(height: 20),
                  // Use theme's text style for the 'or' separator
                  Center(child: Text('or', style: theme.textTheme.bodyMedium)),
                  const SizedBox(height: 10),
                  _buildGoogleSignUpButton(l10n), // Pass l10n
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Use theme's text style and Flexible to prevent overflow
                      Flexible(
                        // Keep Flexible for this text
                        child: Text(
                          l10n.dontHaveAnAccount,
                          style: theme.textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ), // Localized
                      TextButton(
                        onPressed: () {
                          // Check mounted before navigating
                          if (!mounted) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignUpPage(),
                            ),
                          );
                        },
                        child: Text(
                          l10n.signUp,
                          overflow: TextOverflow.ellipsis,
                        ), // Localized
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? validateEmail(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) {
      return l10n.pleaseEnterEmail; // Localized
    }
    // isValidEmail should likely be theme-independent validation logic
    if (!isValidEmail(value)) {
      return l10n.validEmail; // Localized
    }
    return null;
  }

  String? validatePassword(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) {
      return l10n.pleaseEnterPassword; // Localized
    }
    // Add more complex password validation if needed (like isPasswordSecure check)
    // isPasswordSecure should likely be theme-independent validation logic
    // For sign-in, you might not need the full security check here, just that it's not empty.
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

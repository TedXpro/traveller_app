import 'dart:io' as http;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

  void handleLogin() async {
    final l10n = AppLocalizations.of(context)!; // Get AppLocalizations instance

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        EmailCredential credentials = EmailCredential(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        LoginResponse? loginResponse = await UserService().login(credentials);

        if (loginResponse != null) {
          final prefs = await SharedPreferences.getInstance();
          if (_rememberMe) {
            prefs.setString('rememberedEmail', _emailController.text.trim());
            prefs.setString(
              'rememberedPassword',
              _passwordController.text.trim(),
            );
          } else {
            prefs.remove('rememberedEmail');
            prefs.remove('rememberedPassword');
          }
          prefs.setString('authToken', loginResponse.token);

          Provider.of<UserProvider>(
            context,
            listen: false,
          ).setUserData(loginResponse.user);

          await Provider.of<DestinationProvider>(
            context,
            listen: false,
          ).fetchDestinations();

          // Get FCM token after successful login
          String? fcmToken = await FirebaseMessaging.instance.getToken();
          if (fcmToken != null) {
            // Send the FCM token to your backend
            await UserService().storeFCMToken(userId: loginResponse.user.id!, fcmToken: fcmToken);
          } else {
            print('Failed to get FCM token during login.');
            // Optionally handle this error
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.incorrectEmailOrPassword)), // Localized
          );
        }
      } catch (e) {
        String errorMessage = l10n.unexpectedError; // Default localized message
        if (e is http.ClientException || e is http.SocketException) {
          errorMessage = l10n.networkError; // Localized network error
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
        print("Error: $e");
      } finally {
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
    setState(() {
      _emailController.text = prefs.getString('rememberedEmail') ?? '';
      _passwordController.text = prefs.getString('rememberedPassword') ?? '';
      _rememberMe = prefs.getString('rememberedEmail') != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // Get AppLocalizations instance

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.signIn, // Localized
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: l10n.email, // Localized
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => validateEmail(value, l10n), // Pass l10n
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: l10n.password, // Localized
                    border: OutlineInputBorder(),
                  ),
                  validator:
                      (value) => validatePassword(value, l10n), // Pass l10n
                ),
                const SizedBox(height: 10),
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
                        ),
                        Text(l10n.rememberMe), // Localized
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: Implement forgot password functionality
                      },
                      child: Text(l10n.forgotPassword), // Localized
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                      onPressed: handleLogin,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: Text(l10n.signIn), // Localized
                    ),
                const SizedBox(height: 20),
                const Center(child: Text('or')),
                const SizedBox(height: 10),
                _buildGoogleSignUpButton(),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(l10n.dontHaveAnAccount), // Localized
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUpPage()),
                        );
                      },
                      child: Text(l10n.signUp), // Localized
                    ),
                  ],
                ),
              ],
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
    if (!isValidEmail(value)) {
      return l10n.validEmail; // Localized
    }
    return null;
  }

  String? validatePassword(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) {
      return l10n.pleaseEnterPassword; // Localized
    }
    // Add more complex password validation if needed
    return null;
  }

  Widget _buildGoogleSignUpButton() {
    final l10n = AppLocalizations.of(context)!; // Get AppLocalizations instance

    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
      onPressed: () {
        // TODO: Handle Google Sign Up
        print('Sign Up with Google');
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/google_logo.png', height: 20),
          const SizedBox(width: 10),
          Text(
            l10n.signUpWithGoogle, // Localized
            style: TextStyle(color: Colors.black),
          ),
        ],
      ),
    );
  }
}

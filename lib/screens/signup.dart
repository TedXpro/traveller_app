import 'package:flutter/material.dart';
import 'package:traveller_app/models/user.dart';
import 'package:traveller_app/services/user_api_services.dart';
import 'package:traveller_app/screens/signin.dart';
import 'package:traveller_app/utils/validation_utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import AppLocalizations

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  String? _loginPreference = 'Email';
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final UserService _userService = UserService();

  Future<void> _signUp(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!; // Get AppLocalizations instance

    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.passwordsDoNotMatch)));
        return;
      }

      final user = User(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        loginPreference: _loginPreference,
        email: _loginPreference == 'Email' ? _emailController.text : null,
        phoneNumber: _loginPreference == 'Phone' ? _phoneController.text : null,
        password: _passwordController.text,
      );

      try {
        final newUser = await _userService.signup(user);
        if (newUser != null) {
          _showVerificationDialog(context, l10n); // Pass l10n
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.signUpFailed)));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.signUpError(e.toString())),
          ),
        );
      }
    }
  }

  void _showVerificationDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.verificationEmailSent),
          content: Text(l10n.verificationEmailContent),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.ok),
              onPressed: () {
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
    final l10n = AppLocalizations.of(context)!; // Get AppLocalizations instance

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 350,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.createAccount,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  _buildInputField(l10n.firstName, _firstNameController, l10n),
                  _buildInputField(l10n.lastName, _lastNameController, l10n),
                  _buildLoginPreference(l10n),
                  _loginPreference == 'Email'
                      ? _buildInputField(l10n.email, _emailController, l10n)
                      : _buildInputField(
                        l10n.phoneNumber,
                        _phoneController,
                        l10n,
                      ),
                  _buildInputField(
                    l10n.password,
                    _passwordController,
                    l10n,
                    isPassword: true,
                  ),
                  _buildInputField(
                    l10n.confirmPassword,
                    _confirmPasswordController,
                    l10n,
                    isPassword: true,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _signUp(context),
                    child: Text(l10n.signUp),
                  ),
                  const SizedBox(height: 10),
                  _buildGoogleSignUpButton(l10n),
                  const SizedBox(height: 15),
                  _buildAlreadyHaveAccount(context, l10n),
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
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          errorMaxLines: 3,
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

          if (label == l10n.firstName && !isValidName(value)) {
            return l10n.validFirstName;
          }

          if (label == l10n.lastName && !isValidName(value)) {
            return l10n.validLastName;
          }

          if (isPassword && !isPasswordSecure(value)) {
            return l10n.securePassword;
          }

          return null;
        },
      ),
    );
  }

  Widget _buildLoginPreference(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text('${l10n.loginPreference}: '),
        DropdownButton<String>(
          value: _loginPreference,
          items:
              ['Email', 'Phone'].map((option) {
                return DropdownMenuItem(
                  value: option,
                  child: Text(
                    option == 'Email' ? l10n.emailOption : l10n.phoneOption,
                  ),
                );
              }).toList(),
          onChanged: (value) {
            setState(() {
              _loginPreference = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildGoogleSignUpButton(AppLocalizations l10n) {
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
          Text(l10n.signUpWithGoogle, style: TextStyle(color: Colors.black)),
        ],
      ),
    );
  }

  Widget _buildAlreadyHaveAccount(BuildContext context, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(l10n.alreadyHaveAccount),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SignInPage()),
            );
          },
          child: Text(l10n.signIn),
        ),
      ],
    );
  }
}

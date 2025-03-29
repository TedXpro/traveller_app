import 'package:flutter/material.dart';
import 'package:traveller_app/models/user.dart';
import 'package:traveller_app/services/user_api_services.dart';
import 'signin.dart';

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
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
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
          _showVerificationDialog(context); // Show verification message
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Sign up failed')));
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Sign up error: $e')));
      }
    }
  }

  void _showVerificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Verification Email Sent'),
          content: const Text(
            'A verification email has been sent to your account. Please check your inbox (and spam folder) to verify your email address.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
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
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
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
                const Text(
                  'Create an Account',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                _buildInputField('First Name', _firstNameController),
                _buildInputField('Last Name', _lastNameController),
                _buildLoginPreference(),
                _loginPreference == 'Email'
                    ? _buildInputField('Email', _emailController)
                    : _buildInputField('Phone Number', _phoneController),
                _buildInputField(
                  'Password',
                  _passwordController,
                  isPassword: true,
                ),
                _buildInputField(
                  'Confirm Password',
                  _confirmPasswordController,
                  isPassword: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _signUp(context),
                  child: const Text('Sign Up'),
                ),
                const SizedBox(height: 10),
                _buildGoogleSignUpButton(),
                const SizedBox(height: 15),
                _buildAlreadyHaveAccount(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller, {
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
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }

          if (label == 'Email' && !value.contains('@')) {
            return 'Enter a valid email address';
          }

          if (label == "Phone Number" && value.length < 10) {
            return "Enter a valid phone number";
          }

          if (label == "First Name" && (value.isEmpty || value.length > 50)) {
            return "First Name must be between 1 and 50 characters";
          }

          if (label == "Last Name" && (value.isEmpty || value.length > 50)) {
            return "Last Name must be between 1 and 50 characters";
          }
          return null;
        },
      ),
    );
  }

  Widget _buildLoginPreference() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Text('Login Preference: '),
        DropdownButton<String>(
          value: _loginPreference,
          items:
              ['Email', 'Phone'].map((option) {
                return DropdownMenuItem(value: option, child: Text(option));
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

  Widget _buildGoogleSignUpButton() {
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
          const Text(
            'Sign Up with Google',
            style: TextStyle(color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildAlreadyHaveAccount(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Already have an account?'),
        TextButton(
          onPressed: () {
            // Navigate to Sign Up
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SignInPage()),
            );
          },
          child: const Text('Sign In'),
        ),
      ],
    );
  }
}

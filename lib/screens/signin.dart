import 'package:flutter/material.dart';
import 'package:traveller_app/models/email_credential.dart';
import 'package:traveller_app/screens/home.dart';
import 'package:traveller_app/screens/signup.dart';
import 'package:traveller_app/services/user_api_services.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = false;

  void handleLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      EmailCredential credentials = EmailCredential(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      bool isSuccess = await UserService().login(credentials);

      if (isSuccess) {
        print("Login successful!");

        // Navigate to home page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Login failed. Please check your credentials."),
          ),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred. Please try again.")),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Light background color
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width * 0.9, // Responsive width
          constraints: const BoxConstraints(
            maxWidth: 400,
          ), // Limit max width for desktop
          decoration: BoxDecoration(
            color: Colors.white, // White card background
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Fit content
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sign In',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
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
                      const Text('Remember Me'),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Implement forgot password functionality
                    },
                    child: const Text('Forgot Password?'),
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
                    child: const Text('Sign In'),
                  ),
              const SizedBox(height: 20),
              const Center(child: Text('or')),
              const SizedBox(height: 10),
              _buildGoogleSignUpButton(),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      // Navigate to Sign Up
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpPage()),
                      );
                    },
                    child: const Text('Sign Up'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
}

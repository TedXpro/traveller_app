// signup.dart
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

  String? _loginPreference =
      'Email'; // Consider making this nullable initially or use a default from options
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

      // Basic validation for login preference selection (redundant with TextFormField but okay)
      if (_loginPreference == 'Email' && _emailController.text.trim().isEmpty) {
        // Handled by validator
      }
      if (_loginPreference == 'Phone' && _phoneController.text.trim().isEmpty) {
        // Handled by validator
      }

      final user = User(
        firstName: _firstNameController.text.trim(), // Trim whitespace
        lastName: _lastNameController.text.trim(), // Trim whitespace
        loginPreference: _loginPreference,
        email:
            _loginPreference == 'Email' ? _emailController.text.trim() : null,
        phoneNumber:
            _loginPreference == 'Phone' ? _phoneController.text.trim() : null,
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.signUpError(e.toString()))));
      }
    }
  }

  void _showVerificationDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        final theme = Theme.of(
          dialogContext,
        ); 

        return AlertDialog(
          title: Text(
            l10n.verificationEmailSent,
          ),
          content: Text(
            l10n.verificationEmailContent,
          ),
          actions: <Widget>[
            TextButton(
              // TextButton style will pick up theme.textButtonTheme automatically
              child: Text(l10n.ok),
              onPressed: () {
                // Check mounted before navigating (using context from the main State, not dialogContext)
                // While navigating from dialog actions is common, checking 'mounted' here is safest practice
                if (!mounted) return;
                Navigator.of(context).pushReplacement(
                  // Use context from the State, not dialogContext
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
              borderRadius: BorderRadius.circular(
                20,
              ), 
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
                  // General input fields
                  _buildInputField(l10n.firstName, _firstNameController, l10n),
                  _buildInputField(l10n.lastName, _lastNameController, l10n),
                  _buildLoginPreference(l10n, theme), // Pass theme
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
                      minimumSize: const Size(
                        double.infinity,
                        50,
                      ), // Keep full width and height
                    ),
                    child: Text(l10n.signUp),
                  ),
                  const SizedBox(height: 10),
                  _buildGoogleSignUpButton(l10n), // Pass l10n if needed inside
                  const SizedBox(height: 15),
                  _buildAlreadyHaveAccount(context, l10n, theme), // Pass theme
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
    bool? isVisible, // Added
    VoidCallback? toggleVisibility, // Added
  }) {
    // Input decoration styling will pick up theme.inputDecorationTheme automatically
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        // Use isVisible state if it's a password field
        obscureText: isPassword ? !(isVisible ?? false) : false,
        keyboardType:
            isPassword
                ? TextInputType.visiblePassword
                : (label == l10n.email
                    ? TextInputType.emailAddress
                    : (label == l10n.phoneNumber
                        ? TextInputType.phone
                        : TextInputType
                            .text)), 
        decoration: InputDecoration(
          labelText: label,
          errorMaxLines: 3,
          // Add suffix icon only if it's a password field
          suffixIcon:
              isPassword && toggleVisibility != null
                  ? IconButton(
                    icon: Icon(
                      isVisible == true
                          ? Icons.visibility
                          : Icons.visibility_off,
                      // Icon color will inherit from theme.inputDecorationTheme.suffixIconColor
                    ),
                    onPressed:
                        toggleVisibility, // Use the passed toggle function
                  )
                  : null, // No suffix icon for non-password fields
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

          // Need to handle password confirmation validation outside individual field validator
          // if (label == l10n.confirmPassword && value != _passwordController.text) {
          //   return l10n.passwordsDoNotMatch;
          // }

          return null;
        },
      ),
    );
  }

  // Pass Theme to the login preference builder
  Widget _buildLoginPreference(AppLocalizations l10n, ThemeData theme) {
    return Padding(
      // Wrap in Padding for consistent vertical spacing
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Use theme's text style for the label
          Text('${l10n.loginPreference}: ', style: theme.textTheme.bodyMedium),
          // DropdownButton styling will pick up theme.dropdownMenuTheme automatically
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
      ),
    );
  }

  Widget _buildGoogleSignUpButton(AppLocalizations l10n) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white, 
        foregroundColor: Colors.black, 
        minimumSize: const Size(double.infinity, 50), 
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

  // Pass Theme to the link builder
  Widget _buildAlreadyHaveAccount(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Use theme's text style and Flexible to prevent overflow
        Flexible(
          // Wrap text in Flexible
          child: Text(
            l10n.alreadyHaveAccount,
            style: theme.textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ), // Localized, add overflow
        ),
        TextButton(
          // TextButton style will pick up theme.textButtonTheme automatically
          onPressed: () {
            // Check mounted before navigating
            if (!mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SignInPage()),
            );
          },
          // Add overflow to the Text within the TextButton for safety
          child: Text(
            l10n.signIn,
            overflow: TextOverflow.ellipsis,
          ), // Localized, add overflow
        ),
      ],
    );
  }
}

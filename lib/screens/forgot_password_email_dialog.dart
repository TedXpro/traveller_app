// lib/widgets/auth/forgot_password_email_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import AppLocalizations
import 'package:traveller_app/utils/validation_utils.dart'; // Import your validation utils

class ForgotPasswordEmailDialog extends StatefulWidget {
  const ForgotPasswordEmailDialog({super.key});

  @override
  _ForgotPasswordEmailDialogState createState() =>
      _ForgotPasswordEmailDialogState();
}

class _ForgotPasswordEmailDialogState extends State<ForgotPasswordEmailDialog> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Form key for validation

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // Access localization

    return AlertDialog(
      title: Text(l10n.forgotPasswordTitle), // Localize title
      content: Form(
        // Wrap content in a Form for validation
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min, // Make the column take minimum space
          children: [
            Text(l10n.forgotPasswordEmailPrompt), // Localize prompt text
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: l10n.email, // Localize label
                border: OutlineInputBorder(
                  // Add a border for clarity in dialog
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              validator:
                  (value) =>
                      validateEmail(value, l10n), // Use your email validation
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text(l10n.cancelButton), // Localize button
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // If the form is valid, return the email
              Navigator.of(context).pop(_emailController.text.trim());
            }
          },
          child: Text(l10n.sendCodeButton), // Localize button
        ),
      ],
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
}

// TODO: Add localization strings for:
// - forgotPasswordTitle
// - forgotPasswordEmailPrompt
// - cancelButton
// - sendCodeButton
// - pleaseEnterEmail (if not already present)
// - validEmail (if not already present)
// TODO: Ensure validateEmail function is accessible or included.
// TODO: Ensure validation_utils.dart is imported correctly.

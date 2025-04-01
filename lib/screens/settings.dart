import 'package:flutter/material.dart';
import 'package:traveller_app/utils/theme_utils.dart'; // Import theme_utils.dart

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: const Text('Theme'),
              subtitle: const Text('Change app theme'),
              onTap: () {
                // showThemePickerDialog(context); // Trigger theme dialog
              },
            ),
            // Add other settings options here...
          ],
        ),
      ),
    );
  }
}

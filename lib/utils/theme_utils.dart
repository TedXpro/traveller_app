import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traveller_app/providers/theme_provider.dart';

Future<void> showThemePickerDialog(BuildContext context) async {
  final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
  ThemeMode selectedThemeMode = themeProvider.themeMode;

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: const Text('Choose Theme'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<ThemeMode>(
                  title: const Text('Light'),
                  value: ThemeMode.light,
                  groupValue: selectedThemeMode,
                  onChanged: (ThemeMode? value) {
                    if (value != null) {
                      setState(() {
                        selectedThemeMode = value;
                      });
                    }
                  },
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Dark'),
                  value: ThemeMode.dark,
                  groupValue: selectedThemeMode,
                  onChanged: (ThemeMode? value) {
                    if (value != null) {
                      setState(() {
                        selectedThemeMode = value;
                      });
                    }
                  },
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('System Default'),
                  value: ThemeMode.system,
                  groupValue: selectedThemeMode,
                  onChanged: (ThemeMode? value) {
                    if (value != null) {
                      setState(() {
                        selectedThemeMode = value;
                      });
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  themeProvider.setThemeMode(selectedThemeMode);
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    },
  );
}

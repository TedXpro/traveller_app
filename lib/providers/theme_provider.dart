// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ThemeProvider with ChangeNotifier {
//   ThemeMode _themeMode = ThemeMode.system; // Default to system

//   ThemeMode get themeMode => _themeMode;

//   Future<void> setThemeMode(ThemeMode themeMode) async {
//     _themeMode = themeMode;
//     notifyListeners();
//     // Persist theme mode using SharedPreferences
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('themeMode', themeMode.toString());
//   }

//   Future<void> loadThemeMode() async {
//     final prefs = await SharedPreferences.getInstance();
//     final themeString = prefs.getString('themeMode');

//     if (themeString != null) {
//       switch (themeString) {
//         case 'ThemeMode.light':
//           _themeMode = ThemeMode.light;
//           break;
//         case 'ThemeMode.dark':
//           _themeMode = ThemeMode.dark;
//           break;
//         case 'ThemeMode.system':
//           _themeMode = ThemeMode.system;
//           break;
//         default:
//           _themeMode = ThemeMode.system;
//       }
//       notifyListeners();
//     }
//   }
// }

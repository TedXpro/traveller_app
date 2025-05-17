// lib/providers/user_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traveller_app/models/user.dart'; // Assuming User model is correctly defined

class UserProvider with ChangeNotifier {
  User? _userData;
  String? _jwtToken; // Field to store the JWT token

  User? get userData => _userData;
  String? get jwtToken => _jwtToken; // Getter for the JWT token

  // Method to load user data and token from SharedPreferences
  Future<void> loadUserDataAndToken() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataJson = prefs.getString('userData');
    final authToken = prefs.getString('authToken'); // Load the token

    if (userDataJson != null) {
      try {
        final userDataMap = jsonDecode(userDataJson) as Map<String, dynamic>;
        _userData = User.fromJson(userDataMap);
        _jwtToken = authToken; // Assign the loaded token
        print('User data and token loaded from SharedPreferences.');
      } catch (e) {
        print('Error decoding user data from SharedPreferences: $e');
        // Clear potentially corrupted data
        await clearUserDataAndToken();
      }
    } else {
      _userData = null;
      _jwtToken = null; // Ensure token is null if no user data
      print('No user data found in SharedPreferences.');
    }
    notifyListeners(); // Notify listeners when data loads or changes
  }

  // Method to set user data and token after successful login
  Future<void> setUserDataAndToken(User user, String token) async {
    _userData = user;
    _jwtToken = token; // Store the token
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userData', jsonEncode(user.toJson()));
    await prefs.setString('authToken', token); // Save the token
    print('User data and token set in Provider and SharedPreferences.');
    notifyListeners();
  }

  // Method to clear user data and token on logout or authentication failure
  Future<void> clearUserDataAndToken() async {
    _userData = null;
    _jwtToken = null; // Clear the token
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userData');
    await prefs.remove('authToken'); // Remove the token
    print('User data and token cleared from Provider and SharedPreferences.');
    notifyListeners();
  }

  // You might want to add a method to check if the user is logged in
  bool get isLoggedIn =>
      _userData != null && _jwtToken != null && _jwtToken!.isNotEmpty;
}

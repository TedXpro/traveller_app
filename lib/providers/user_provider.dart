// lib/providers/user_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traveller_app/models/user.dart';

class UserProvider with ChangeNotifier {
  User? _userData;

  User? get userData => _userData;

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataJson = prefs.getString('userData');

    if (userDataJson != null) {
      final userDataMap = jsonDecode(userDataJson) as Map<String, dynamic>;
      _userData = User.fromJson(userDataMap);
    } else {
      _userData = null;
    }
    notifyListeners(); // Notify listeners when data loads or changes
  }

  // Method to update user data
  Future<void> setUserData(User user) async {
    _userData = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userData', jsonEncode(user.toJson()));
    notifyListeners();
  }

  // Method to clear user data on logout
  Future<void> clearUserData() async {
    _userData = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userData');
    notifyListeners();
  }
}

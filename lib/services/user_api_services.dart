import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traveller_app/models/email_credential.dart';
import 'package:jwt_decoder/jwt_decoder.dart'; // Import the JWT decoder

class UserService {
  final String baseUrl =
      'http://localhost:8080/api/login/email'; // Replace with your IP

  Future<bool> login(EmailCredential credentials) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(credentials.toJson()),
    );

    print(response);
    print("**********************");
    print(response.body);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final token = responseData['token'];

      if (token != null) {
        // Decode the JWT token
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        final firstName = decodedToken['first_name'];
        final userId = decodedToken['id'];

        print("Decoded Token: $decodedToken");

        if (firstName != null) {
          // Save token and first_name in SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('authToken', token); // Save token
          prefs.setString('userName', firstName); // Save first name
          prefs.setString('userId', userId); //save user id
          return true;
        } else {
          print("firstName not found in token");
          return false; // First name not found in token
        }
      } else {
        print("token not found in response");
        return false; // Token not found in response
      }
    } else {
      print("Login failed with status code: ${response.statusCode}");
      return false; // Login failed
    }
  }
}

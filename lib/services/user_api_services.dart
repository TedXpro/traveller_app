// lib/services/user_api_services.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:traveller_app/models/email_credential.dart';
import 'package:traveller_app/models/user.dart';
import 'package:traveller_app/models/login_response.dart';

class UserService {
  final String baseUrl = 'http://localhost:8080';

  Future<LoginResponse?> login(EmailCredential credentials) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/login/email'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(credentials.toJson()),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final token = responseData['token'];

      if (token != null) {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        final userId = decodedToken['id'];

        final userData = await getUserData(userId);

        if (userData != null) {
          // Return the User object and the token
          return LoginResponse(user: userData, token: token);
        } else {
          print("User data not found for userId: $userId");
          return null;
        }
      } else {
        print("Token not found in response");
        return null;
      }
    } else {
      print("Login failed with status code: ${response.statusCode}");
      return null;
    }
  }

  Future<User?> getUserData(userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/$userId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> userData = jsonDecode(response.body);
      return User.fromJson(userData);
    }
    return null;
  }

  Future<User?> signup(User user) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 200) {
        // Changed to 201 for successful creation
        final Map<String, dynamic> userData = jsonDecode(response.body);
        return User.fromJson(userData);
      } else {
        // Handle error responses from the backend
        print("Signup failed with status code: ${response.statusCode}");
        print(
          "Response body: ${response.body}",
        ); // Print the response body for debugging
        return null;
      }
    } catch (e) {
      // Handle network or other errors
      print("Signup error: $e");
      return null;
    }
  }

  Future<String?> updateUserProfile(User user) async {
    // Return String? for error
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/user/edit'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 200) {
        return null; // Return null on success
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return errorData['error']; // Return the error message
      }
    } catch (e) {
      return "Network error: $e"; // Return network error
    }
  }
}

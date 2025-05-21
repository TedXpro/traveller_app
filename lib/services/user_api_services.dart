// lib/services/user_api_services.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:traveller_app/models/change_credentials.dart';
import 'package:traveller_app/models/email_credential.dart';
import 'package:traveller_app/models/reset_password_request.dart';
import 'package:traveller_app/models/user.dart';
import 'package:traveller_app/models/login_response.dart';
import 'package:traveller_app/constants/api_constants.dart';

class UserService {
  Future<LoginResponse?> login(EmailCredential credentials) async {
    final url = Uri.parse('$baseUrl/api/login/email');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(credentials.toJson()),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final token = responseData['token'];

        if (token != null) {
          // Decode token to get user ID (assuming 'id' claim exists)
          Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
          final userId = decodedToken['id'];

          final userData = await getUserData(
            userId,
            token,
          ); // Pass token to getUserData

          if (userData != null) {
            // Return the User object and the token
            return LoginResponse(user: userData, token: token);
          } else {
            print("User data not found for userId: $userId after login.");
            // Depending on backend, this might indicate an issue or require token for getUserData
            return null;
          }
        } else {
          print("Token not found in login response.");
          return null;
        }
      } else {
        print("Login failed with status code: ${response.statusCode}");
        print(
          "Response body: ${response.body}",
        ); // Log response body for debugging
        return null;
      }
    } catch (e) {
      print("Login error: $e");
      return null;
    }
  }

  Future<User?> getUserData(String userId, String jwtToken) async {
    final url = Uri.parse('$baseUrl/user/$userId');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = jsonDecode(response.body);
        return User.fromJson(userData);
      } else if (response.statusCode == 401) {
        print("Unauthorized to get user data for userId: $userId");
        return null; // Return null on unauthorized
      } else {
        print(
          "Failed to get user data for userId: $userId. Status code: ${response.statusCode}",
        );
        print(
          "Response body: ${response.body}",
        ); // Log response body for debugging
        return null;
      }
    } catch (e) {
      print("Error getting user data for userId: $userId. Error: $e");
      return null;
    }
  }

  Future<User?> signup(User user) async {
    final url = Uri.parse('$baseUrl/api/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> userData = jsonDecode(response.body);
        return User.fromJson(userData);
      } else {
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

  Future<String?> updateUserProfile({
    required String userId, // Pass user ID explicitly
    required String firstName,
    required String lastName,
    // Include phone number if your backend expects it in this request
    required String phoneNumber,
    // Include favourite agencies if your backend expects them here
    // List<String>? favouriteAgencies,
    File? profilePhotoFile, // Optional file to upload
    required String jwtToken,
  }) async {
    final url = Uri.parse('$baseUrl/user/edit'); // Your backend endpoint
    final request = http.MultipartRequest('PUT', url); // Use PUT method

    // Add JWT token to headers for authentication
    request.headers['Authorization'] = 'Bearer $jwtToken';

    // Add text fields as form fields
    request.fields['id'] = userId; // User ID is required by backend
    request.fields['first_name'] = firstName.trim();
    request.fields['last_name'] = lastName.trim();
    // Add phone number field if your backend expects it here
    request.fields['phone_number'] = phoneNumber.trim();

    // Add favourite agencies if your backend expects them here as an array
    // Example if favouriteAgencies is a List<String>:
    // if (favouriteAgencies != null) {
    //    for (var agencyId in favouriteAgencies) {
    //       request.fields['favourite_agencies[]'] = agencyId; // Use [] for array
    //    }
    // }

    // Add the profile photo file if provided
    if (profilePhotoFile != null) {
      try {
        request.files.add(
          await http.MultipartFile.fromPath(
            'profile_photo', // This key must match the backend's FormFile key (ctx.FormFile("profile_photo"))
            profilePhotoFile.path,
          ),
        );
      } catch (e) {
        print('Error adding image file to multipart request: $e');
        return 'Error preparing image for upload.'; // Return error message
      }
    }

    // Send the request
    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Update User Profile API Response Status: ${response.statusCode}');
      print('Update User Profile API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // Assuming backend returns a success message or updated user data on 200
        return null; // Return null on success
      } else if (response.statusCode == 401) {
        print("Unauthorized to update user profile for userId: $userId");
        return "Unauthorized"; // Indicate unauthorized error
      } else {
        // Attempt to parse error message from backend response
        String errorMessage = 'Unknown error';
        try {
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          if (errorData.containsKey('error')) {
            errorMessage = errorData['error']; // Use backend error message
          }
        } catch (e) {
          print('Failed to parse error response body: $e');
          // Keep default error message if parsing fails
        }
        print(
          "Failed to update user profile for userId: $userId. Status code: ${response.statusCode}, Error: $errorMessage",
        );
        return errorMessage; // Return the parsed or default error message
      }
    } catch (e) {
      // Handle network or other errors during the request
      print('Error sending multipart request to update user profile: $e');
      return "Network error: $e"; // Return network error
    }
  }

  Future<String?> changeUserCredential(
    ChangeCredential userCredential,
    String jwtToken,
  ) async {
    final url = Uri.parse('$baseUrl/user/password/reset');
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: jsonEncode(userCredential.toJson()),
      );

      if (response.statusCode == 200) {
        return null; // Return null on success
      } else if (response.statusCode == 401) {
        print(
          "Unauthorized to change password for email: ${userCredential.email}",
        );
        return "Unauthorized"; // Indicate unauthorized error
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        print(
          "Failed to change password for email: ${userCredential.email}. Status code: ${response.statusCode}",
        );
        print("Response body: ${response.body}");
        return errorData['error'] ?? 'Unknown error'; // Use null-aware operator
      }
    } catch (e) {
      print(
        "Error changing password for email: ${userCredential.email}. Error: $e",
      );
      return "Network error: $e"; // Return network error
    }
  }

  Future<void> storeFCMToken({
    required String userId,
    required String fcmToken,
    required String jwtToken, // Added jwtToken parameter
  }) async {
    final url = Uri.parse(
      '$baseUrl/user/$userId/fcm-token',
    ); // Assuming this is the correct endpoint
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: jsonEncode({'fcm_token': fcmToken}),
      );

      if (response.statusCode == 200) {
        print('FCM token successfully stored on the server for user $userId');
      } else if (response.statusCode == 401) {
        print("Unauthorized to store FCM token for userId: $userId");
      } else {
        print(
          'Failed to store FCM token on the server for user $userId. Status code: ${response.statusCode}',
        );
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error sending FCM token to server for user $userId: $e');
    }
  }

  Future<void> removeFCMToken({
    required String userId,
    required String fcmToken,
    required String jwtToken, // Added jwtToken parameter
  }) async {
    final url = Uri.parse('$baseUrl/user/$userId/fcm-token');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: jsonEncode({'fcm_token': fcmToken}),
      );

      if (response.statusCode == 200) {
        print(
          'FCM token successfully removed from the server for user $userId',
        );
      } else if (response.statusCode == 401) {
        print("Unauthorized to remove FCM token for userId: $userId");
      } else {
        print(
          'Failed to remove FCM token from the server for user $userId. Status code: ${response.statusCode}',
        );
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error removing FCM token from server for user $userId: $e');
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String newPassword,
    required String code,
  }) async {
    final String endpoint = '/user/password/forget/reset';
    final url = Uri.parse(
      '$baseUrl$endpoint',
    ); // baseUrl should be defined in api_constants.dart

    // Create the request body matching the backend struct (ForgetPassword)
    final resetRequest = ResetPasswordRequest(
      // ResetPasswordRequest model should be defined
      email: email,
      newPassword: newPassword,
      code: code,
    );

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
          resetRequest.toJson(),
        ), // Encode the request body to JSON
      );

      print('Reset Password API Response Status: ${response.statusCode}');
      print(
        'Reset Password API Response Body: ${response.body}',
      ); // Log response body

      // Assuming your backend returns a 2xx status code on success
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('Password reset successful for email: $email');
        return true; // Indicate success
      } else {
        print(
          'Password reset failed: ${response.statusCode} - ${response.body}',
        );
        return false; // Indicate failure
      }
    } catch (e) {
      print('Error resetting password: $e');
      // Re-throw the exception to be handled by the caller (e.g., in the UI)
      rethrow;
    }
  }

  Future<bool> requestPasswordResetCode({required String email}) async {
    final String endpoint = '/user/password/forget/$email';
    final url = Uri.parse(
      '$baseUrl$endpoint',
    ); // baseUrl should be defined in api_constants.dart

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        // The backend endpoint /user/password/forgot/:email typically doesn't require a body,
        // as the email is in the URL. If your backend *does* expect a body like {"email": "..."},
        // you would uncomment and use the line below:
        // body: jsonEncode({'email': email}),
      );

      print(
        'Request Password Reset Code API Response Status: ${response.statusCode}',
      );
      print(
        'Request Password Reset Code API Response Body: ${response.body}',
      ); // Log response body

      // Assuming your backend returns a 2xx status code on success
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('Password reset code request successful for email: $email');
        return true; // Indicate success
      } else {
        print(
          'Password reset code request failed: ${response.statusCode} - ${response.body}',
        );
        // You might want to parse the error response body to get a specific error message
        // and throw an exception or return a specific error type.
        // For simplicity, returning false for any non-success status code for now.
        return false; // Indicate failure
      }
    } catch (e) {
      print('Error requesting password reset code: $e');
      // Re-throw the exception to be handled by the caller (e.g., in the UI)
      rethrow;
    }
  }
}

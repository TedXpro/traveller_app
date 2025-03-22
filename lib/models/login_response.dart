// lib/models/login_response.dart
import 'package:traveller_app/models/user.dart';

class LoginResponse {
  final String token;
  final User user;

  LoginResponse({required this.token, required this.user});
}

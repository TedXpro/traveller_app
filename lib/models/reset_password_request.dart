// lib/models/reset_password_request.dart
import 'package:json_annotation/json_annotation.dart';

// This is necessary for the generated code to be included
part 'reset_password_request.g.dart';

@JsonSerializable()
class ResetPasswordRequest {
  // Matches json:"email"
  final String email;

  // Matches json:"code"
  final String code;

  // Matches json:"new_password"
  @JsonKey(name: 'new_password')
  final String newPassword;

  ResetPasswordRequest({
    required this.email,
    required this.code,
    required this.newPassword,
  });

  // Factory method to create a ResetPasswordRequest object from a JSON map
  factory ResetPasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$ResetPasswordRequestFromJson(json);

  // Method to convert a ResetPasswordRequest object to a JSON map
  Map<String, dynamic> toJson() => _$ResetPasswordRequestToJson(this);
}

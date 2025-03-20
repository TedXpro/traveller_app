import 'package:json_annotation/json_annotation.dart';

part 'email_credential.g.dart'; // Ensure this is correct

@JsonSerializable()
class EmailCredential {
  String email;
  String password;

  EmailCredential({required this.email, required this.password});

  factory EmailCredential.fromJson(Map<String, dynamic> json) =>
      _$EmailCredentialFromJson(json);

  Map<String, dynamic> toJson() => _$EmailCredentialToJson(this);
}

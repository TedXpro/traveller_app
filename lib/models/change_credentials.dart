import 'package:json_annotation/json_annotation.dart';

part 'change_credentials.g.dart';

@JsonSerializable(explicitToJson: true)
class ChangeCredential {
  @JsonKey(name: 'email')
  final String? email;

  @JsonKey(name: 'old_password')
  final String? oldPassword;

  @JsonKey(name: 'new_password')
  final String? newPassword;

  ChangeCredential({
    required this.email,
    required this.oldPassword,
    required this.newPassword,
  });

  factory ChangeCredential.fromJson(Map<String, dynamic> json) =>
      _$ChangeCredentialFromJson(json);

  Map<String, dynamic> toJson() => _$ChangeCredentialToJson(this);
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_credentials.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChangeCredential _$ChangeCredentialFromJson(Map<String, dynamic> json) =>
    ChangeCredential(
      email: json['email'] as String?,
      oldPassword: json['old_password'] as String?,
      newPassword: json['new_password'] as String?,
    );

Map<String, dynamic> _$ChangeCredentialToJson(ChangeCredential instance) =>
    <String, dynamic>{
      'email': instance.email,
      'old_password': instance.oldPassword,
      'new_password': instance.newPassword,
    };

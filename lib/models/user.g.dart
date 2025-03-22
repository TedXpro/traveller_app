// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['id'] as String?,
  firstName: json['first_name'] as String?,
  lastName: json['last_name'] as String?,
  loginPreference: json['login_preference'] as String?,
  email: json['email'] as String?,
  phoneNumber: json['phone_number'] as String?,
  password: json['password'] as String?,
  profilePhoto: json['profile_photo'] as String?,
  registrationDate:
      json['registration_date'] == null
          ? null
          : DateTime.parse(json['registration_date'] as String),
  verified: json['verified'] as bool?,
  favouriteAgencies:
      (json['favourite_agencies'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'login_preference': instance.loginPreference,
  'email': instance.email,
  'phone_number': instance.phoneNumber,
  'password': instance.password,
  'profile_photo': instance.profilePhoto,
  'registration_date': instance.registrationDate?.toIso8601String(),
  'verified': instance.verified,
  'favourite_agencies': instance.favouriteAgencies,
};

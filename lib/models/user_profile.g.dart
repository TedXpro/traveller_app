// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => UserProfile(
  id: json['id'] as String?,
  firstName: json['first_name'] as String,
  lastName: json['last_name'] as String,
  profilePhoto: json['profile_photo'] as String?,
  favouriteAgencies:
      (json['favourite_agencies'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
);

Map<String, dynamic> _$UserProfileToJson(UserProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'profile_photo': instance.profilePhoto,
      'favourite_agencies': instance.favouriteAgencies,
    };

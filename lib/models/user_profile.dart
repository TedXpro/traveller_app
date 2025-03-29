import 'package:json_annotation/json_annotation.dart';

part 'user_profile.g.dart';

@JsonSerializable(explicitToJson: true)
class UserProfile {
  @JsonKey(name: 'id',)
  final String? id;

  @JsonKey(name: 'first_name')
  final String firstName;

  @JsonKey(name: 'last_name')
  final String lastName;

  @JsonKey(name: 'profile_photo')
  final String? profilePhoto;

  @JsonKey(name: 'favourite_agencies')
  final List<String>? favouriteAgencies;

  UserProfile({
    this.id,
    required this.firstName,
    required this.lastName,
    this.profilePhoto,
    this.favouriteAgencies,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileToJson(this);
}

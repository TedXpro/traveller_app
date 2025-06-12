import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  @JsonKey(name: 'id')
  String? id;

  @JsonKey(name: 'first_name')
  String? firstName;

  @JsonKey(name: 'last_name')
  String? lastName;

  @JsonKey(name: 'email')
  String? email;

  @JsonKey(name: 'phone_number')
  String? phoneNumber;

  @JsonKey(name: 'password')
  String? password;

  @JsonKey(name: 'profile_photo')
  String? profilePhoto;

  @JsonKey(name: 'registration_date')
  DateTime? registrationDate;

  @JsonKey(name: 'verified')
  bool? verified;

  @JsonKey(name: 'favourite_agencies')
  List<String>? favouriteAgencies;

  User({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.password,
    this.profilePhoto,
    this.registrationDate,
    this.verified,
    this.favouriteAgencies,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
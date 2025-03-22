import 'package:json_annotation/json_annotation.dart';

part 'agency.g.dart';

@JsonSerializable()
class Agency {
  @JsonKey(name: 'id')
  final String id;
  @JsonKey(name: 'name')
  final String name;
  @JsonKey(name: 'services')
  final List<String>? services;
  @JsonKey(name: 'logo_url')
  final String? logoUrl;
  @JsonKey(name: 'description')
  final String description;
  @JsonKey(name: 'contact')
  final List<String> contact;

  Agency({
    required this.id,
    required this.name,
    this.services,
    this.logoUrl,
    required this.description,
    required this.contact,
  });

  factory Agency.fromJson(Map<String, dynamic> json) => _$AgencyFromJson(json);
  Map<String, dynamic> toJson() => _$AgencyToJson(this);
}

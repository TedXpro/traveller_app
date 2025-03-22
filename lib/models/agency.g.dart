// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agency.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Agency _$AgencyFromJson(Map<String, dynamic> json) => Agency(
  id: json['id'] as String,
  name: json['name'] as String,
  services:
      (json['services'] as List<dynamic>?)?.map((e) => e as String).toList(),
  logoUrl: json['logo_url'] as String?,
  description: json['description'] as String,
  contact: (json['contact'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$AgencyToJson(Agency instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'services': instance.services,
  'logo_url': instance.logoUrl,
  'description': instance.description,
  'contact': instance.contact,
};

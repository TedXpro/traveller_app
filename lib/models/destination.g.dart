// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'destination.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Destination _$DestinationFromJson(Map<String, dynamic> json) => Destination(
  id: json['id'] as String?,
  name: json['name'] as String,
  latitude: json['latitude'] as String,
  longitude: json['longitude'] as String,
  description: json['description'] as String,
  hotels:
      (json['hotels'] as List<dynamic>?)
          ?.map(
            (e) =>
                (e as List<dynamic>)
                    .map((e) => Hotel.fromJson(e as Map<String, dynamic>))
                    .toList(),
          )
          .toList(),
  culture: json['culture'] as String,
  history: json['history'] as String,
  population: json['population'] as String,
  touristAttractions:
      (json['touristAttractions'] as List<dynamic>?)
          ?.map(
            (e) =>
                (e as List<dynamic>)
                    .map(
                      (e) =>
                          TouristAttraction.fromJson(e as Map<String, dynamic>),
                    )
                    .toList(),
          )
          .toList(),
  postDate:
      json['post_date'] == null
          ? null
          : DateTime.parse(json['post_date'] as String),
);

Map<String, dynamic> _$DestinationToJson(Destination instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'description': instance.description,
      'hotels': instance.hotels,
      'culture': instance.culture,
      'history': instance.history,
      'population': instance.population,
      'touristAttractions': instance.touristAttractions,
      'post_date': instance.postDate?.toIso8601String(),
    };

Hotel _$HotelFromJson(Map<String, dynamic> json) => Hotel(
  name: json['name'] as String,
  imageUrl: json['imageUrl'] as String,
  mapLink: json['mapLink'] as String,
);

Map<String, dynamic> _$HotelToJson(Hotel instance) => <String, dynamic>{
  'name': instance.name,
  'imageUrl': instance.imageUrl,
  'mapLink': instance.mapLink,
};

TouristAttraction _$TouristAttractionFromJson(Map<String, dynamic> json) =>
    TouristAttraction(
      name: json['name'] as String,
      desc: json['desc'] as String,
      imageUrl: json['imageUrl'] as String,
    );

Map<String, dynamic> _$TouristAttractionToJson(TouristAttraction instance) =>
    <String, dynamic>{
      'name': instance.name,
      'desc': instance.desc,
      'imageUrl': instance.imageUrl,
    };

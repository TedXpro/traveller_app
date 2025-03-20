import 'package:json_annotation/json_annotation.dart';

part 'destination.g.dart';

@JsonSerializable()
class Destination {
  @JsonKey(name: 'id')
  String? id;

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'latitude')
  String latitude;

  @JsonKey(name: 'longitude')
  String longitude;

  @JsonKey(name: 'description')
  String description;

  @JsonKey(name: 'hotels')
  List<List<Hotel>>? hotels;

  @JsonKey(name: 'culture')
  String culture;

  @JsonKey(name: 'history')
  String history;

  @JsonKey(name: 'population')
  String population;

  @JsonKey(name: 'touristAttractions')
  List<List<TouristAttraction>>? touristAttractions;

  @JsonKey(name: 'post_date')
  DateTime? postDate;

  Destination({
    this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.description,
    this.hotels,
    required this.culture,
    required this.history,
    required this.population,
    this.touristAttractions,
    this.postDate,
  });

  factory Destination.fromJson(Map<String, dynamic> json) =>
      _$DestinationFromJson(json);
  Map<String, dynamic> toJson() => _$DestinationToJson(this);
}

@JsonSerializable()
class Hotel {
  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'imageUrl')
  String imageUrl;

  @JsonKey(name: 'mapLink')
  String mapLink;

  Hotel({required this.name, required this.imageUrl, required this.mapLink});

  factory Hotel.fromJson(Map<String, dynamic> json) => _$HotelFromJson(json);
  Map<String, dynamic> toJson() => _$HotelToJson(this);
}

@JsonSerializable()
class TouristAttraction {
  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'desc')
  String desc;

  @JsonKey(name: 'imageUrl')
  String imageUrl;

  TouristAttraction({
    required this.name,
    required this.desc,
    required this.imageUrl,
  });

  factory TouristAttraction.fromJson(Map<String, dynamic> json) =>
      _$TouristAttractionFromJson(json);
  Map<String, dynamic> toJson() => _$TouristAttractionToJson(this);
}

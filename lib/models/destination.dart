import 'package:json_annotation/json_annotation.dart';

part 'destination.g.dart';

@JsonSerializable()
class Destination {
  
  @JsonKey(name: 'id')
  String? id; 

  @JsonKey(name: 'name')
  String name; 

  @JsonKey(name: 'image') 
  String? image; 

  @JsonKey(name: 'stations')
  List<String>? stations; 

  Destination({this.id, required this.name, this.stations});

  factory Destination.fromJson(Map<String, dynamic> json) =>
      _$DestinationFromJson(json);
  Map<String, dynamic> toJson() => _$DestinationToJson(this);
}

@JsonSerializable()
class DestinationDetails {
  @JsonKey(name: 'destination_id')
  String? destinationId; 

  @JsonKey(name: 'latitude')
  String? latitude; 

  @JsonKey(name: 'longitude')
  String? longitude; 

  @JsonKey(name: 'description')
  String? description; 

  @JsonKey(name: 'hotels')
  List<Hotel>? hotels; 

  @JsonKey(name: 'culture')
  String? culture; 

  @JsonKey(name: 'history')
  String? history; 

  @JsonKey(name: 'tourist_attractions') 
  List<TouristAttraction>? touristAttractions; 

  @JsonKey(name: 'post_date')
  DateTime? postDate; 

  DestinationDetails({
    this.destinationId,
    this.latitude,
    this.longitude,
    this.description,
    this.hotels,
    this.culture,
    this.history,
    this.touristAttractions,
    this.postDate,
  });

  factory DestinationDetails.fromJson(Map<String, dynamic> json) =>
      _$DestinationDetailsFromJson(json);
  Map<String, dynamic> toJson() => _$DestinationDetailsToJson(this);
}


@JsonSerializable()
class Hotel {
  @JsonKey(name: 'name')
  String name; 

  @JsonKey(name: 'image_url') 
  String? imageUrl; 

  @JsonKey(name: 'map_link') 
  String? mapLink; 

  Hotel({
    required this.name,
    this.imageUrl,
    this.mapLink,
  }); 

  factory Hotel.fromJson(Map<String, dynamic> json) => _$HotelFromJson(json);
  Map<String, dynamic> toJson() => _$HotelToJson(this);
}

@JsonSerializable()
class TouristAttraction {
  @JsonKey(name: 'name')
  String name; 

  @JsonKey(name: 'desc') 
  String desc; 

  @JsonKey(name: 'image_url') 
  String? imageUrl; 

  @JsonKey(
    name: 'map_link',
  ) 
  String? mapLink; 

  TouristAttraction({
    required this.name,
    required this.desc,
    this.imageUrl,
    this.mapLink, 
  });

  factory TouristAttraction.fromJson(Map<String, dynamic> json) =>
      _$TouristAttractionFromJson(json);
  Map<String, dynamic> toJson() => _$TouristAttractionToJson(this);
}

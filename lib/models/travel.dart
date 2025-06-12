import 'package:json_annotation/json_annotation.dart';

part 'travel.g.dart';

@JsonSerializable()
class Travel {
  @JsonKey(name: 'id')
  final String id;
  @JsonKey(name: 'agency_id')
  final String agencyId;
  @JsonKey(name: 'start_location')
  final String startLocation;
  @JsonKey(name: 'pickup_locations')
  final List<String> pickupLocations;
  @JsonKey(name: 'destination')
  final String destination;
  @JsonKey(name: 'planned_start_time')
  final DateTime plannedStartTime;
  @JsonKey(name: 'actual_start_time')
  final DateTime? actualStartTime;
  @JsonKey(name: 'est_arrival_time')
  final DateTime? estArrivalTime;
  @JsonKey(name: 'actual_arrival_time')
  final DateTime? actualArrivalTime;
  @JsonKey(name: 'price')
  final double price;
  @JsonKey(name: 'total_seats')
  final int totalSeats;
  @JsonKey(name: 'bus_ref')
  final String? busRef;
  @JsonKey(name: 'driver_id')
  final String? driverId;
  @JsonKey(name: 'post_time')
  final DateTime? postTime;
  @JsonKey(name: 'last_mod_time')
  final DateTime? lastModTime;
  @JsonKey(name: 'status')
  final String? status;

  Travel({
    required this.id,
    required this.agencyId,
    required this.startLocation,
    required this.pickupLocations,
    required this.destination,
    required this.plannedStartTime,
    this.actualStartTime,
    this.estArrivalTime,
    this.actualArrivalTime,
    required this.price,
    required this.totalSeats,
    this.busRef,
    this.driverId,
    this.postTime,
    this.lastModTime,
    this.status,
  });

  factory Travel.fromJson(Map<String, dynamic> json) => _$TravelFromJson(json);
  Map<String, dynamic> toJson() => _$TravelToJson(this);
}

@JsonSerializable()
class TravelStats {
  @JsonKey(name: 'travel_id')
  final String travelID;
  @JsonKey(name: 'seats')
  final List<bool> seats;
  @JsonKey(name: 'reserved_count')
  final int reservedCount;
  @JsonKey(name: 'avg_rating')
  final double avgRating;
  @JsonKey(name: 'rated_by')
  final int ratedBy;

  TravelStats({
    required this.travelID,
    required this.seats,
    required this.reservedCount,
    required this.avgRating,
    required this.ratedBy,
  });

  factory TravelStats.fromJson(Map<String, dynamic> json) =>
      _$TravelStatsFromJson(json);
  Map<String, dynamic> toJson() => _$TravelStatsToJson(this);
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'travel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Travel _$TravelFromJson(Map<String, dynamic> json) => Travel(
  id: json['id'] as String,
  agencyId: json['agency_id'] as String,
  startLocation: json['start_location'] as String,
  pickupLocations:
      (json['pickup_locations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
  destination: json['destination'] as String,
  plannedStartTime: DateTime.parse(json['planned_start_time'] as String),
  actualStartTime:
      json['actual_start_time'] == null
          ? null
          : DateTime.parse(json['actual_start_time'] as String),
  estArrivalTime:
      json['est_arrival_time'] == null
          ? null
          : DateTime.parse(json['est_arrival_time'] as String),
  actualArrivalTime:
      json['actual_arrival_time'] == null
          ? null
          : DateTime.parse(json['actual_arrival_time'] as String),
  price: (json['price'] as num).toDouble(),
  totalSeats: (json['total_seats'] as num).toInt(),
  busRef: json['bus_ref'] as String?,
  driverId: json['driver_id'] as String?,
  postTime:
      json['post_time'] == null
          ? null
          : DateTime.parse(json['post_time'] as String),
  lastModTime:
      json['last_mod_time'] == null
          ? null
          : DateTime.parse(json['last_mod_time'] as String),
  status: json['status'] as String?,
);

Map<String, dynamic> _$TravelToJson(Travel instance) => <String, dynamic>{
  'id': instance.id,
  'agency_id': instance.agencyId,
  'start_location': instance.startLocation,
  'pickup_locations': instance.pickupLocations,
  'destination': instance.destination,
  'planned_start_time': instance.plannedStartTime.toIso8601String(),
  'actual_start_time': instance.actualStartTime?.toIso8601String(),
  'est_arrival_time': instance.estArrivalTime?.toIso8601String(),
  'actual_arrival_time': instance.actualArrivalTime?.toIso8601String(),
  'price': instance.price,
  'total_seats': instance.totalSeats,
  'bus_ref': instance.busRef,
  'driver_id': instance.driverId,
  'post_time': instance.postTime?.toIso8601String(),
  'last_mod_time': instance.lastModTime?.toIso8601String(),
  'status': instance.status,
};

TravelStats _$TravelStatsFromJson(Map<String, dynamic> json) => TravelStats(
  travelID: json['travel_id'] as String,
  seats: (json['seats'] as List<dynamic>).map((e) => e as bool).toList(),
  reservedCount: (json['reserved_count'] as num).toInt(),
  avgRating: (json['avg_rating'] as num).toDouble(),
  ratedBy: (json['rated_by'] as num).toInt(),
);

Map<String, dynamic> _$TravelStatsToJson(TravelStats instance) =>
    <String, dynamic>{
      'travel_id': instance.travelID,
      'seats': instance.seats,
      'reserved_count': instance.reservedCount,
      'avg_rating': instance.avgRating,
      'rated_by': instance.ratedBy,
    };

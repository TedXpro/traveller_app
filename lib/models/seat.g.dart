// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Seat _$SeatFromJson(Map<String, dynamic> json) => Seat(
  travelId: json['travel_id'] as String,
  travelerId: json['traveler_id'] as String,
  seatNo: (json['seat_no'] as num).toInt(),
  maxTime:
      json['max_time'] == null
          ? null
          : DateTime.parse(json['max_time'] as String),
);

Map<String, dynamic> _$SeatToJson(Seat instance) => <String, dynamic>{
  'travel_id': instance.travelId,
  'traveler_id': instance.travelerId,
  'seat_no': instance.seatNo,
  'max_time': instance.maxTime?.toIso8601String(),
};

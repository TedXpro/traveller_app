// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Booking _$BookingFromJson(Map<String, dynamic> json) => Booking(
  travelId: json['travel_id'] as String,
  travelerId: json['traveler_id'] as String,
  seatNo: (json['seat_no'] as num).toInt(),
  tripType: json['trip_type'] as String,
  startLocation: json['start_location'] as String,
  paymentType: (json['payment_type'] as num).toDouble(),
  paymentRef: json['payment_ref'] as String,
  bookTime: DateTime.parse(json['book_time'] as String),
  payTime:
      json['pay_time'] == null
          ? null
          : DateTime.parse(json['pay_time'] as String),
  bookTimeLimit: DateTime.parse(json['book_time_limit'] as String),
  status: json['status'] as String,
);

Map<String, dynamic> _$BookingToJson(Booking instance) => <String, dynamic>{
  'travel_id': instance.travelId,
  'traveler_id': instance.travelerId,
  'seat_no': instance.seatNo,
  'trip_type': instance.tripType,
  'start_location': instance.startLocation,
  'payment_type': instance.paymentType,
  'payment_ref': instance.paymentRef,
  'book_time': instance.bookTime.toIso8601String(),
  'pay_time': instance.payTime?.toIso8601String(),
  'book_time_limit': instance.bookTimeLimit.toIso8601String(),
  'status': instance.status,
};

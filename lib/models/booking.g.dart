// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Booking _$BookingFromJson(Map<String, dynamic> json) => Booking(
  id: json['id'] as String?,
  bookingRef: json['booking_ref'] as String?,
  travelId: json['travel_id'] as String,
  travelerId: json['traveler_id'] as String,
  firstName: json['first_name'] as String?,
  lastName: json['last_name'] as String?,
  email: json['email'] as String?,
  phoneNumber: json['phone_number'] as String?,
  seatNo: (json['seat_no'] as num).toInt(),
  tripType: json['trip_type'] as String,
  startLocation: json['start_location'] as String,
  destination: json['destination'] as String,
  price: (json['price'] as num).toDouble(),
  paymentType: json['payment_type'] as String?,
  paymentRef:
      json['payment_ref'] == null
          ? null
          : Payment.fromJson(json['payment_ref'] as Map<String, dynamic>),
  bookTime: DateTime.parse(json['book_time'] as String),
  payTime:
      json['pay_time'] == null
          ? null
          : DateTime.parse(json['pay_time'] as String),
  bookTimeLimit: DateTime.parse(json['book_time_limit'] as String),
  status: json['status'] as String?,
);

Map<String, dynamic> _$BookingToJson(Booking instance) => <String, dynamic>{
  'id': instance.id,
  'booking_ref': instance.bookingRef,
  'travel_id': instance.travelId,
  'traveler_id': instance.travelerId,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'email': instance.email,
  'phone_number': instance.phoneNumber,
  'seat_no': instance.seatNo,
  'trip_type': instance.tripType,
  'start_location': instance.startLocation,
  'destination': instance.destination,
  'price': instance.price,
  'payment_type': instance.paymentType,
  'payment_ref': instance.paymentRef,
  'book_time': instance.bookTime.toIso8601String(),
  'pay_time': instance.payTime?.toIso8601String(),
  'book_time_limit': instance.bookTimeLimit.toIso8601String(),
  'status': instance.status,
};

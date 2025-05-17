// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookingStatus _$BookingStatusFromJson(Map<String, dynamic> json) =>
    BookingStatus(
      bookingRef: json['booking_ref'] as String,
      status: json['status'] as String,
    );

Map<String, dynamic> _$BookingStatusToJson(BookingStatus instance) =>
    <String, dynamic>{
      'booking_ref': instance.bookingRef,
      'status': instance.status,
    };

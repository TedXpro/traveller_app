// lib/models/booking.dart
// Description: This model represents a Booking record.
// It has been updated to include a nested Payment model for payment details and the bookingRef field.

import 'package:json_annotation/json_annotation.dart';
import 'package:traveller_app/models/payment.dart'; // Import the new Payment model

part 'booking.g.dart';

@JsonSerializable()
class Booking {
  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'booking_ref') // Added booking_ref field
  final String? bookingRef; // Added bookingRef field
  @JsonKey(name: 'travel_id')
  final String travelId;
  @JsonKey(name: 'traveler_id')
  final String travelerId;
  @JsonKey(name: 'first_name')
  final String? firstName;
  @JsonKey(name: 'last_name')
  final String? lastName;
  @JsonKey(name: 'email')
  final String? email;
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  @JsonKey(name: 'seat_no')
  final int seatNo;
  @JsonKey(name: 'trip_type')
  final String tripType;
  @JsonKey(name: 'start_location')
  final String startLocation;
  @JsonKey(name: 'destination')
  final String destination;
  @JsonKey(name: 'price')
  final double price;
  @JsonKey(name: 'payment_type')
  String? paymentType;
  @JsonKey(name: 'payment_ref')
  final Payment? paymentRef; // Changed type to Payment?
  @JsonKey(name: 'book_time')
  final DateTime bookTime;
  @JsonKey(name: 'pay_time')
  final DateTime? payTime;
  @JsonKey(name: 'book_time_limit')
  final DateTime bookTimeLimit;
  @JsonKey(name: 'status')
  String? status;

  Booking({
    this.id,
    this.bookingRef, // Added to constructor
    required this.travelId,
    required this.travelerId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.seatNo,
    required this.tripType,
    required this.startLocation,
    required this.destination,
    required this.price,
    this.paymentType,
    this.paymentRef, // Updated constructor
    required this.bookTime, // Updated constructor
    this.payTime,
    required this.bookTimeLimit, // Updated constructor
    this.status,
  });

  // Factory constructor to create a Booking object from a JSON map
  factory Booking.fromJson(Map<String, dynamic> json) =>
      _$BookingFromJson(json);

  // Method to convert a Booking object to a JSON map
  Map<String, dynamic> toJson() => _$BookingToJson(this);
}

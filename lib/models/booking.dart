import 'package:json_annotation/json_annotation.dart';

part 'booking.g.dart';

@JsonSerializable()
class Booking {
  @JsonKey(name: 'travel_id')
  final String travelId;
  @JsonKey(name: 'traveler_id')
  final String travelerId;
  @JsonKey(name: 'seat_no')
  final int seatNo;
  @JsonKey(name: 'trip_type')
  final String tripType;
  @JsonKey(name: 'start_location')
  final String startLocation;
  @JsonKey(name: 'payment_type')
  final double paymentType;
  @JsonKey(name: 'payment_ref')
  final String paymentRef;
  @JsonKey(name: 'book_time')
  final DateTime bookTime;
  @JsonKey(name: 'pay_time')
  final DateTime? payTime;
  @JsonKey(name: 'book_time_limit')
  final DateTime bookTimeLimit;
  @JsonKey(name: 'status')
  final String status;

  Booking({
    required this.travelId,
    required this.travelerId,
    required this.seatNo,
    required this.tripType,
    required this.startLocation,
    required this.paymentType,
    required this.paymentRef,
    required this.bookTime,
    this.payTime,
    required this.bookTimeLimit,
    required this.status,
  });

  factory Booking.fromJson(Map<String, dynamic> json) =>
      _$BookingFromJson(json);
  Map<String, dynamic> toJson() => _$BookingToJson(this);
}

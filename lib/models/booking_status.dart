import 'package:json_annotation/json_annotation.dart';

part 'booking_status.g.dart';

@JsonSerializable()
class BookingStatus {
  @JsonKey(name: 'booking_ref')
  final String bookingRef; // Corresponds to BookingRef in backend
  @JsonKey(name: 'status')
  final String status; // Corresponds to Status in backend

  BookingStatus({required this.bookingRef, required this.status});

  // Factory constructor to create a BookingStatus object from a JSON map
  factory BookingStatus.fromJson(Map<String, dynamic> json) =>
      _$BookingStatusFromJson(json);

  // Method to convert a BookingStatus object to a JSON map
  Map<String, dynamic> toJson() => _$BookingStatusToJson(this);
}

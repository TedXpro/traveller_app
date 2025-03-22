import 'package:json_annotation/json_annotation.dart';

part 'seat.g.dart';

@JsonSerializable()
class Seat {
  @JsonKey(name: 'travel_id')
  final String travelId;
  @JsonKey(name: 'traveler_id')
  final String travelerId;
  @JsonKey(name: 'seat_no')
  final int seatNo;
  @JsonKey(name: 'max_time')
  final DateTime? maxTime;

  Seat({
    required this.travelId,
    required this.travelerId,
    required this.seatNo,
    this.maxTime,
  });

  factory Seat.fromJson(Map<String, dynamic> json) => _$SeatFromJson(json);
  Map<String, dynamic> toJson() => _$SeatToJson(this);
}

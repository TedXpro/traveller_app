import 'package:json_annotation/json_annotation.dart';

part 'events.g.dart';

class Event {
  @JsonKey(name: "title")
  final String title;

  @JsonKey(name: "desc")
  final String? desc;

  @JsonKey(name: "date")
  final DateTime? date;

  @JsonKey(name: "destination_id")
  final String destination_id;

  @JsonKey(name: "media_link")
  final String? media;

  Event({
    required this.title,
    required this.desc,
    required this.date,
    required this.destination_id,
    required this.media,
  });

  factory Event.fromJson(Map<String, dynamic> json) => $_EventFromJson(json);
}

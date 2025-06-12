
part of 'events.dart';

Event $_EventFromJson(Map<String, dynamic> json){
  return Event(
    title : json['title'] as String,
    desc : json['desc'] as String?,
    media: json['media_link'] as String?,
    destination_id: json['destination_id'] as String,
    date : json['date'] == null ? null : DateTime.parse(json['date'] as String)
  );
}
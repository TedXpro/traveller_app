import 'package:json_annotation/json_annotation.dart';

part 'notification.g.dart'; // Make sure this matches your file name

@JsonSerializable()
class UserNotification {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'traveller_id')
  final String travellerId;

  @JsonKey(name: 'notifications')
  final List<CustomNotification> notifications;

  UserNotification({
    required this.id,
    required this.travellerId,
    required this.notifications,
  });

  factory UserNotification.fromJson(Map<String, dynamic> json) =>
      _$UserNotificationFromJson(json);

  Map<String, dynamic> toJson() => _$UserNotificationToJson(this);
}

@JsonSerializable()
class CustomNotification {
  // Using String for ID as it's a hex representation of primitive.ObjectID
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'message')
  final String message;

  @JsonKey(name: 'post_time')
  final DateTime postTime; // Use DateTime for time.Time

  @JsonKey(name: 'status')
  final String status; // Corresponds to NotificationStatus string

  CustomNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.postTime,
    required this.status,
  });

  factory CustomNotification.fromJson(Map<String, dynamic> json) =>
      _$CustomNotificationFromJson(json);

  Map<String, dynamic> toJson() => _$CustomNotificationToJson(this);
}

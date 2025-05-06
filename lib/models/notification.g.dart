// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserNotification _$UserNotificationFromJson(Map<String, dynamic> json) =>
    UserNotification(
      id: json['id'] as String,
      travellerId: json['traveller_id'] as String,
      notifications:
          (json['notifications'] as List<dynamic>)
              .map(
                (e) => CustomNotification.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
    );

Map<String, dynamic> _$UserNotificationToJson(UserNotification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'traveller_id': instance.travellerId,
      'notifications': instance.notifications,
    };

CustomNotification _$CustomNotificationFromJson(Map<String, dynamic> json) =>
    CustomNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      postTime: DateTime.parse(json['post_time'] as String),
      status: json['status'] as String,
    );

Map<String, dynamic> _$CustomNotificationToJson(CustomNotification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'message': instance.message,
      'post_time': instance.postTime.toIso8601String(),
      'status': instance.status,
    };

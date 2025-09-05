import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'notification.g.dart';

@JsonSerializable()
class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  @JsonKey(name: 'is_read')
  final bool isRead;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'read_at')
  final String? readAt;
  final Map<String, dynamic>? data;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.readAt,
    this.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) => _$NotificationModelFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    bool? isRead,
    String? createdAt,
    String? readAt,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      data: data ?? this.data,
    );
  }

  DateTime get createdAtDateTime => DateTime.parse(createdAt);
  DateTime? get readAtDateTime => readAt != null ? DateTime.parse(readAt!) : null;

  IconData get iconData {
    switch (type) {
      case 'order':
        return Icons.shopping_bag;
      case 'lottery':
        return Icons.confirmation_number;
      case 'payment':
        return Icons.payment;
      case 'system':
        return Icons.info;
      case 'promotion':
        return Icons.local_offer;
      default:
        return Icons.notifications;
    }
  }

  Color get colorFromType {
    switch (type) {
      case 'order':
        return Colors.blue;
      case 'lottery':
        return Colors.purple;
      case 'payment':
        return Colors.green;
      case 'system':
        return Colors.orange;
      case 'promotion':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

@JsonSerializable()
class NotificationsResponse {
  final List<NotificationModel>? notifications;
  final String? message;
  final bool success;

  NotificationsResponse({
    this.notifications,
    this.message,
    required this.success,
  });

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) => _$NotificationsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationsResponseToJson(this);
}
import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  expense,
  income,
  system,
  appUpdate,
  alert
}

class NotificationEntity {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final String? transactionId;

  NotificationEntity({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.transactionId,
  });

  factory NotificationEntity.fromMap(Map<String, dynamic> data, String documentId) {
    NotificationType parsedType = NotificationType.system;
    final typeString = data['type'] as String?;
    if (typeString != null) {
      parsedType = NotificationType.values.firstWhere(
        (e) => e.toString() == 'NotificationType.$typeString',
        orElse: () => NotificationType.system,
      );
    }

    return NotificationEntity(
      id: documentId,
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: parsedType,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
      transactionId: data['transactionId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'type': type.toString().split('.').last,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'transactionId': transactionId,
    };
  }

  NotificationEntity copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
    String? transactionId,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      transactionId: transactionId ?? this.transactionId,
    );
  }
}

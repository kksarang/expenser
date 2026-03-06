import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/notification_entity.dart';
import '../../core/services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  
  List<NotificationEntity> _notifications = [];
  bool _isLoading = false;
  StreamSubscription<List<NotificationEntity>>? _notificationSubscription;

  List<NotificationEntity> get notifications => _notifications;
  bool get isLoading => _isLoading;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationProvider() {
    _initFCM();
  }

  Future<void> _initFCM() async {
    await _notificationService.setupFirebaseMessaging();
  }

  void listenToNotifications() {
    _isLoading = true;
    notifyListeners();

    _notificationSubscription?.cancel();
    _notificationSubscription = _notificationService.getNotifications().listen(
      (notifications) {
        _notifications = notifications;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        if (kDebugMode) {
          print('Error listening to notifications: $error');
        }
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void stopListening() {
    _notificationSubscription?.cancel();
    _notificationSubscription = null;
    _notifications = [];
    notifyListeners();
  }

  Future<void> addNotification(NotificationEntity notification) async {
    await _notificationService.createNotification(notification);
  }

  Future<void> markAsRead(String notificationId) async {
    await _notificationService.markAsRead(notificationId);
  }

  Future<void> markAllAsRead() async {
    await _notificationService.markAllAsRead();
  }

  Future<void> deleteNotification(String notificationId) async {
    await _notificationService.deleteNotification(notificationId);
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }
}

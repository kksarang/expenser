import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../domain/entities/notification_entity.dart';
import '../../core/services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  
  List<NotificationEntity> _notifications = [];
  bool _isLoading = false;
  AuthorizationStatus _authorizationStatus = AuthorizationStatus.notDetermined;
  StreamSubscription<List<NotificationEntity>>? _notificationSubscription;

  List<NotificationEntity> get notifications => _notifications;
  bool get isLoading => _isLoading;
  AuthorizationStatus get authorizationStatus => _authorizationStatus;
  bool get hasPermission => _authorizationStatus == AuthorizationStatus.authorized;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationProvider() {
    _initFCM();
  }

  Future<void> _initFCM() async {
    _authorizationStatus = await _notificationService.setupFirebaseMessaging();
    notifyListeners();
  }

  Future<void> requestPermission() async {
    _authorizationStatus = await _notificationService.setupFirebaseMessaging();
    notifyListeners();
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

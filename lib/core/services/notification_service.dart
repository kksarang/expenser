import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  String? get currentUid => _auth.currentUser?.uid;

  CollectionReference _getNotificationsCollection() {
    if (currentUid == null) {
      throw Exception('User not logged in');
    }
    return _firestore
        .collection('users')
        .doc(currentUid)
        .collection('notifications');
  }

  // Set up Firebase Cloud Messaging
  Future<void> setupFirebaseMessaging() async {
    // Request permission (required for iOS, mostly auto-granted on newer Androids depending on OS version but good practice)
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('User granted permission');
      }
    } else {
      if (kDebugMode) {
        print('User declined or has not accepted permission');
      }
    }

    // Get the FCM token for this device
    try {
      String? token = await _messaging.getToken();
      if (token != null && currentUid != null) {
        // Save token to user profile if we wanted to send remote pushes from a server
        await _firestore.collection('users').doc(currentUid).set({
          'fcmToken': token,
        }, SetOptions(merge: true));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get FCM token: $e');
      }
    }

    // Foreground message handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');
      }

      if (message.notification != null) {
        if (kDebugMode) {
          print('Message also contained a notification: ${message.notification}');
        }
        // Here we could show a local notification overlay if desired, 
        // but adding to Firestore usually suffices for in-app DB sync.
      }
    });
  }

  // Get notifications stream
  Stream<List<NotificationEntity>> getNotifications() {
    if (currentUid == null) return const Stream.empty();

    return _getNotificationsCollection()
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return NotificationEntity.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  // Add a new notification
  Future<void> createNotification(NotificationEntity notification) async {
    if (currentUid == null) return;
    try {
      await _getNotificationsCollection().add(notification.toMap());
    } catch (e) {
      if (kDebugMode) {
        print('Error creating notification: $e');
      }
    }
  }

  // Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    if (currentUid == null) return;
    try {
      await _getNotificationsCollection().doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error marking notification as read: $e');
      }
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    if (currentUid == null) return;
    try {
      var unreadDocs = await _getNotificationsCollection()
          .where('isRead', isEqualTo: false)
          .get();
      
      WriteBatch batch = _firestore.batch();
      for (var doc in unreadDocs.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      if (kDebugMode) {
        print('Error marking all as read: $e');
      }
    }
  }

  // Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    if (currentUid == null) return;
    try {
      await _getNotificationsCollection().doc(notificationId).delete();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting notification: $e');
      }
    }
  }
}

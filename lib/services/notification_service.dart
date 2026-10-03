import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'auth_service.dart';

class NotificationItem {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type; // 'booking', 'payment', 'cancellation', 'system'
  final bool read;
  final DateTime createdAt;

  NotificationItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.read = false,
    required this.createdAt,
  });

  factory NotificationItem.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parsedDate = DateTime.now();
    if (map['createdAt'] is Timestamp) {
      parsedDate = (map['createdAt'] as Timestamp).toDate();
    } else if (map['createdAt'] is int) {
      parsedDate = DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int);
    }

    return NotificationItem(
      id: docId,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      type: map['type'] ?? 'system',
      read: map['read'] ?? false,
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'read': read,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _notificationsCol =>
      _firestore.collection('notifications');

  /// Live stream of current user's notifications
  Stream<List<NotificationItem>> streamUserNotifications([String? userId]) {
    final uid = userId ?? AuthService().currentUser?.uid;
    if (uid == null) {
      return Stream.value([]);
    }

    return _notificationsCol
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => NotificationItem.fromMap(doc.data(), doc.id))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// Create a notification in Firestore
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String message,
    String type = 'system',
  }) async {
    try {
      await _notificationsCol.add({
        'userId': userId,
        'title': title,
        'message': message,
        'type': type,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error creating notification: $e');
    }
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationsCol.doc(notificationId).update({'read': true});
    } catch (e) {
      debugPrint('Error marking notification read: $e');
    }
  }

  /// Mark all notifications as read for user
  Future<void> markAllAsRead(String userId) async {
    try {
      final snapshot = await _notificationsCol
          .where('userId', isEqualTo: userId)
          .where('read', isEqualTo: false)
          .get();
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'read': true});
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Error marking all notifications read: $e');
    }
  }
}

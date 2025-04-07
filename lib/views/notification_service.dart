import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ Function to send a notification
  Future<void> sendNotification({
    required String receiverId,
    required String type, // 'message', 'post_like', 'comment'
    required String message,
    String? postId,
    String? senderId,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'receiverId': receiverId,
        'senderId': senderId ?? FirebaseAuth.instance.currentUser!.uid,
        'type': type,
        'message': message,
        'postId': postId,
        'isRead': false, // Track read/unread status
        'timestamp': FieldValue.serverTimestamp(),
      });

      print("✅ Notification sent successfully");
    } catch (e) {
      print('❌ Error sending notification: $e');
    }
  }

  // ✅ Function to fetch user notifications
  Stream<List<Map<String, dynamic>>> getUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('receiverId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              var data = doc.data();
              data['id'] = doc.id; // Add document ID for updates
              return data;
            }).toList());
  }

  // ✅ Function to mark a notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });
      print("✅ Notification marked as read");
    } catch (e) {
      print('❌ Error marking notification as read: $e');
    }
  }
}

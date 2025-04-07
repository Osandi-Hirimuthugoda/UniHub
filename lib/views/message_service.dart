import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notification_service.dart';

class MessageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();

  // ✅ Function to send a message
  Future<void> sendMessage(String receiverId, String message) async {
    try {
      await _firestore.collection('messages').add({
        'senderId': _auth.currentUser!.uid,
        'receiverId': receiverId,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // ✅ Send notification
      await _notificationService.sendNotification(
        receiverId: receiverId,
        type: "message",
        message: "You have a new message!",
      );

      print("✅ Message sent and notification triggered");
    } catch (e) {
      print("❌ Error sending message: $e");
    }
  }
}

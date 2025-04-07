import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notification_service.dart';

class LikeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();

  // ✅ Function to like a post
  Future<void> likePost(String postId, String postOwnerId) async {
    try {
      await _firestore.collection('likes').add({
        'postId': postId,
        'userId': _auth.currentUser!.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // ✅ Send notification to the post owner
      await _notificationService.sendNotification(
        receiverId: postOwnerId,
        type: "post_like",
        message: "Someone liked your post!",
      );

      print("✅ Post liked and notification sent");
    } catch (e) {
      print("❌ Error liking post: $e");
    }
  }
}

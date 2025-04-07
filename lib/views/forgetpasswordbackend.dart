import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Send password reset email
  Future<void> resetPassword(String email, BuildContext context) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      Navigator.pushNamed(context, '/success'); // Navigate to success page
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  // Update password and navigate to login
  Future<void> updatePassword(String newPassword, BuildContext context) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Password updated successfully!")),
        );
        Navigator.pushNamed(context, '/login'); // Navigate to login page
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  updateUserSettings(String uid, Map<String, dynamic> newSettings) {}

  getUserSettings(String uid) {}
}

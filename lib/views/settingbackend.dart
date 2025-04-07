import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign in method
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return userCredential.user;
    } catch (e) {
      print("Error signing in: $e");
      return null;
    }
  }

  // Sign out method
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Change password
  Future<void> changePassword(String newPassword) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await user.updatePassword(newPassword);
    }
  }

  // Get user settings from Firestore
  Future<Map<String, dynamic>?> getUserSettings(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      return doc.exists ? doc.data() as Map<String, dynamic> : null;
    } catch (e) {
      print("Error fetching user settings: $e");
      return null;
    }
  }

  // Update user settings
  Future<void> updateUserSettings(String uid, Map<String, dynamic> settings) async {
    try {
      await _firestore.collection('users').doc(uid).set(settings, SetOptions(merge: true));
    } catch (e) {
      print("Error updating settings: $e");
    }
  }

  loadUserSettings(String uid) {}

  storeUserSettings(String uid, bool bool) {}
}

// Settings Controller using GetX
class SettingsController extends GetxController {
  final AuthService _authService = AuthService();
  RxBool isDarkMode = false.obs;
  RxMap userSettings = {}.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  void toggleDarkMode() {
    isDarkMode.value = !isDarkMode.value;
  }

  Future<void> loadSettings() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Map<String, dynamic>? settings = await _authService.getUserSettings(user.uid);
      if (settings != null) {
        userSettings.value = settings;
      }
    }
  }

  Future<void> saveSettings(Map<String, dynamic> newSettings) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _authService.updateUserSettings(user.uid, newSettings);
      userSettings.value = newSettings;
    }
  }
}

// Navigation to Notification Page
class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notifications")),
      body: Center(child: Text("Notification Settings")),
    );
  }
}

// Navigation to Change Password Page
class ChangePasswordPage extends StatelessWidget {
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Change Password")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "New Password"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _authService.changePassword(_passwordController.text);
                Get.snackbar("Success", "Password updated successfully");
              },
              child: Text("Update Password"),
            ),
          ],
        ),
      ),
    );
  }
}

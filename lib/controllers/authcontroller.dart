import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/views/home.dart';
import 'package:flutter_application_1/views/homepage.dart';
import 'package:flutter_application_1/views/login.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  var nameController = TextEditingController();
  var usernameController = TextEditingController();
  var emailController = TextEditingController();
  var mobileController = TextEditingController();
  var passwordController = TextEditingController();
  UserCredential? userCredential;

  @override
  void onInit() {
    super.onInit();
    isUserAlreadyLoggedIn();
  }

  isUserAlreadyLoggedIn() async {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        Get.offAll(() => const Home());
      } else {
        Get.offAll(() => const LoginPage());
      }
    });
  }

  loginUser() async {
    try {
      userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      Get.offAll(() => const HomeScreen());
    } catch (e) {
      Get.snackbar("Login Failed", e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  signupUser() async {
    try {
      userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      User? user = userCredential!.user;
      if (user != null) {
        await user.updateDisplayName(usernameController.text);
        await user.reload();
        user = FirebaseAuth.instance.currentUser;
        await storeUserData(
          user!.uid,
          nameController.text,
          emailController.text,
          mobileController.text,
          usernameController.text,
        );
        Get.offAll(() => const HomeScreen());
      }
    } catch (e) {
      Get.snackbar("Signup Failed", e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      rethrow;
    }
  }

  storeUserData(String uid, String fullname, String email, String mobile, String username) async {
    var store = FirebaseFirestore.instance.collection('users').doc(uid);
    await store.set({
      'uid': uid,
      'fullname': fullname,
      'email': email,
      'mobile': mobile,
      'username': username,
      // No default profilePic; user sets it via EditProfilePage
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}

class ResetPassword {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return "Password reset email sent!";
    } catch (e) {
      return e.toString();
    }
  }
}
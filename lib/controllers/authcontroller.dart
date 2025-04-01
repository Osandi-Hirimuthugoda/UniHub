import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
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

  isUserAlreadyLoggedIn() async {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        Get.offAll(() => const HomeScreen());
      } else {
        Get.offAll(() => const LoginPage());
      }
    });
  }

  loginUser() async {
    userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailController.text, password: passwordController.text);
  }

  signupUser() async {
    userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: emailController.text, password: passwordController.text);
    await storeUserData(userCredential!.user!.uid, nameController.text, emailController.text, mobileController.text, usernameController.text);
  }

  storeUserData(String uid, String fullname, String email, String mobile, String username) async {
    var store = FirebaseFirestore.instance.collection('users').doc(uid);
    await store.set({'fullname': fullname, 'email': email, 'mobile': mobile, 'username': username});
  }

  signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_application_1/controllers/authcontroller.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthController controller = AuthController();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade300, Colors.pink.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centers content
          children: [
            Text(
              'UNIHUB',
              style: TextStyle(
                fontFamily: 'Lobster',
                fontSize: 48,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 40),

            // White Card UI for Input Fields
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10.0,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Username Field
                    GetBuilder<AuthController>(
                      builder: (controller) {
                        return TextField(
                          controller: controller.emailController, // Add controller here
                          decoration: InputDecoration(
                            hintText: 'Email',
                            hintStyle: TextStyle(color: Colors.grey),
                            prefixIcon: Icon(Icons.person, color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0),
                              borderSide: BorderSide(color: Colors.purple),
                            ),
                          ),
                          style: TextStyle(color: Colors.black),
                        );
                      },
                    ),
                    SizedBox(height: 16.0),

                    // Password Field
                    GetBuilder<AuthController>(
                      builder: (controller) {
                        return TextField(
                          controller: controller.passwordController, // Add controller here
                          decoration: InputDecoration(
                            hintText: 'Password',
                            hintStyle: TextStyle(color: Colors.grey),
                            prefixIcon: Icon(Icons.person, color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0),
                              borderSide: BorderSide(color: Colors.purple),
                            ),
                          ),
                          style: TextStyle(color: Colors.black),
                        );
                      },
                    ),
                    SizedBox(height: 16.0),

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/newpswd ');
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(color: Colors.purple, fontSize: 12),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),

                    // Login Button
                    ElevatedButton(
                      onPressed: ()  {
                        /*await controller.loginUser();
                        if (controller.userCredential != null) {
                          Get.to(() => const HomeScreen()); // Navigate to home page if login is successful
                        } else {
                          Get.snackbar(
                            "Login Failed",
                            "Invalid email or password. Please try again.",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                        }*/
                        Navigator.pushNamed(context, '/home');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 215, 19, 117),
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        elevation: 5,
                      ),
                      child: Center(
                        child: Text(
                          'Login',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.0),

            // Sign Up Text
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register'); // Navigate to SignUp
              },
              child: Text(
                "Don't have an account? Sign Up",
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

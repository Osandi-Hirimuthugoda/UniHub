import 'package:flutter/material.dart';
import 'package:flutter_application_1/controllers/authcontroller.dart';
import 'package:flutter_application_1/views/login.dart';
import 'package:get/get.dart';


class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
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
        padding: EdgeInsets.all(16),
        child: Stack(
          children: [
            Positioned(
              top: -screenWidth * 0.1,
              left: -screenWidth * 0.1,
              child: Transform.rotate(
                angle: -0.785398, // -45 degrees in radians
                child: Container(
                  width: screenWidth * 1.5,
                  height: screenWidth * 1.5,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'UNIHUB',
                  style: TextStyle(
                    fontFamily: 'Lobster',
                    fontSize: screenWidth * 0.1,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: screenHeight * 0.02),
                        _buildTextField(
                          hintText: 'Email',
                          icon: Icons.person_outline,
                          textcontroller: controller.emailController,
                        ),
                        _buildTextField(
                          hintText: 'Mobile Number',
                          icon: Icons.phone,
                          textcontroller: controller.mobileController,
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        _buildTextField(
                          hintText: 'Password',
                          icon: Icons.lock,
                          obscureText: true,
                          textcontroller: controller.passwordController,
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        _buildTextField(
                          hintText: 'Full Name',
                          icon: Icons.person,
                          textcontroller: controller.nameController,
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        _buildTextField(
                          hintText: 'Username',
                          icon: Icons.person_outline,
                          textcontroller: controller.usernameController,
                        ),
                  
                        SizedBox(height: screenHeight * 0.02),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: ElevatedButton(
                            onPressed: () async {
                              await controller.signupUser();

                              if (controller.userCredential != null) {
                                Get.offAll(() => const LoginPage());
                              } else {
                                Get.snackbar(
                                  "Signup Failed",
                                  "Could not create account. Please try again.",
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                              }
                            }, 
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 182, 34, 130),
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Register',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.04,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                  child: Text(
                    'Have an account? Log in',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.04,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    IconData? icon,
    bool obscureText = false,
    TextEditingController? textcontroller,
  }) {
    return TextField(
      controller: textcontroller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white),
        prefixIcon: icon != null ? Icon(icon, color: Colors.white) : null,
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
      style: TextStyle(color: Colors.white),
    );
  }
}

import 'package:flutter/material.dart';

class TroubleLoggingInPage extends StatelessWidget {
  const TroubleLoggingInPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Back button at the top-left corner
          Positioned(
            top: screenHeight * 0.05, // Adjust top padding as needed
            left: screenWidth * 0.05, // Adjust left padding as needed
            child: IconButton(
              icon: Icon(Icons.arrow_back, size: 24),
              onPressed: () {
                // Handle back button press
              },
            ),
          ),

          // Main content
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        height: screenHeight *
                            0.1), // Add space for the back button
                    Image.network(
                      'https://storage.googleapis.com/a1aa/image/ENcG9EmA8Wh1zCqceLKjRhF1ZhLmqAVn289TCubfcno.jpg',
                      height: screenHeight * 0.12,
                      width: screenHeight * 0.12,
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    Text(
                      'Trouble logging in?',
                      style: TextStyle(
                        fontSize: screenWidth * 0.06,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      'Enter Email Address',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: const Color.fromARGB(255, 81, 80, 80),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'example@gmail.com',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.05,
                          vertical: screenHeight * 0.02,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    Container(
                      width: double.infinity,
                      height: screenHeight * 0.06,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: LinearGradient(
                          colors: [Color(0xFF9C27B0), Color(0xFF673AB7)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle send button press
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.transparent,
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Send',
                          style: TextStyle(
                            color: const Color.fromARGB(255, 251, 251, 251),
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class NewPasswordPage extends StatelessWidget {
  const NewPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Back button at the top-left corner
          Positioned(
            top: screenHeight * 0.05, // Adjust top padding as needed
            left: screenWidth * 0.05, // Adjust left padding as needed
            child: IconButton(
              icon: Icon(Icons.arrow_back),
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                        height: screenHeight *
                            0.1), // Add space for the back button
                    Text(
                      'New Password',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: screenWidth * 0.06, // Responsive font size
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.05),
                    Text(
                      'Enter New Password',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04, // Responsive font size
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'At least 8 digits',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.05,
                          vertical: screenHeight * 0.02,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    Text(
                      'Confirm Password',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04, // Responsive font size
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: '******',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.05,
                          vertical: screenHeight * 0.02,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.05),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color.fromARGB(255, 151, 65, 226),
                            Color.fromARGB(255, 210, 129, 191)
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          // Your onPressed logic here
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.02),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          backgroundColor: Colors
                              .transparent, // Make button background transparent
                          shadowColor: Colors.transparent, // Remove shadow
                        ),
                        child: Text(
                          'Confirm',
                          style: TextStyle(
                            fontSize:
                                screenWidth * 0.04, // Responsive font size
                            color: Colors.white,
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

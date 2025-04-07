import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About UNIHUB'),
        backgroundColor: const Color.fromARGB(255, 226, 16, 233),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Welcome to UNIHUB',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'UNIHUB is a social platform exclusively for NSBM University students. It enables students to connect, share updates, organize events, and explore the student marketplace.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Key Features:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text('- Social feed for student interactions'),
            Text('- Event creation and participation'),
            Text('- Student marketplace for buying and selling'),
            Text('- Private and group messaging'),
            SizedBox(height: 20),
            Text(
              'Special Features:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text('- Special posts can be featured on the homepage banners for three days.'),
            Text('- Payment must be completed in person on campus before the post is published.'),
            Text('- Contact us at: 0915687742 for more details.'),
            SizedBox(height: 20),
            Text(
              'Development Team:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text('UI/UX Designer: Malindu Pabasara'),
            Text('Front-end Developers: Osandi Hirimuthugoda, Gamodya Rajasooria, Isuri Pabasara, Mindiya Kulathilaka, Movindu Abhishek, Malindu Pabasara, Yumin'),
            Text('Back-end Developers: Osandi Hirimuthugoda, Gamodya Rajasooria, Isuri Pabasara'),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: Text(
                  'Back to Settings',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

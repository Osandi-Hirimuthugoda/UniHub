import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/views/eventcategorypost.dart';
import 'package:flutter_application_1/views/eventchatscreen.dart';

class EventsApp extends StatelessWidget {
  const EventsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: EventsScreen());
  }
}

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final List<String> categories = [
    "Academic and Educational",
    "Religious and Cultural",
    "Sports",
    "Professional Development",
    "Social",
    "Innovations and Tech",
  ];

  final List<IconData> categoryIcons = [
    Icons.school,
    Icons.group,
    Icons.sports_handball,
    Icons.work,
    Icons.social_distance,
    Icons.computer,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 50),
              child: Center(child: Text("EVENTS", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold))),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text("HAPPENING TODAY", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .where('category', isEqualTo: 'Event')
                  .orderBy('timestamp', descending: true)
                  .limit(3)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return Center(child: Text('No events happening today. Add a new event!'));
                return SizedBox(
                  height: 160,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var post = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                      return _buildEventCard(
                        post['caption'] ?? 'Untitled Event',
                        post['imagePath'] ?? '',
                        post['userId'] ?? 'unknown',
                      );
                    },
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text("EVENT CATEGORIES", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.8,
                ),
                itemCount: 6,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EventCategoryPostsScreen(category: categories[index]))),
                    child: Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: LinearGradient(colors: [Colors.blue, Color.fromARGB(255, 103, 147, 238)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(9.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(categoryIcons[index], size: 32, color: Colors.white),
                            Text(categories[index], style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(String title, String imagePath, String userId) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 220,
        margin: EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: imagePath.isNotEmpty && File(imagePath).existsSync()
              ? DecorationImage(image: FileImage(File(imagePath)), fit: BoxFit.cover)
              : null,
          color: imagePath.isEmpty || !File(imagePath).existsSync() ? Colors.grey : null,
        ),
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      backgroundColor: Colors.black.withOpacity(0.3),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 28, 129, 175),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(seller: userId))),
                    child: Text("JOIN NOW", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
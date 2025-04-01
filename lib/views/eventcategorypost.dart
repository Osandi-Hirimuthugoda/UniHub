import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/views/eventchatscreen.dart';

class EventCategoryPostsScreen extends StatelessWidget {
  final String category;
  const EventCategoryPostsScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    print('Loading EventCategoryPostsScreen for category: $category'); // Debug log
    return Scaffold(
      appBar: AppBar(
        title: Text("EVENTS - $category", style: TextStyle(fontFamily: "Cursive", fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .where('category', isEqualTo: 'Event')
            .where('subcategory', isEqualTo: category)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print('Error in StreamBuilder: ${snapshot.error}'); // Debug log
            return Center(child: Text("Error loading events: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            print('No events found for category: $category'); // Debug log
            return Center(child: Text("No events in this category. Add a new event!"));
          }

          final posts = snapshot.data!.docs;
          print('Found ${posts.length} events for category: $category'); // Debug log
          for (var post in posts) {
            print('Post data: ${post.data()}'); // Debug log
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              var post = posts[index].data() as Map<String, dynamic>;
              return PostCard(
                seller: post['userId'] ?? 'USER_NAME',
                profilePic: 'https://source.unsplash.com/50x50/?person',
                imagePath: post['imagePath'] ?? '',
                description: post['caption'] ?? 'No description',
              );
            },
          );
        },
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final String seller;
  final String profilePic;
  final String imagePath;
  final String description;

  const PostCard({super.key, required this.seller, required this.profilePic, required this.imagePath, required this.description});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(backgroundImage: NetworkImage(profilePic), radius: 20),
                SizedBox(width: 10),
                FutureBuilder(
                  future: FirebaseFirestore.instance.collection('users').doc(seller).get(),
                  builder: (context, snapshot) {
                    return Text(snapshot.hasData ? snapshot.data!['username'] ?? 'Unknown' : 'Loading...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16));
                  },
                ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imagePath.isNotEmpty && File(imagePath).existsSync()
                ? Image.file(File(imagePath), width: double.infinity, height: 400, fit: BoxFit.cover)
                : Container(width: double.infinity, height: 400, color: Colors.grey, child: Center(child: Text('Image not found'))),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(description, style: TextStyle(fontSize: 14, color: Colors.black87)),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                IconButton(icon: Icon(Icons.favorite_border, size: 28), onPressed: () {}),
                IconButton(icon: Icon(Icons.send, size: 28), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(seller: seller)))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
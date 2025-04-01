import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/views/eventchatscreen.dart';

class CategoryPostsScreen extends StatelessWidget {
  final String category;
  const CategoryPostsScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "MARKETPLACE - $category",
          style: TextStyle(
            fontFamily: "Cursive",
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .where('category', isEqualTo: 'Marketplace')
            .where('subcategory', isEqualTo: category)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No items in this category"));
          }
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var post = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return PostCard(
                seller: 'USER_NAME',
                profilePic: 'https://source.unsplash.com/50x50/?person',
                imagePath: post['imagePath'],
                description: post['caption'],
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

  const PostCard({super.key, 
    required this.seller,
    required this.profilePic,
    required this.imagePath,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 20),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Seller Info
          Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(profilePic),
                  radius: 20,
                ),
                SizedBox(width: 10),
                Text(
                  seller,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
          // Post Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: File(imagePath).existsSync()
                ? Image.file(
                    File(imagePath),
                    width: double.infinity,
                    height: 400,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: double.infinity,
                    height: 400,
                    color: Colors.grey,
                    child: Center(child: Text('Image not found')),
                  ),
          ),
          // Description Text Below Image
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              description,
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
          // Like, Message Buttons
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.favorite_border, size: 28),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.send, size: 28),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(seller: seller),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
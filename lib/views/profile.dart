import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  String username = "Loading...";
  String bio = "Loading...";
  String profileImageUrl = "";
  List<dynamic> myPosts = [];
  List<String> savedPosts = [];

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchUserPosts();
  }

  Future<void> fetchUserData() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userDoc.exists) {
      setState(() {
        var userData = userDoc.data() as Map<String, dynamic>;
        username = userData['username'] ?? "Unknown User";
        bio = userData['bio'] ?? "Add a bio";
        profileImageUrl = userData['profileImageUrl'] ?? "";
      });
    }
  }

  Future<void> fetchUserPosts() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    QuerySnapshot postSnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();

    setState(() {
      myPosts = postSnapshot.docs.map((doc) => doc['imageUrl']).toList();
    });
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.bookmark),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SavedPostsPage(savedPosts: savedPosts),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(context, '/editprofile');
            },
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.red), // Styled Logout Button
            onPressed: logout, // Calls logout function
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          CircleAvatar(
            radius: 50,
            backgroundImage: profileImageUrl.isNotEmpty
                ? NetworkImage(profileImageUrl)
                : AssetImage('assets/default_profile.png') as ImageProvider,
          ),
          SizedBox(height: 20),
          Text(
            username,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              bio,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
          SizedBox(height: 10),
          Text(
            '${myPosts.length} POSTS',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: 10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: myPosts.length,
              itemBuilder: (context, index) {
                return Image.network(
                  myPosts[index],
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SavedPostsPage extends StatelessWidget {
  final List<dynamic> savedPosts;
  const SavedPostsPage({super.key, required this.savedPosts});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Saved Posts')),
      body: savedPosts.isEmpty
          ? Center(child: Text("No saved posts"))
          : GridView.builder(
              padding: EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: savedPosts.length,
              itemBuilder: (context, index) {
                return Image.network(
                  savedPosts[index],
                  fit: BoxFit.cover,
                );
              },
            ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NewPostScreen extends StatefulWidget {
  const NewPostScreen({super.key});

  @override
  _NewPostScreenState createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  File? _image;
  final TextEditingController _captionController = TextEditingController();
  String? _category;
  String? _subcategory;
  final ImagePicker _picker = ImagePicker();

  final List<String> categories = ['Marketplace', 'Event'];
  final Map<String, List<String>> subcategories = {
    'Marketplace': [
      'Educational',
      'Accessories',
      'Food And Beverages',
      'Secondhand Items',
      'Services',
      'Event Tickets',
    ],
    'Event': [
      'Academic and Educational',
      'Religious and Cultural',
      'Sports',
      'Professional Development',
      'Social',
      'Innovations and Tech',
    ],
  };

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String?> _saveImageLocally() async {
    if (_image == null) return null;
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/posts';
      await Directory(imagePath).create(recursive: true);
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      String filePath = '$imagePath/$fileName';
      await _image!.copy(filePath);
      return filePath;
    } catch (e) {
      print('Error saving image: $e');
      return null;
    }
  }

  Future<String?> _getUserDocId(String authUid) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('uid_to_user_doc').doc(authUid).get();
      return doc.exists ? doc['userDocId'] as String : null;
    } catch (e) {
      print('Error fetching user document ID: $e');
      return null;
    }
  }

  Future<String> _createUserInFirestore(String username, String email) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');

    DocumentReference userDocRef = await FirebaseFirestore.instance.collection('users').add({
      'uid': user.uid,
      'username': username,
      'email': email,
      'profilePic': 'https://source.unsplash.com/50x50/?person',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await FirebaseFirestore.instance.collection('uid_to_user_doc').doc(user.uid).set({'userDocId': userDocRef.id});

    return userDocRef.id;
  }

  Future<void> _uploadPost() async {
    if (_image == null || _category == null || _subcategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an image, category, and subcategory')),
      );
      return;
    }

    try {
      String? imagePath = await _saveImageLocally();
      if (imagePath == null) throw Exception('Failed to save image');

      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      String? userDocId = await _getUserDocId(user.uid);
      userDocId ??= await _createUserInFirestore(user.displayName ?? 'Anonymous', user.email ?? '');

      await FirebaseFirestore.instance.collection('posts').add({
        'userId': userDocId,
        'imagePath': imagePath,
        'caption': _captionController.text,
        'category': _category,
        'subcategory': _subcategory,
        'timestamp': FieldValue.serverTimestamp(),
        'likesCount': 0,
        'likedBy': [],
        'comments': [],
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post uploaded successfully')),
      );
    } catch (e) {
      print('Error uploading post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload post: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: Text('New Post', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(10),
                  image: _image != null ? DecorationImage(image: FileImage(_image!), fit: BoxFit.cover) : null,
                ),
                child: _image == null ? Center(child: Icon(Icons.add_a_photo, color: Colors.white)) : null,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _captionController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Add a caption...',
                hintStyle: TextStyle(color: Colors.grey),
                border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
              ),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _category,
              hint: Text('Select Category', style: TextStyle(color: Colors.white)),
              dropdownColor: Colors.black,
              items: categories.map((category) => DropdownMenuItem(value: category, child: Text(category, style: TextStyle(color: Colors.white)))).toList(),
              onChanged: (value) => setState(() {
                _category = value;
                _subcategory = null;
              }),
              decoration: InputDecoration(
                border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
              ),
            ),
            SizedBox(height: 16),
            if (_category != null)
              DropdownButtonFormField<String>(
                value: _subcategory,
                hint: Text('Select Subcategory', style: TextStyle(color: Colors.white)),
                dropdownColor: Colors.black,
                items: subcategories[_category!]!.map((subcategory) => DropdownMenuItem(value: subcategory, child: Text(subcategory, style: TextStyle(color: Colors.white)))).toList(),
                onChanged: (value) => setState(() => _subcategory = value),
                decoration: InputDecoration(
                  border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                ),
              ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _uploadPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                child: Text('Post', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
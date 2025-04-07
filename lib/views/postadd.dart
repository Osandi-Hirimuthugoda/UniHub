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

  final List<String> categories = ['General', 'Marketplace', 'Event'];
  final Map<String, List<String>> subcategories = {
    'General': [],
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

  Future<void> _uploadPost() async {
    if (_image == null || _category == null || (_category != 'General' && _subcategory == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an image, category, and subcategory (if applicable)')),
      );
      return;
    }

    try {
      String? imagePath = await _saveImageLocally();
      if (imagePath == null) throw Exception('Failed to save image');

      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      String userDocId = user.uid;

      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userDocId).get();
      if (!userDoc.exists) {
        throw Exception('User document not found. Please register again.');
      }

      await FirebaseFirestore.instance.collection('posts').add({
        'userId': userDocId,
        'imagePath': imagePath,
        'caption': _captionController.text,
        'category': _category,
        'subcategory': _category == 'General' ? null : _subcategory,
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Create New Post', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.grey[400]!, width: 1),
                  borderRadius: BorderRadius.circular(12),
                  image: _image != null ? DecorationImage(image: FileImage(_image!), fit: BoxFit.cover) : null,
                ),
                child: _image == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, color: Colors.grey[600], size: 40),
                            SizedBox(height: 8),
                            Text('Add Image', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                          ],
                        ),
                      )
                    : null,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Caption',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _captionController,
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: 'Add a caption...',
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 24),
            Text(
              'Category',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _category,
              hint: Text('Select Category', style: TextStyle(color: Colors.grey)),
              isExpanded: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category, style: TextStyle(color: Colors.black)),
                );
              }).toList(),
              onChanged: (value) => setState(() {
                _category = value;
                _subcategory = null;
              }),
            ),
            SizedBox(height: 24),
            if (_category != null && _category != 'General')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Subcategory',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _subcategory,
                    hint: Text('Select Subcategory', style: TextStyle(color: Colors.grey)),
                    isExpanded: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: subcategories[_category!]!.map((subcategory) {
                      return DropdownMenuItem(
                        value: subcategory,
                        child: Text(subcategory, style: TextStyle(color: Colors.black)),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _subcategory = value),
                  ),
                  SizedBox(height: 24),
                ],
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/home');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  ),
                  child: Text('Cancel', style: TextStyle(color: Colors.black, fontSize: 16)),
                ),
                ElevatedButton(
                  onPressed: _uploadPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  ),
                  child: Text('Post', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
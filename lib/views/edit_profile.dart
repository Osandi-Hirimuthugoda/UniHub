import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  

  String? profileImagePath;
  File? _imageFile;
  String _selectedGender = "Male";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userData =
        await _firestore.collection('users').doc(user.uid).get();
          if (userData.exists) {
            Map<String, dynamic>? data = userData.data() as Map<String, dynamic> ?;
            setState(() {
            _nameController.text = data ? ['fullname'] ?? '';
            _usernameController.text = data ? ['username'] ?? '';
            _websiteController.text = data ? ['website'] ?? '';
            _bioController.text = data ? ['bio'] ?? '';
            _emailController.text = data ? ['email'] ?? '';
            _mobileController.text = data ? ['mobile'] ?? '';
            _selectedGender = data ? ['gender'] ?? "Male";
            profileImagePath = data ? ['profileImage'];
          });
          }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File newImage = File(pickedFile.path);
      String savedImagePath = await _saveImageLocally(newImage);

      setState(() {
        _imageFile = newImage;
        profileImagePath = savedImagePath;
      });
    }
  }

  Future<String> _saveImageLocally(File imageFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = path.basename(imageFile.path);
    final savedImage = File('${directory.path}/$fileName');

    await imageFile.copy(savedImage.path);
    return savedImage.path;
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'fullname': _nameController.text,
          'username': _usernameController.text,
          'website': _websiteController.text,
          'bio': _bioController.text,
          'email': _emailController.text,
          'mobile': _mobileController.text,
          'gender': _selectedGender,
          'profileImage': profileImagePath, // Save local image path in Firestore
        });

        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: Text("Done", style: TextStyle(fontSize: 16)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!)
                      : (profileImagePath != null
                          ? FileImage(File(profileImagePath!))
                          : AssetImage("assets/default_profile.png"))
                              as ImageProvider,
                ),
              ),
              SizedBox(height: 8),
              TextButton(
                onPressed: _pickImage,
                child: Text("Change Profile Photo"),
              ),
              SizedBox(height: 16),
              _buildTextField("Name", _nameController),
              _buildTextField("Username", _usernameController),
              _buildTextField("Website", _websiteController),
              _buildTextField("Bio", _bioController, maxLines: 2),
              Divider(),
              Text("Private Information", style: TextStyle(fontSize: 18)),
              _buildTextField("Email", _emailController, enabled: false),
              _buildTextField("Mobile", _mobileController),
              _buildGenderSelector(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool enabled = true, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Gender", style: TextStyle(fontSize: 16)),
        Row(
          children: [
            Radio<String>(
              value: "Male",
              groupValue: _selectedGender,
              onChanged: (value) {
                setState(() {
                  _selectedGender = value!;
                });
              },
            ),
            Text("Male"),
            Radio<String>(
              value: "Female",
              groupValue: _selectedGender,
              onChanged: (value) {
                setState(() {
                  _selectedGender = value!;
                });
              },
            ),
            Text("Female"),
          ],
        ),
      ],
    );
  }
}


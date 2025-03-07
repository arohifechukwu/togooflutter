import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import 'UserModel.dart';
import 'login_screen.dart';

class UserEditProfile extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<UserEditProfile> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String userAvatar = '';
  String userId = '';
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  /// **Fetch user data from Firebase Realtime Database**
  Future<void> _fetchUserData() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user != null) {
      final DatabaseReference userRef = FirebaseDatabase.instance.ref().child('users/${user.uid}');
      final DataSnapshot snapshot = await userRef.get();

      if (snapshot.exists) {
        final userData = snapshot.value as Map?;
        final UserModel userModel = UserModel.fromMap(userData!);
        setState(() {
          userId = userModel.id;
          _nameController.text = userModel.name;
          _bioController.text = userModel.userBio;
          userAvatar = userModel.userPhotoUrl;
        });
      }
    }
  }

  /// **Pick Image from Gallery**
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  /// **Upload Image to Firebase Storage**
  Future<String?> _uploadImage(File imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('user_profile_pictures/$userId.jpg');
      await storageRef.putFile(imageFile);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print('🚨 Error uploading image: $e');
      return null;
    }
  }

  /// **Update User Profile**
  Future<void> _updateUserProfile() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user != null) {
      print("✅ Updating Profile...");

      String? imageUrl;
      if (_imageFile != null) {
        imageUrl = await _uploadImage(_imageFile!);
      }

      final DatabaseReference userRef = FirebaseDatabase.instance.ref().child('users/${user.uid}');
      UserModel updatedUser = UserModel(
        id: user.uid,
        name: _nameController.text,
        email: user.email!,
        userBio: _bioController.text,
        userPhotoUrl: imageUrl ?? userAvatar,
      );

      await userRef.update(updatedUser.toMap()).then((_) {
        setState(() {
          userAvatar = imageUrl ?? userAvatar;
        });

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("✅ Profile updated successfully!")));
      }).catchError((error) {
        print("🚨 Failed to update profile: $error");
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("❌ Failed to update profile")));
      });

      /// **Update Password If Provided**
      if (_passwordController.text.isNotEmpty) {
        try {
          await user.updatePassword(_passwordController.text.trim());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✅ Password updated successfully!')),
          );
        } catch (error) {
          print("🚨 Error updating password: $error");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ Error updating password')),
          );
        }
      }
    }
  }

  /// **Logout User**
  Future<void> _logoutUser() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Colors.grey,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey,
              radius: 50,
              backgroundImage: _imageFile != null
                  ? FileImage(_imageFile!)
                  : userAvatar.isNotEmpty
                  ? NetworkImage(userAvatar)
                  : AssetImage('assets/small_logo.png') as ImageProvider,
            ),
            TextButton(
              onPressed: _pickImage,
              child: Text('Change Profile Picture'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _bioController,
              decoration: InputDecoration(
                labelText: "Bio",
                border: OutlineInputBorder(),
              ),
              maxLines: 1,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: "New Password",
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateUserProfile,
              child: Text('Save Changes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _logoutUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                textStyle: TextStyle(fontSize: 16),
              ),
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}

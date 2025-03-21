import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  DatabaseReference? userRef;
  String? userRole;
  String? imageUrl;
  File? _imageFile;

  final _auth = FirebaseAuth.instance;
  final _storageRef = FirebaseStorage.instance.ref("ProfilePictures");

  @override
  void initState() {
    super.initState();
    _emailController.text = _auth.currentUser?.email ?? "";
    _findUserRoleAndLoadData();
  }

  Future<void> _findUserRoleAndLoadData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final roles = ["driver", "customer", "admin", "restaurant"];
    for (String role in roles) {
      final ref = FirebaseDatabase.instance.ref("$role/${user.uid}");
      final snapshot = await ref.get();
      if (snapshot.exists) {
        setState(() {
          userRole = role;
          userRef = ref;
        });
        _loadUserData(snapshot);
        break;
      }
    }
  }

  void _loadUserData(DataSnapshot snapshot) {
    final data = snapshot.value as Map<dynamic, dynamic>;
    _nameController.text = data["name"] ?? "";
    _addressController.text = data["address"] ?? "";
    _phoneController.text = data["phone"] ?? "";
    imageUrl = data["imageURL"] ?? null;
  }

  // Future<void> _selectImage() async {
  //   debugPrint("📸 Image picker triggered");
  //
  //   final picker = ImagePicker();
  //   final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  //
  //   if (pickedFile != null) {
  //     debugPrint("✅ Image picked: ${pickedFile.path}");
  //     setState(() => _imageFile = File(pickedFile.path));
  //   } else {
  //     debugPrint("❌ No image selected");
  //   }
  // }

  Future<void> _selectImage() async {
    final status = await Permission.photos.request(); // For Android 13+
    if (status.isDenied || status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission denied to access gallery')),
      );
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _uploadAndSave() async {
    if (_nameController.text.isEmpty || _addressController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    final updates = <String, dynamic>{
      "name": _nameController.text.trim(),
      "address": _addressController.text.trim(),
      "phone": _phoneController.text.trim(),
    };

    if (_imageFile != null) {
      final user = _auth.currentUser;
      final ref = _storageRef.child("${user!.uid}.jpg");
      final uploadTask = await ref.putFile(_imageFile!);
      imageUrl = await uploadTask.ref.getDownloadURL();
      updates["imageURL"] = imageUrl;
    }

    await userRef?.update(updates);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile Updated Successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile"), backgroundColor: Colors.orange),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Image
            GestureDetector(
              onTap: _selectImage,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: _imageFile != null
                    ? FileImage(_imageFile!)
                    : (imageUrl != null
                    ? CachedNetworkImageProvider(imageUrl!)
                    : const AssetImage("assets/images/ic_account2.png") as ImageProvider),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _selectImage,
              child: const Text("Upload Profile Picture"),
            ),

            const SizedBox(height: 20),

            _buildTextField("Full Name", _nameController),
            _buildTextField("Address", _addressController),
            _buildTextField("Phone Number", _phoneController, inputType: TextInputType.phone),
            _buildTextField("Email", _emailController, readOnly: true),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadAndSave,
              child: const Text("Save Changes", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType inputType = TextInputType.text, bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        readOnly: label == "Email" ? true : readOnly,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
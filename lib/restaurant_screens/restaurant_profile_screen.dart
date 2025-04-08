// Flutter version of RestaurantProfileActivity
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geocoding/geocoding.dart';

class RestaurantProfileScreen extends StatefulWidget {
  const RestaurantProfileScreen({Key? key}) : super(key: key);

  @override
  State<RestaurantProfileScreen> createState() => _RestaurantProfileScreenState();
}

class _RestaurantProfileScreenState extends State<RestaurantProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _picker = ImagePicker();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final List<String> _days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
  final Map<String, TextEditingController> _openControllers = {};
  final Map<String, TextEditingController> _closeControllers = {};
  File? _selectedImage;
  String? _imageURL;
  late DatabaseReference _restaurantRef;

  @override
  void initState() {
    super.initState();
    final uid = _auth.currentUser!.uid;
    _restaurantRef = FirebaseDatabase.instance.ref().child("restaurant").child(uid);
    _emailController.text = _auth.currentUser!.email ?? "";
    for (var day in _days) {
      _openControllers[day] = TextEditingController();
      _closeControllers[day] = TextEditingController();
    }
    _loadProfile();
  }

  void _loadProfile() async {
    final snapshot = await _restaurantRef.get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      _nameController.text = data['name'] ?? '';
      _addressController.text = data['address'] ?? '';
      _phoneController.text = data['phone'] ?? '';
      _imageURL = data['imageURL'];
      if (data['operatingHours'] != null) {
        final hours = Map<String, dynamic>.from(data['operatingHours']);
        for (var day in _days) {
          _openControllers[day]?.text = hours[day]?['open'] ?? '';
          _closeControllers[day]?.text = hours[day]?['close'] ?? '';
        }
      }
      setState(() {});
    }
  }

  Future<void> _chooseImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    final address = _addressController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || address.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fill all required fields")));
      return;
    }

    await _restaurantRef.update({
      "name": name,
      "address": address,
      "phone": phone,
    });

    for (var day in _days) {
      await _restaurantRef.child("operatingHours").child(day).update({
        "open": _openControllers[day]!.text,
        "close": _closeControllers[day]!.text,
      });
    }

    if (_selectedImage != null) {
      final ref = FirebaseStorage.instance.ref("restaurant_profile_images/${_auth.currentUser!.uid}.jpg");
      await ref.putFile(_selectedImage!);
      final url = await ref.getDownloadURL();
      await _restaurantRef.update({"imageURL": url});
      setState(() => _imageURL = url);
    }

    List<Location> locations = await locationFromAddress(address);
    if (locations.isNotEmpty) {
      await _restaurantRef.child("location").update({
        "latitude": locations[0].latitude,
        "longitude": locations[0].longitude,
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile updated")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text("Restaurant's Profile", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              CircleAvatar(
                radius: 60,
                backgroundImage: _selectedImage != null
                    ? FileImage(_selectedImage!)
                    : (_imageURL != null ? NetworkImage(_imageURL!) as ImageProvider : null),
                child: _imageURL == null && _selectedImage == null
                    ? const Icon(Icons.image, size: 60)
                    : null,
              ),
              TextButton(
                onPressed: _chooseImage,
                child: const Text("Change Image"),
              ),
              TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Restaurant Name")),
              TextField(controller: _addressController, decoration: const InputDecoration(labelText: "Address")),
              TextField(controller: _phoneController, decoration: const InputDecoration(labelText: "Phone")),
              TextField(controller: _emailController, readOnly: true, decoration: const InputDecoration(labelText: "Email")),
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Operating Hours", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              ..._days.map((day) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(day, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Row(
                    children: [
                      Expanded(
                          child: TextField(
                            controller: _openControllers[day],
                            decoration: const InputDecoration(hintText: "Open (e.g. 09:00)"),
                          )),
                      const SizedBox(width: 16),
                      Expanded(
                          child: TextField(
                            controller: _closeControllers[day],
                            decoration: const InputDecoration(hintText: "Close (e.g. 18:00)"),
                          )),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              )),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveProfile,
                child: const Text("Save Changes"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

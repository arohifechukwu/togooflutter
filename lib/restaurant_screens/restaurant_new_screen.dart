import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../restaurant_bottom_navigation_menu.dart';

class RestaurantNewScreen extends StatefulWidget {
  const RestaurantNewScreen({Key? key}) : super(key: key);

  @override
  State<RestaurantNewScreen> createState() => _RestaurantNewScreenState();
}

class _RestaurantNewScreenState extends State<RestaurantNewScreen> {
  final _auth = FirebaseAuth.instance;
  final _picker = ImagePicker();
  final _foodIdController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryInputController = TextEditingController();

  final List<String> _sections = [
    "Special Offers",
    "Top Picks",
    "New Menu Category",
    "Update Menu Category"
  ];
  String _selectedSection = "Special Offers";
  String _selectedDropdownCategory = "";
  List<String> _menuCategories = [];

  File? _imageFile;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _fetchMenuCategories();
  }

  Future<void> _fetchMenuCategories() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final ref = FirebaseDatabase.instance.ref("restaurant/$uid/menu");
    final snap = await ref.get();
    if (snap.exists) {
      final keys = snap.children.map((e) => e.key).whereType<String>().toList();
      setState(() => _menuCategories = keys);
    }
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _uploadImageAndSaveFood() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || _imageFile == null) return;

    final foodId = _foodIdController.text.trim();
    final desc = _descController.text.trim();
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final category = _selectedSection == "New Menu Category"
        ? _categoryInputController.text.trim()
        : _selectedDropdownCategory;

    if (foodId.isEmpty || desc.isEmpty || price <= 0 ||
        (_selectedSection.contains("Category") && category.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please fill all required fields")));
      return;
    }

    final uuid = const Uuid().v4();
    final storageRef = FirebaseStorage.instance
        .ref("restaurant_menu_images/$uid/$uuid.jpg");
    await storageRef.putFile(_imageFile!);
    final imageUrl = await storageRef.getDownloadURL();

    final foodData = {
      "id": foodId,
      "description": desc,
      "imageURL": imageUrl,
      "restaurantId": uid,
      "price": price
    };

    DatabaseReference dbRef;
    if (_selectedSection.contains("Category")) {
      dbRef = FirebaseDatabase.instance
          .ref("restaurant/$uid/menu/$category/$foodId");
    } else {
      dbRef = FirebaseDatabase.instance
          .ref("restaurant/$uid/$_selectedSection/$foodId");
    }

    await dbRef.set(foodData);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Food item added successfully!")));
    _clearFields();
  }

  void _clearFields() {
    _foodIdController.clear();
    _descController.clear();
    _priceController.clear();
    _categoryInputController.clear();
    setState(() => _imageFile = null);
  }

  @override
  Widget build(BuildContext context) {
    final showNewCategoryInput = _selectedSection == "New Menu Category";
    final showDropdown = _selectedSection == "Update Menu Category";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Food Item"),
        backgroundColor: Colors.orange, // 🟧 AppBar color
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedSection,
              items: _sections.map((s) => DropdownMenuItem(
                  value: s, child: Text(s))).toList(),
              onChanged: (val) => setState(() => _selectedSection = val!),
              decoration: const InputDecoration(labelText: "Select Section"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _foodIdController,
              decoration: const InputDecoration(labelText: "Food ID"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: "Description"),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Price (e.g. 12.50)"),
            ),
            if (showNewCategoryInput) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _categoryInputController,
                decoration: const InputDecoration(labelText: "New Category Name"),
              ),
            ],
            if (showDropdown) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedDropdownCategory.isNotEmpty
                    ? _selectedDropdownCategory
                    : null,
                items: _menuCategories.map((cat) => DropdownMenuItem(
                    value: cat, child: Text(cat))).toList(),
                onChanged: (val) => setState(() => _selectedDropdownCategory = val ?? ""),
                decoration: const InputDecoration(labelText: "Choose Category"),
              ),
            ],
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  image: _imageFile != null
                      ? DecorationImage(
                      image: FileImage(_imageFile!),
                      fit: BoxFit.cover)
                      : null,
                ),
                alignment: Alignment.center,
                child: _imageFile == null
                    ? const Text("Tap to select image")
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadImageAndSaveFood,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Create Food Item",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: RestaurantBottomNavigationMenu(
        currentIndex: 1,
      ),
    );
  }
}
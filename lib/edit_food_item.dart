import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class EditFoodItemScreen extends StatefulWidget {
  final String foodId, nodeType, restaurantId, category, foodName, foodDescription, imageURL;
  final double foodPrice;

  const EditFoodItemScreen({
    Key? key,
    required this.foodId,
    required this.nodeType,
    required this.restaurantId,
    required this.category,
    required this.foodName,
    required this.foodDescription,
    required this.foodPrice,
    required this.imageURL,
  }) : super(key: key);

  @override
  _EditFoodItemScreenState createState() => _EditFoodItemScreenState();
}

class _EditFoodItemScreenState extends State<EditFoodItemScreen> {
  final _foodNameController = TextEditingController();
  final _foodDescriptionController = TextEditingController();
  final _foodPriceController = TextEditingController();
  final _picker = ImagePicker();

  File? _imageFile;
  String? _imageUrl;
  late DatabaseReference _foodRef;

  @override
  void initState() {
    super.initState();

    _foodNameController.text = widget.foodName;
    _foodDescriptionController.text = widget.foodDescription;
    _foodPriceController.text = widget.foodPrice.toString();
    _imageUrl = widget.imageURL;

    _foodRef = widget.nodeType == "menu"
        ? FirebaseDatabase.instance
        .ref("restaurant")
        .child(widget.restaurantId)
        .child("menu")
        .child(widget.category)
        .child(widget.foodId)
        : FirebaseDatabase.instance
        .ref("restaurant")
        .child(widget.restaurantId)
        .child(widget.nodeType)
        .child(widget.foodId);
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<void> _saveChanges() async {
    String name = _foodNameController.text.trim();
    String description = _foodDescriptionController.text.trim();
    String priceText = _foodPriceController.text.trim();
    double price = double.tryParse(priceText) ?? 0.0;

    if (name.isEmpty || description.isEmpty || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    if (_imageFile != null) {
      final uuid = Uuid().v4();
      final storageRef = FirebaseStorage.instance
          .ref("restaurant_menu_images/${widget.restaurantId}/$uuid.jpg");
      await storageRef.putFile(_imageFile!);
      _imageUrl = await storageRef.getDownloadURL();
    }

    await _foodRef.update({
      "id": widget.foodId,
      "description": description,
      "price": price,
      "imageURL": _imageUrl,
    });

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Food item updated successfully")));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Food Item"),
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  image: _imageFile != null
                      ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                      : _imageUrl != null && _imageUrl!.isNotEmpty
                      ? DecorationImage(image: NetworkImage(_imageUrl!), fit: BoxFit.cover)
                      : null,
                ),
                alignment: Alignment.center,
                child: _imageFile == null && (_imageUrl == null || _imageUrl!.isEmpty)
                    ? const Text("Tap to select image")
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _foodNameController,
              decoration: const InputDecoration(labelText: "Food Name"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _foodDescriptionController,
              decoration: const InputDecoration(labelText: "Description"),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _foodPriceController,
              decoration: const InputDecoration(labelText: "Price"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                "Save Changes",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
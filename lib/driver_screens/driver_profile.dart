import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:togoo/driver_screens/driver_bottom_navigation_menu.dart';
import 'dart:io';

class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({Key? key}) : super(key: key);

  @override
  _DriverProfileScreenState createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  late DatabaseReference driverRef;
  late User currentUser;
  late String profileImageURL, carImageURL;
  late TextEditingController nameController, addressController, phoneController, emailController, carBrandController, carModelController, licensePlateController;
  File? profileImage, carImage;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser!;
    driverRef = FirebaseDatabase.instance.ref("driver").child(currentUser.uid);

    nameController = TextEditingController();
    addressController = TextEditingController();
    phoneController = TextEditingController();
    emailController = TextEditingController();
    carBrandController = TextEditingController();
    carModelController = TextEditingController();
    licensePlateController = TextEditingController();

    profileImageURL = '';
    carImageURL = '';

    loadDriverData();
  }

  // Load driver data
  void loadDriverData() {
    driverRef.once().then((DatabaseEvent snapshot) {
      if (snapshot.snapshot.value != null) {
        var driverData = snapshot.snapshot.value as Map;
        nameController.text = driverData['name'];
        addressController.text = driverData['address'];
        phoneController.text = driverData['phone'];
        emailController.text = driverData['email'];
        carBrandController.text = driverData['carBrand'];
        carModelController.text = driverData['carModel'];
        licensePlateController.text = driverData['licensePlate'];

        profileImageURL = driverData['imageURL'] ?? '';
        carImageURL = driverData['carPicture'] ?? '';

        setState(() {});
      }
    }).catchError((error) {
      print('Error loading driver data: $error');
    });
  }

  // Select image from gallery
  Future<void> selectImage(bool isProfileImage) async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isProfileImage) {
          profileImage = File(pickedFile.path);
        } else {
          carImage = File(pickedFile.path);
        }
      });
    }
  }

  // Upload image to Firebase Storage
  Future<String?> uploadImage(File imageFile, String imageType) async {
    String filePath = 'drivers/${currentUser.uid}/$imageType.jpg';
    final storageRef = FirebaseStorage.instance.ref().child(filePath);
    UploadTask uploadTask = storageRef.putFile(imageFile);
    TaskSnapshot taskSnapshot = await uploadTask;
    return await taskSnapshot.ref.getDownloadURL();
  }

  // Save profile data to Firebase
  Future<void> saveProfileData() async {
    String name = nameController.text.trim();
    String address = addressController.text.trim();
    String phone = phoneController.text.trim();
    String carBrand = carBrandController.text.trim();
    String carModel = carModelController.text.trim();
    String licensePlate = licensePlateController.text.trim();

    if (name.isEmpty || address.isEmpty || phone.isEmpty || carBrand.isEmpty || carModel.isEmpty || licensePlate.isEmpty) {
      showToast("Please fill all fields.");
      return;
    }

    Map<String, Object> updates = {
      'name': name,
      'address': address,
      'phone': phone,
      'carBrand': carBrand,
      'carModel': carModel,
      'licensePlate': licensePlate,
    };

    // Upload profile image if exists
    if (profileImage != null) {
      String? profileImageUrl = await uploadImage(profileImage!, 'profileImage');
      if (profileImageUrl != null) {
        updates['imageURL'] = profileImageUrl;
      }
    }

    // Upload car image if exists
    if (carImage != null) {
      String? carImageUrl = await uploadImage(carImage!, 'carImage');
      if (carImageUrl != null) {
        updates['carPicture'] = carImageUrl;
      }
    }

    driverRef.update(updates).then((_) {
      showToast("Profile Updated Successfully!");
      Navigator.pop(context); // Go back to the previous screen
    }).catchError((error) {
      showToast("Failed to update profile.");
    });
  }

  // Show toast message
  void showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Driver Profile",),
        backgroundColor: const Color(0xFFE37D2B),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: saveProfileData,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => selectImage(true),
              child: CircleAvatar(
                radius: 60,
                backgroundImage: profileImage != null
                    ? FileImage(profileImage!)
                    : NetworkImage(profileImageURL.isNotEmpty ? profileImageURL : 'https://via.placeholder.com/150') as ImageProvider,
                child: profileImage == null
                    ? Icon(Icons.camera_alt, size: 40, color: Colors.white)
                    : null,
              ),
            ),
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Name"),
            ),
            TextFormField(
              controller: addressController,
              decoration: InputDecoration(labelText: "Address"),
            ),
            TextFormField(
              controller: phoneController,
              decoration: InputDecoration(labelText: "Phone"),
            ),
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
              enabled: false,
            ),
            TextFormField(
              controller: carBrandController,
              decoration: InputDecoration(labelText: "Car Brand"),
            ),
            TextFormField(
              controller: carModelController,
              decoration: InputDecoration(labelText: "Car Model"),
            ),
            TextFormField(
              controller: licensePlateController,
              decoration: InputDecoration(labelText: "License Plate"),
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: () => selectImage(false),
              child: Image.asset(
                'assets/ic_car_placeholder.jpg',
                height: 150,
                width: 150,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: saveProfileData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFE37D2B),
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                'Save Changes',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: DriverBottomNavigationMenu(currentIndex: 3),
    );
  }
}
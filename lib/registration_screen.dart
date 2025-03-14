import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:togoo/registration_status.dart';
import 'login_screen.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _db = FirebaseDatabase.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // URL Controllers
  final TextEditingController _driverLicenseUrlController = TextEditingController();
  final TextEditingController _vehicleRegistrationUrlController = TextEditingController();
  final TextEditingController _restaurantLicenseUrlController = TextEditingController();
  final TextEditingController _retailLicenseUrlController = TextEditingController();

  String _selectedBusinessType = "Driver"; // Default selection
  bool _termsAccepted = false;
  bool _isLoading = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  Map<String, File?> _selectedFiles = {};


  // Define color palette
  final Color primaryColor = Color(0xFFF18D34); // Dark Orange
  final Color primaryVariant = Color(0xFFE67E22); // Slightly Darker Orange
  final Color secondaryColor = Color(0xFFFF9800); // Lighter Orange
  final Color white = Color(0xFFFFFFFF);
  final Color lightGray = Color(0xFFF5F5F5);
  final Color darkGray = Color(0xFF757575);
  final Color black = Color(0xFF000000);
  final Color buttonDefault = Color(0xFFF18D34);
  final Color buttonPressed = Color(0xFFE67E22);
  final Color buttonDisabled = Color(0xFFFFB066);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),

            // Logo
            Image.asset('assets/logo.png', width: 150, height: 150),
            const SizedBox(height: 20),

            // Slogan
            Text(
              "Register Your Business",
              style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: Colors.grey[700]),
            ),
            const SizedBox(height: 30),

            // Form
            _buildForm(),

            const SizedBox(height: 20),

            // Register Button
            ElevatedButton(
              onPressed: _registerUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Register", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),

            const SizedBox(height: 20),

            // Login Link
            GestureDetector(
              onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen())),
              child: Text("Already registered? Log In", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        _buildTextField(_nameController, "Full Name"),
        _buildTextField(_emailController, "Email", TextInputType.emailAddress),
        _buildTextField(_phoneController, "Phone", TextInputType.phone),
        _buildTextField(_addressController, "Address"),

        // Password Fields
        _buildPasswordField(_passwordController, "Password", _passwordVisible, () {
          setState(() {
            _passwordVisible = !_passwordVisible;
          });
        }),
        _buildPasswordField(_confirmPasswordController, "Confirm Password", _confirmPasswordVisible, () {
          setState(() {
            _confirmPasswordVisible = !_confirmPasswordVisible;
          });
        }),

        // Business Type Selection
        DropdownButtonFormField<String>(
          value: _selectedBusinessType,
          items: ["Driver", "Restaurant"].map((String type) {
            return DropdownMenuItem(value: type, child: Text(type));
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedBusinessType = value!;
            });
          },
          decoration: InputDecoration(labelText: "Business Type", border: OutlineInputBorder()),
        ),
        const SizedBox(height: 10),

        // File Upload Fields or URL Entry (Driver)
        if (_selectedBusinessType.toLowerCase() == "driver") ...[
          _buildFilePicker("Driver License", "driverLicense"),
          _buildTextField(_driverLicenseUrlController, "Driver License URL"),
          _buildFilePicker("Vehicle Registration", "vehicleRegistration"),
          _buildTextField(_vehicleRegistrationUrlController, "Vehicle Registration URL"),
        ],
        // File Upload Fields or URL Entry (Restaurant)
        if (_selectedBusinessType.toLowerCase() == "restaurant") ...[
          _buildFilePicker("Restaurant License", "restaurantLicense"),
          _buildTextField(_restaurantLicenseUrlController, "Restaurant License URL"),
          _buildFilePicker("Retail License", "retailLicense"),
          _buildTextField(_retailLicenseUrlController, "Retail License URL"),
        ],

        // Terms & Conditions Checkbox
        CheckboxListTile(
        value: _termsAccepted,
        onChanged: (value) => setState(() => _termsAccepted = value!),
    title: Text("I agree to Terms & Conditions", style: TextStyle(color: darkGray)),
    controlAffinity: ListTileControlAffinity.leading,
    activeColor: primaryColor,
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, [TextInputType keyboardType = TextInputType.text]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
        keyboardType: keyboardType,
      ),
    );
  }

  /// Enhanced Password Field with Visibility Toggle and Validation
  Widget _buildPasswordField(TextEditingController controller, String label, bool isVisible, VoidCallback toggleVisibility) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        obscureText: !isVisible,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off, color: primaryColor),
            onPressed: toggleVisibility,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return "Enter your password";
          if (!isValidPassword(value)) return "Password must contain letters, numbers, symbols & be 6+ chars";
          return null;
        },
      ),
    );
  }

  /// Password Strength Validation
  bool isValidPassword(String password) {
    return password.length >= 6 &&
        password.contains(RegExp(r'[A-Za-z]')) &&
        password.contains(RegExp(r'\d')) &&
        password.contains(RegExp(r'[@#$%^&+=!]'));
  }

  Widget _buildFilePicker(String label, String key) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        Row(
          children: [
            ElevatedButton(
              onPressed: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles();
                if (result != null) {
                  setState(() {
                    _selectedFiles[key] = File(result.files.single.path!);
                  });
                }
              },
              child: Text("Upload $label"),
            ),
            SizedBox(width: 10),
            Expanded(child: Text(_selectedFiles[key]?.path.split('/').last ?? "No file selected")),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Future<void> _registerUser() async {
    if (!_termsAccepted) {
      Fluttertoast.showToast(msg: "You must accept Terms & Conditions");
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      String uid = userCredential.user!.uid;
      String dbChild = _selectedBusinessType.toLowerCase();

      DatabaseReference userRef = _db.ref().child(dbChild).child(uid);

      Map<String, dynamic> userData = {
        "name": _nameController.text.trim(),
        "email": _emailController.text.trim(),
        "phone": _phoneController.text.trim(),
        "address": _addressController.text.trim(),
        "role": _selectedBusinessType,
        "status": "pending"
      };

      // Store URLs if provided
      if (_selectedBusinessType == "driver") {
        if (_driverLicenseUrlController.text.isNotEmpty) {
          userData["driverLicense"] = _driverLicenseUrlController.text.trim();
        }
        if (_vehicleRegistrationUrlController.text.isNotEmpty) {
          userData["vehicleRegistration"] = _vehicleRegistrationUrlController.text.trim();
        }
      }
      if (_selectedBusinessType == "restaurant") {
        if (_restaurantLicenseUrlController.text.isNotEmpty) {
          userData["restaurantLicense"] = _restaurantLicenseUrlController.text.trim();
        }
        if (_retailLicenseUrlController.text.isNotEmpty) {
          userData["retailLicense"] = _retailLicenseUrlController.text.trim();
        }
      }

      // Upload files if applicable
      for (var key in _selectedFiles.keys) {
        File? file = _selectedFiles[key];
        if (file != null) {
          String filePath = "$dbChild/$uid/$key.jpg";
          TaskSnapshot snapshot = await _storage.ref(filePath).putFile(file);
          userData[key] = await snapshot.ref.getDownloadURL();
        }
      }

      await userRef.set(userData);
      Fluttertoast.showToast(msg: "Registration Successful!");
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => RegistrationStatusScreen()));

    } catch (e) {
      Fluttertoast.showToast(msg: "Registration failed: ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
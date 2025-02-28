import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _termsAccepted = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
      backgroundColor: white,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 60),

            // Logo
            Image.asset(
              'assets/logo.png',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 16),

            // Slogan
            Text(
              "Bringing Your Cravings Home!",
              style: TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
                color: darkGray,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Signup Form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(_nameController, "Full Name", TextInputType.name),
                  _buildTextField(_emailController, "Email", TextInputType.emailAddress),
                  _buildTextField(_phoneController, "Phone", TextInputType.phone),
                  _buildTextField(_addressController, "Address", TextInputType.text),

                  // Password Field with Toggle
                  _buildPasswordField(_passwordController, "Password", _passwordVisible, () {
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  }),

                  // Confirm Password Field with Toggle
                  _buildPasswordField(_confirmPasswordController, "Confirm Password", _confirmPasswordVisible, () {
                    setState(() {
                      _confirmPasswordVisible = !_confirmPasswordVisible;
                    });
                  }),

                  // Password Hint
                  const SizedBox(height: 5),
                  Text(
                    "Password must be at least 6 characters and contain letters, numbers, and symbols (e.g., P@ssw0rd!)",
                    style: TextStyle(fontSize: 14, color: darkGray),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 10),

                  // Terms & Conditions Checkbox
                  CheckboxListTile(
                    value: _termsAccepted,
                    onChanged: (value) {
                      setState(() {
                        _termsAccepted = value!;
                      });
                    },
                    title: Text(
                      "I agree to Terms & Conditions",
                      style: TextStyle(color: darkGray),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: primaryColor,
                  ),

                  // Signup Button
                  ElevatedButton(
                    onPressed: _registerUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonDefault, // Updated button color
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "Signup",
                      style: TextStyle(color: white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Login Link
            GestureDetector(
              onTap: () => Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => LoginScreen())),
              child: Text(
                "Already registered? Log In",
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// **Reusable Text Field Builder**
  Widget _buildTextField(TextEditingController controller, String label, TextInputType keyboardType) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        validator: (value) => value!.isEmpty ? "Enter your $label" : null,
      ),
    );
  }

  /// **Reusable Password Field Builder with Visibility Toggle**
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
            icon: Icon(
              isVisible ? Icons.visibility : Icons.visibility_off,
              color: primaryColor,
            ),
            onPressed: toggleVisibility,
          ),
        ),
        validator: (value) {
          if (value!.isEmpty) return "Enter your password";
          if (label == "Password" && !isValidPassword(value)) {
            return "Password must contain letters, numbers, symbols & be 6+ chars";
          }
          return null;
        },
      ),
    );
  }

  /// **Firebase Signup & Firestore User Storage**
  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_termsAccepted) {
      Fluttertoast.showToast(msg: "You must accept Terms & Conditions");
      return;
    }

    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String phone = _phoneController.text.trim();
    String address = _addressController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (password != confirmPassword) {
      Fluttertoast.showToast(msg: "Passwords do not match!");
      return;
    }

    try {
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(email: email, password: password);

      String uid = userCredential.user!.uid;
      await _db.collection("users").doc(uid).set({
        "name": name,
        "email": email,
        "phone": phone,
        "address": address,
        "role": "customer",
        "createdAt": FieldValue.serverTimestamp(),
      });

      Fluttertoast.showToast(msg: "Signup successful!");
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => LoginScreen()));
    } catch (e) {
      Fluttertoast.showToast(msg: "Signup failed: ${e.toString()}");
    }
  }

  /// **Password Strength Validation**
  bool isValidPassword(String password) {
    return password.length >= 6 &&
        password.contains(RegExp(r'[A-Za-z]')) &&
        password.contains(RegExp(r'\d')) &&
        password.contains(RegExp(r'[@#$%^&+=!]'));
  }
}
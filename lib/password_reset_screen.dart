import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'login_screen.dart';

class PasswordResetScreen extends StatefulWidget {
  @override
  _PasswordResetScreenState createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
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
            const SizedBox(height: 50),

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
            const SizedBox(height: 100),

            // Password Reset Title
            Text(
              "Reset Your Password",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: black, // Updated color
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Password Reset Form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: "Enter Your Registered Email",
                      labelStyle: TextStyle(color: darkGray),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: primaryColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: primaryVariant),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) =>
                    value!.isEmpty ? "Enter a valid email" : null,
                  ),
                  const SizedBox(height: 10),

                  // Disclaimer
                  Text(
                    "A valid registered email address is required to reset your password.",
                    style: TextStyle(fontSize: 14, color: darkGray),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Reset Password Button
                  ElevatedButton(
                    onPressed: () => _resetPassword(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonDefault, // Updated button color
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "Reset Password",
                      style: TextStyle(color: white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Back to Login Link
            GestureDetector(
              onTap: () => Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => LoginScreen())),
              child: Text(
                "Back to Login",
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

  /// **Password Reset Functionality using Firebase**
  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    String email = _emailController.text.trim();

    try {
      await _auth.sendPasswordResetEmail(email: email);
      Fluttertoast.showToast(msg: "Password reset email sent!");
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => LoginScreen()));
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Failed to send reset email. Check your email and try again.");
    }
  }
}
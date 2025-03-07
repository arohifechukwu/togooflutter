import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'signup_screen.dart';
import 'password_reset_screen.dart';
import 'customer_home.dart';
import 'driver_home.dart';
import 'restaurant_home.dart';
import 'admin_home.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _db = FirebaseDatabase.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false; // Toggle password visibility

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // Logo
              Image.asset('assets/logo.png', width: 150, height: 150),
              const SizedBox(height: 20),
              // Slogan
              Text(
                "Bringing Your Cravings Home!",
                style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: darkGray),
              ),
              const SizedBox(height: 100),

              // Customer Login Image
              GestureDetector(
                onTap: () {}, // Placeholder for action
                child: Image.asset(
                  'assets/customer_login.png',
                  width: 200,
                  height: 50,
                ),
              ),
              const SizedBox(height: 30),

              // Login Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(color: darkGray),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: primaryVariant),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => value!.isEmpty ? "Enter your email" : null,
                    ),
                    const SizedBox(height: 16),
                    // Password Field with Visibility Toggle
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_passwordVisible,
                      decoration: InputDecoration(
                        labelText: "Password",
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(color: darkGray),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: primaryVariant),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible ? Icons.visibility : Icons.visibility_off,
                            color: darkGray,
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                      ),
                      validator: (value) => value!.isEmpty ? "Enter your password" : null,
                    ),
                    const SizedBox(height: 16),
                    // Login Button
                    ElevatedButton(
                      onPressed: () => _loginUser(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonDefault,
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text("Login", style: TextStyle(color: white, fontSize: 16)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Signup & Forgot Password Links
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SignupScreen())),
                child: Text(
                  "Haven't Registered? Signup",
                  style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PasswordResetScreen())),
                child: Text(
                  "Forgot Your Password? Reset It.",
                  style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// **Login Functionality with Firebase Auth & Realtime Database Role Validation**
  Future<void> _loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      String uid = userCredential.user!.uid;
      await _validateUserRole(uid);
    } catch (e) {
      Fluttertoast.showToast(msg: "Login failed! Check your credentials.", gravity: ToastGravity.CENTER);
    }
  }

  /// **Validate User Role from Realtime Database and Navigate to the Correct Screen**
  Future<void> _validateUserRole(String uid) async {
    // List of nodes to check
    List<String> branches = ["customer", "admin", "restaurant", "driver"];
    String? role;

    // Recursive check of nodes
    Future<void> checkRoleInBranch(int index) async {
      if (index >= branches.length) {
        Fluttertoast.showToast(msg: "User role not found!", gravity: ToastGravity.CENTER);
        return;
      }

      String branch = branches[index];
      DatabaseReference userRef = _db.ref().child(branch).child(uid);
      DataSnapshot snapshot = await userRef.get();

      if (snapshot.exists && snapshot.value != null) {
        Map data = snapshot.value as Map;
        role = data['role'];
        if (role != null) {
          _navigateToDashboard(role!);
          return;
        }
      }
      // If not found, check the next branch
      await checkRoleInBranch(index + 1);
    }

    await checkRoleInBranch(0);
  }

  /// **Navigate to the correct dashboard based on role**
  void _navigateToDashboard(String role) {
    Widget nextScreen;
    switch (role.toLowerCase()) {
      case 'customer':
        nextScreen = CustomerHome();
        break;
      case 'driver':
        nextScreen = DriverHome();
        break;
      case 'restaurant':
        nextScreen = RestaurantHome();
        break;
      case 'admin':
        nextScreen = AdminHome();
        break;
      default:
        nextScreen = CustomerHome();
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => nextScreen));
  }
}
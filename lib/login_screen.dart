import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'signup_screen.dart';
import 'password_reset_screen.dart';
import 'customer_home.dart';
import 'driver_home.dart';
import 'restaurant_home.dart';
import 'admin_home.dart';
import 'registration_status.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbReference = FirebaseDatabase.instance.ref();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;

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
            const SizedBox(height: 40),
            Image.asset('assets/logo.png', width: 150, height: 150),
            const SizedBox(height: 20),
            Text("Bringing Your Cravings Home!",
                style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: darkGray)),
            const SizedBox(height: 100),

            //Customer Login Image
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
                    onPressed: _loginUser,
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
              child: Text("Haven't Registered? Signup", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PasswordResetScreen())),
              child: Text("Forgot Your Password? Reset It.", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  /// **Reusable Text Field**
  Widget _buildTextField(TextEditingController controller, String label, TextInputType keyboardType) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      keyboardType: keyboardType,
      validator: (value) => value!.isEmpty ? "Enter your $label" : null,
    );
  }

  /// **Password Field with Visibility Toggle**
  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_passwordVisible,
      decoration: InputDecoration(
        labelText: "Password",
        border: OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            setState(() {
              _passwordVisible = !_passwordVisible;
            });
          },
        ),
      ),
      validator: (value) => value!.isEmpty ? "Enter your password" : null,
    );
  }

  /// **Login Functionality**
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

  /// **Validate User Role and Handle Status**
  Future<void> _validateUserRole(String uid) async {
    List<String> roles = ["customer", "driver", "restaurant", "admin"];
    String? userRole;

    for (String role in roles) {
      DataSnapshot snapshot = await _dbReference.child(role).child(uid).get();
      if (snapshot.exists && snapshot.value != null) {
        Map<String, dynamic> userData = Map<String, dynamic>.from(snapshot.value as Map);
        userRole = userData["role"];
        String status = userData.containsKey("status") ? userData["status"] : "approved";

        if (status == "suspended") {
          Fluttertoast.showToast(msg: "Account Suspended. Contact Administrator.", gravity: ToastGravity.CENTER);
          return;
        }

        if (status == "deleted") {
          _auth.signOut();
          Fluttertoast.showToast(msg: "Account does not exist.", gravity: ToastGravity.CENTER);
          return;
        }

        if (status == "pending") {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => RegistrationStatusScreen()));
          return;
        }

        _navigateToDashboard(userRole!);
        return;
      }
    }

    Fluttertoast.showToast(msg: "User role not found!", gravity: ToastGravity.CENTER);
  }

  /// **Navigate to Dashboard Based on Role**
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
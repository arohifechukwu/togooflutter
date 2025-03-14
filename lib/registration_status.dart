import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'driver_home.dart';
import 'login_screen.dart';
import 'restaurant_home.dart';


class RegistrationStatusScreen extends StatefulWidget {
  @override
  _RegistrationStatusScreenState createState() => _RegistrationStatusScreenState();
}

class _RegistrationStatusScreenState extends State<RegistrationStatusScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbReference = FirebaseDatabase.instance.ref();
  String _statusMessage = "Checking registration status...";

  @override
  void initState() {
    super.initState();
    _checkRegistrationStatus();
  }

  void _checkRegistrationStatus() async {
    User? user = _auth.currentUser;
    if (user == null) {
      setState(() {
        _statusMessage = "User not logged in.";
      });
      return;
    }

    String uid = user.uid;

    _dbReference.child("driver").child(uid).once().then((snapshot) {
      if (snapshot.snapshot.exists && snapshot.snapshot.child("status").value != null) {
        String status = snapshot.snapshot.child("status").value.toString();
        _handleStatus(status, "driver");
      } else {
        _dbReference.child("restaurant").child(uid).once().then((snapshot) {
          if (snapshot.snapshot.exists && snapshot.snapshot.child("status").value != null) {
            String status = snapshot.snapshot.child("status").value.toString();
            _handleStatus(status, "restaurant");
          } else {
            setState(() {
              _statusMessage = "Error: Registration not found.";
            });
          }
        });
      }
    }).catchError((error) {
      setState(() {
        _statusMessage = "Error fetching data: $error";
      });
    });
  }

  void _handleStatus(String status, String role) {
    if (status == "approved") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => role == "driver"
              ? DriverHome() // Navigate to DriverHome
              : RestaurantHome(), // Ensure this is implemented
        ),
      );
    } else {
      setState(() {
        _statusMessage = "Registration awaiting approval, please check back later.";
      });
    }
  }

  void _logout() {
    _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Registration Status")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_statusMessage, textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _logout,
              child: Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}
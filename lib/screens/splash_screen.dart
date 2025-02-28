import 'dart:async';
import 'package:flutter/material.dart';
import '../login_screen.dart'; // Import LoginScreen correctly

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()), // Navigate to LoginScreen
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              width: 250,
              height: 250,
            ),
            const SizedBox(height: 20),
            Text(
              "Bringing Your Cravings Home!",
              style: TextStyle(
                fontSize: 22,
                fontStyle: FontStyle.italic,
                color: Colors.grey[800], // Dark gray
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
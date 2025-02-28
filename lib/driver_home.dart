import 'package:flutter/material.dart';

class DriverHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Driver Home"),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text(
          "Welcome to Driver Home",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
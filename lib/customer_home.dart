import 'package:flutter/material.dart';

class CustomerHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Customer Home"),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text(
          "Welcome to Customer Home",
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
import 'package:flutter/material.dart';

class RestaurantHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Restaurant Home"),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text(
          "Welcome to Restaurant Home",
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
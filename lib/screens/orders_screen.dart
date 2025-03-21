import 'package:flutter/material.dart';

class OrdersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Orders'), backgroundColor: Colors.orange),
      body: Center(
        child: Text(
          'Welcome to orders page',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'admin_bottom_navigation_menu.dart';

class TransactionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Transaction Page"),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Text(
          "Welcome to Transaction Page",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBar: AdminBottomNavigationMenu(currentIndex: 3),
    );
  }
}
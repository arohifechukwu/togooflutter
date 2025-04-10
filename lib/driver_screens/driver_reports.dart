import 'package:flutter/material.dart';
import 'package:togoo/driver_screens/driver_bottom_navigation_menu.dart';

class DriverReportsScreen extends StatelessWidget {
  const DriverReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Reports'),
      ),
      body: Center(
        child: Text(
          'Welcome to Driver Reports Page',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBar: DriverBottomNavigationMenu(currentIndex: 2), // Adjust index based on the desired position in the navigation
    );
  }
}
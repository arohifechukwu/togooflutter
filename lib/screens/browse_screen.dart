import 'package:flutter/material.dart';

class BrowseScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Browse'), backgroundColor: Colors.orange),
      body: Center(
        child: Text(
          'Welcome to browse page',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
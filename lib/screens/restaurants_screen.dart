import 'package:flutter/material.dart';

class RestaurantsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Restaurants'), backgroundColor: Colors.orange),
      body: Center(
        child: Text(
          'Welcome to restaurants page',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class RestaurantReportScreen extends StatelessWidget {
  const RestaurantReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Restaurant Reports"),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          "Welcome to Restaurant Report Page",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

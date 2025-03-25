import 'package:flutter/material.dart';
import '../models/food_item.dart';
import '../widgets/food_adapter.dart';

class ViewAllScreen extends StatelessWidget {
  final List<FoodItem> foodItems;

  const ViewAllScreen({Key? key, required this.foodItems}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF18D34),
        title: const Text("Search Results"),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: foodItems.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: FoodAdapter(
          foodList: foodItems,
          scrollDirection: Axis.vertical,
          onFoodClick: (food) {
            Navigator.pushNamed(
              context,
              '/food-detail',
              arguments: food,
            );
          },
        ),
      ),
    );
  }
}
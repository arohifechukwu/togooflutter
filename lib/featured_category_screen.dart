import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/food_item.dart';
import '../widgets/food_adapter.dart';

class FeaturedCategoryScreen extends StatefulWidget {
  final String selectedCategory;

  const FeaturedCategoryScreen({Key? key, required this.selectedCategory}) : super(key: key);

  @override
  _FeaturedCategoryScreenState createState() => _FeaturedCategoryScreenState();
}

class _FeaturedCategoryScreenState extends State<FeaturedCategoryScreen> {
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref().child("restaurant");
  List<FoodItem> foodItemList = [];

  @override
  void initState() {
    super.initState();
    fetchCategoryItems(widget.selectedCategory);
  }

  void fetchCategoryItems(String category) async {
    final restaurantNames = getRestaurantsForCategory(category);
    final snapshot = await dbRef.get();

    List<FoodItem> fetchedItems = [];

    for (var restaurant in snapshot.children) {
      final name = restaurant.child("name").value as String?;
      if (name != null && restaurantNames.contains(name)) {
        final menuItems = restaurant.child("menu").child(category);
        for (var food in menuItems.children) {
          fetchedItems.add(FoodItem.fromRealtimeDB(food.key!, food.value as Map));
        }
      }
    }

    if (fetchedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No items found for ${widget.selectedCategory}")),
      );
      Navigator.pop(context);
    } else {
      setState(() => foodItemList = fetchedItems);
    }
  }

  List<String> getRestaurantsForCategory(String category) {
    switch (category) {
      case "Pizza":
      case "Pasta":
        return ["American Cuisine", "Italian Cuisine"];
      case "Burgers":
      case "Seafood":
      case "Salads":
        return ["American Cuisine"];
      case "Sushi":
        return ["Japanese Cuisine", "American Cuisine"];
      case "Tacos":
        return ["Mexican Cuisine"];
      case "Desserts":
        return ["Canadian Dishes"];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectedCategory),
        backgroundColor: Colors.orange,
      ),
      body: foodItemList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FoodAdapter(
            foodList: foodItemList,
            onFoodClick: (food) {
              Navigator.pushNamed(
                context,
                '/food-detail',
                arguments: food,
              );
            },
            scrollDirection: Axis.vertical,
          ),
        ],
      ),
    );
  }
}
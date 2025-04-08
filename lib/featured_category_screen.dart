import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/food_item.dart';
import '../utils/restaurant_helper.dart';
import '../widgets/food_adapter.dart';
import 'models/restaurant.dart';

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

  void fetchCategoryItems(String category) {
    foodItemList.clear();
    dbRef.once().then((DatabaseEvent event) {
      final snapshot = event.snapshot;
      for (var restaurant in snapshot.children) {
        final restaurantId = restaurant.key;
        final menuSnapshot = restaurant.child("menu").child(category);
        if (menuSnapshot.exists) {
          for (var foodSnapshot in menuSnapshot.children) {
            final id = foodSnapshot.key;
            final description = foodSnapshot.child("description").value as String?;
            final imageUrl = foodSnapshot.child("imageURL").value as String?;
            final priceValue = foodSnapshot.child("price").value;
            double? price;
            if (priceValue is double) {
              price = priceValue;
            } else if (priceValue is int) {
              price = priceValue.toDouble();
            } else if (priceValue is String) {
              price = double.tryParse(priceValue);
            }
            if (id != null && description != null && imageUrl != null && price != null) {
              FoodItem item = FoodItem(
                id: id,
                description: description,
                imageUrl: imageUrl,
                restaurantId: restaurantId,
                price: price,
              );
              foodItemList.add(item);
            }
          }
        }
      }
      if (foodItemList.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No items found for $category")),
        );
        Navigator.pop(context);
      } else {
        setState(() {}); // Refresh the UI once items are loaded.
      }
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load items")),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Featured Category"),
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: foodItemList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FoodAdapter(
            foodList: foodItemList,
            unusedRestaurant: RestaurantHelper.getCurrentRestaurant() ?? Restaurant(), // Provide fallback if needed.
            listener: (food) {
              Navigator.pushNamed(
                context,
                '/food-detail',
                arguments: food,
              );
            },
          ),
        ],
      ),
    );
  }
}
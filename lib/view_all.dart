import 'package:flutter/material.dart';
import '../models/food_item.dart';
import '../models/restaurant.dart';
import '../utils/restaurant_helper.dart';
import '../widgets/food_adapter.dart';
import 'food_detail.dart';

class ViewAllScreen extends StatelessWidget {
  final List<FoodItem> foodItems;
  final Restaurant? selectedRestaurant;

  const ViewAllScreen({
    Key? key,
    required this.foodItems,
    this.selectedRestaurant,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Set or retrieve the current restaurant context
    final Restaurant resolvedRestaurant =
        RestaurantHelper.resolveSelectedRestaurant(selectedRestaurant) ??
            Restaurant(id: "temp");

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
          ? const Center(child: Text("No results found."))
          : Padding(
        padding: const EdgeInsets.all(16),
        child: FoodAdapter(
          foodList: foodItems,
          unusedRestaurant: resolvedRestaurant,
          listener: (food) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FoodDetailScreen(
                  foodId: food.id ?? "",
                  foodDescription: food.description ?? "",
                  foodImage: food.imageUrl ?? "",
                  foodPrice: food.price,
                  restaurantId: food.restaurantId, food: food,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:togoo/models/food_item.dart';
import '../models/cart_item.dart';
import '../models/restaurant.dart';
import '../checkout_screen.dart';
import '../utils/restaurant_helper.dart';

class FoodDetailScreen extends StatelessWidget {
  final String foodId;
  final String foodDescription;
  final String foodImage;
  final double foodPrice;
  // Optional: fallback restaurantId if RestaurantHelper is not set.
  final String? restaurantId;

  const FoodDetailScreen({
    Key? key,
    required this.foodId,
    required this.foodDescription,
    required this.foodImage,
    required this.foodPrice,
    this.restaurantId, required FoodItem food,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get current user for cart operations
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Food Details"),
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Food Image (200x200)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: foodImage,
                width: 200,
                height: 200,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                const CircularProgressIndicator(),
                errorWidget: (context, url, error) =>
                const Icon(Icons.fastfood, size: 60),
              ),
            ),
            const SizedBox(height: 10),
            // Food Name (using foodId as the name)
            Text(
              foodId,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Food Description
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                foodDescription,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            // Food Price
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                "\$${foodPrice.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Add to Cart Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _addToCart(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  "Add to Cart",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Buy Now Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _buyNow(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  "Buy Now",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addToCart(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please log in to add items to the cart."),
        ),
      );
      return;
    }
    final restaurant = RestaurantHelper.getCurrentRestaurant();
    if (restaurant == null) {
      // If RestaurantHelper is not set, try to fetch via restaurantId.
      if (restaurantId != null) {
        _fetchRestaurantAndProceed(context, restaurantId!, (rest) {
          _addToCartWithRestaurant(context, rest);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Restaurant info missing")),
        );
      }
      return;
    }
    _addToCartWithRestaurant(context, restaurant);
  }

  void _addToCartWithRestaurant(BuildContext context, Restaurant restaurant) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final cartRef =
    FirebaseDatabase.instance.ref().child("cart").child(currentUser.uid);
    // We assume foodId is non-null.
    final cartItem = CartItem(
      foodId: foodId,
      foodDescription: foodDescription,
      foodImage: foodImage,
      restaurantId: restaurant.id,
      foodPrice: foodPrice,
      quantity: 1,
    );
    debugPrint(
        "AddToCart: CartItem: id=${cartItem.foodId}, desc=${cartItem.foodDescription}, image=${cartItem.foodImage}, price=${cartItem.foodPrice}, restaurantId=${cartItem.restaurantId}");
    cartRef.push().set(cartItem.toMap()).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Added to Cart!")),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to Add to Cart")),
      );
    });
  }

  void _buyNow(BuildContext context) {
    final restaurant = RestaurantHelper.getCurrentRestaurant();
    if (restaurant == null) {
      if (restaurantId != null) {
        _fetchRestaurantAndProceed(context, restaurantId!, (rest) {
          _buyNowWithRestaurant(context, rest);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Restaurant info missing")),
        );
      }
      return;
    }
    _buyNowWithRestaurant(context, restaurant);
  }

  void _buyNowWithRestaurant(BuildContext context, Restaurant restaurant) {
    if (restaurant.id?.isEmpty ?? true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Restaurant data incomplete.")),
      );
      return;
    }
    final cartItem = CartItem(
      foodId: foodId,
      foodDescription: foodDescription,
      foodImage: foodImage,
      restaurantId: restaurant.id,
      foodPrice: foodPrice,
      quantity: 1,
    );
    final checkoutList = [cartItem];
    debugPrint(
        "BuyNow: CartItem: id=${cartItem.foodId}, desc=${cartItem.foodDescription}, image=${cartItem.foodImage}, price=${cartItem.foodPrice}, restaurantId=${cartItem.restaurantId}");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(
          cartItems: checkoutList,
          selectedRestaurant: restaurant,
        ),
      ),
    );
  }

  // Note: Added BuildContext as a parameter.
  void _fetchRestaurantAndProceed(BuildContext context, String restaurantId, Function(Restaurant) callback) {
    final restaurantRef =
    FirebaseDatabase.instance.ref().child("restaurant").child(restaurantId);
    restaurantRef.get().then((snapshot) {
      final data = snapshot.value;
      if (data != null && data is Map) {
        // Pass the required 'id' parameter
        Restaurant restaurant = Restaurant.fromMap(
          Map<String, dynamic>.from(data),
          id: snapshot.key!,
        );
        RestaurantHelper.setCurrentRestaurant(restaurant);
        callback(restaurant);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Restaurant info missing")),
        );
      }
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load restaurant data")),
      );
    });
  }
}
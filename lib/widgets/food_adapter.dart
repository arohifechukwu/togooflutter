import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../models/food_item.dart';
import '../models/restaurant.dart';
import '../models/cart_item.dart';
import '../checkout_screen.dart';
import '../utils/restaurant_helper.dart';

/// Callback signature for when a food item is tapped.
typedef OnFoodClickListener = void Function(FoodItem foodItem);

class FoodAdapter extends StatefulWidget {
  final List<FoodItem> foodList;
  // The unusedRestaurant parameter is included to mirror the Java constructor.
  final Restaurant unusedRestaurant;
  final OnFoodClickListener listener;

  const FoodAdapter({
    Key? key,
    required this.foodList,
    required this.unusedRestaurant,
    required this.listener,
  }) : super(key: key);

  @override
  _FoodAdapterState createState() => _FoodAdapterState();
}

class _FoodAdapterState extends State<FoodAdapter> {
  late List<FoodItem> foodList;

  @override
  void initState() {
    super.initState();
    foodList = widget.foodList;
  }

  /// Update the food list data.
  void updateData(List<FoodItem> newData) {
    setState(() {
      foodList.clear();
      foodList.addAll(newData);
    });
  }

  /// Add the specified food item to the cart.
  void addToCart(FoodItem food) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in to add items to cart.")),
      );
      return;
    }

    if (food.restaurantId == null || food.restaurantId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid restaurant ID for this item.")),
      );
      return;
    }

    // Force unwrap food.restaurantId because we have already ensured it is non-null and non-empty.
    DatabaseReference restaurantRef = FirebaseDatabase.instance
        .ref("restaurant")
        .child(food.restaurantId!);

    restaurantRef.once().then((DatabaseEvent event) {
      final snapshot = event.snapshot;
      if (snapshot.exists) {
        // Assumes Restaurant.fromSnapshot is implemented to convert a DataSnapshot.
        Restaurant? restaurant = Restaurant.fromSnapshot(snapshot);
        if (restaurant != null) {
          RestaurantHelper.setCurrentRestaurant(restaurant);
          DatabaseReference cartRef = FirebaseDatabase.instance
              .ref("cart")
              .child(currentUser.uid);

          // Force unwrap food.id and provide fallback for description and image.
          CartItem cartItem = CartItem(
            foodId: food.id!, // Ensure food.id is non-null.
            foodDescription: food.description ?? "",
            foodImage: food.imageUrl ?? "",
            restaurantId: restaurant.id ?? "",
            foodPrice: food.price,
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
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Restaurant info missing")),
          );
        }
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

  /// Buy the specified food item now.
  void buyNow(FoodItem food) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in to buy items.")),
      );
      return;
    }

    if (food.restaurantId == null || food.restaurantId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid restaurant ID for this item.")),
      );
      return;
    }

    DatabaseReference restaurantRef = FirebaseDatabase.instance
        .ref("restaurant")
        .child(food.restaurantId!);

    restaurantRef.once().then((DatabaseEvent event) {
      final snapshot = event.snapshot;
      if (snapshot.exists) {
        Restaurant? restaurant = Restaurant.fromSnapshot(snapshot);
        if (restaurant != null) {
          if (restaurant.id == null || restaurant.id!.isEmpty) {
            restaurant.id = snapshot.key;
          }
          RestaurantHelper.setCurrentRestaurant(restaurant);
          List<CartItem> checkoutItems = [];
          CartItem cartItem = CartItem(
            foodId: food.id!, // Force unwrap because food.id is required.
            foodDescription: food.description ?? "",
            foodImage: food.imageUrl ?? "",
            restaurantId: restaurant.id ?? "",
            foodPrice: food.price,
            quantity: 1,
          );
          checkoutItems.add(cartItem);

          debugPrint(
              "BuyNow: CartItem: id=${cartItem.foodId}, desc=${cartItem.foodDescription}, image=${cartItem.foodImage}, price=${cartItem.foodPrice}, restaurantId=${cartItem.restaurantId}");

          // Navigate to the Checkout page, passing the cart items and the restaurant.
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CheckoutScreen(
                cartItems: checkoutItems,
                selectedRestaurant: restaurant,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Restaurant info missing")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Restaurant info missing")),
        );
      }
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load restaurant data: $error")),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true, // ✅ Important to avoid unbounded height
      physics: const NeverScrollableScrollPhysics(), // ✅ Prevent nested scroll conflict
      itemCount: foodList.length,
      itemBuilder: (context, index) {
        final food = foodList[index];

        debugPrint(
            "FoodAdapter: FoodItem: id=${food.id}, desc=${food.description}, image=${food.imageUrl}, price=${food.price}, restaurantId=${food.restaurantId}");

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: InkWell(
            onTap: () => widget.listener(food),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Food Image
                  SizedBox(
                    height: 100,
                    width: double.infinity,
                    child: Image.network(
                      food.imageUrl ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        'assets/ic_food_placeholder.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Food name, description, and price
                  Text(
                    food.id ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(food.description ?? ''),
                  Text("\$${food.price}"),
                  // Action buttons for adding to cart and buying now
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_cart),
                        onPressed: () => addToCart(food),
                      ),
                      IconButton(
                        icon: const Icon(Icons.payment),
                        onPressed: () => buyNow(food),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
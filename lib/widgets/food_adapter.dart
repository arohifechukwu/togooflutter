import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../admin_bottom_navigation_menu.dart';
import '../models/food_item.dart';
import '../models/cart_item.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../checkout_screen.dart';

typedef OnFoodClick = void Function(FoodItem foodItem);

class FoodAdapter extends StatelessWidget {
  final List<FoodItem> foodList;
  final OnFoodClick onFoodClick;
  final Axis scrollDirection;

  const FoodAdapter({
    Key? key,
    required this.foodList,
    required this.onFoodClick,
    this.scrollDirection = Axis.horizontal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return foodList.isEmpty
        ? const Center(child: Text("No food items available"))
        : Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: scrollDirection == Axis.horizontal
            ? SizedBox(
          height: 290,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: foodList.length,
            itemBuilder: (context, index) => _buildFoodCard(context, foodList[index]),
          ),
        )
            : ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: foodList.length,
          itemBuilder: (context, index) => _buildFoodCard(context, foodList[index]),
        ),
      ),
    );
  }

  Widget _buildFoodCard(BuildContext context, FoodItem food) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(12),
      child: InkWell(
      onTap: () => onFoodClick(food),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: scrollDirection == Axis.horizontal ? 240 : double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: food.imageUrl.isNotEmpty ? food.imageUrl : "assets/images/placeholder_food.png",
                  height: 130,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                food.id,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                food.description,
                style: const TextStyle(fontSize: 14, color: darkGray),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "\$${food.price.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () => _buyNow(context, food),
                        child: SvgPicture.asset('assets/icons/ic_buy.svg', width: 24, height: 24),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => _addToCart(context, food),
                        child: SvgPicture.asset('assets/icons/ic_add_to_cart.svg', width: 24, height: 24),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }


  void _addToCart(BuildContext context, FoodItem food) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in!")),
      );
      return;
    }

    final userId = user.uid;
    final userTypes = ['customer', 'admin', 'restaurant', 'driver'];
    final rootRef = FirebaseDatabase.instance.ref();
    String? actualUserId;

    for (String role in userTypes) {
      final roleRef = rootRef.child(role).child(userId);
      final snapshot = await roleRef.get();
      if (snapshot.exists) {
        actualUserId = userId;
        break;
      }
    }

    if (actualUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to identify user role.")),
      );
      return;
    }

    final cartRef = FirebaseDatabase.instance.ref().child("cart").child(actualUserId);

    final cartItem = {
      "foodId": food.id,
      "foodDescription": food.description,
      "foodImage": food.imageUrl,
      "foodPrice": food.price,
      "quantity": 1,
    };

    cartRef.push().set(cartItem).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${food.id} added to cart!")),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add to cart: $error")),
      );
    });
  }



  void _buyNow(BuildContext context, FoodItem food) {
    List<CartItem> checkoutItems = [
      CartItem(
        foodId: food.id,
        foodDescription: food.description,
        foodImage: food.imageUrl,
        foodPrice: food.price,
        quantity: 1,
      ),
    ];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(cartItems: checkoutItems),
      ),
    );
  }
}
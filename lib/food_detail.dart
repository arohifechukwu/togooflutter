import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/cart_item.dart';
import '../checkout_screen.dart';

class FoodDetailScreen extends StatelessWidget {
  final String foodId;
  final String foodDescription;
  final String foodImage;
  final double foodPrice;

  const FoodDetailScreen({
    Key? key,
    required this.foodId,
    required this.foodDescription,
    required this.foodImage,
    required this.foodPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final cartRef = FirebaseDatabase.instance.ref().child("cart").child(user!.uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Food Details"),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🍽️ Food Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: foodImage,
                width: 200,
                height: 200,
                fit: BoxFit.cover,
                placeholder: (context, url) => const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.fastfood, size: 60),
              ),
            ),
            const SizedBox(height: 10),

            // 📛 Food Name
            Text(
              foodId,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            // 📝 Description
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                foodDescription,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),

            // 💰 Price
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

            // ➕ Add to Cart
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final newItem = CartItem(
                    foodId: foodId,
                    foodDescription: foodDescription,
                    foodImage: foodImage,
                    foodPrice: foodPrice,
                    quantity: 1,
                  );
                  await cartRef.push().set(newItem.toMap());
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Added to Cart!")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text("Add to Cart", style: TextStyle(color: Colors.white)),
              ),
            ),

            const SizedBox(height: 10),

            // 🛒 Buy Now
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final cartItem = CartItem(
                    foodId: foodId,
                    foodDescription: foodDescription,
                    foodImage: foodImage,
                    foodPrice: foodPrice,
                    quantity: 1,
                  );
                  Navigator.pushNamed(
                    context,
                    "/checkout",
                    arguments: [cartItem],
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text("Buy Now", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
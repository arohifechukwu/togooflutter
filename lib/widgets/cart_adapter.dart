import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/cart_item.dart';

class CartAdapter extends StatelessWidget {
  final List<CartItem> cartItems;
  final DatabaseReference cartRef;

  const CartAdapter({
    Key? key,
    required this.cartItems,
    required this.cartRef,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: cartItems.length,
      itemBuilder: (context, index) {
        final item = cartItems[index];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // 🖼 Food Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: item.foodImage,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => const Icon(Icons.fastfood),
                  ),
                ),
                const SizedBox(width: 12),

                // 📝 Description and Price
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.foodDescription,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "\$${item.foodPrice.toStringAsFixed(2)}",
                        style: const TextStyle(fontSize: 15, color: Colors.red),
                      ),
                    ],
                  ),
                ),

                // 🗑 Delete Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _removeItem(context, item.cartItemId),
                  child: const Text("Delete"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _removeItem(BuildContext context, String? itemId) {
    if (itemId == null) return;

    cartRef.child(itemId).remove().then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Item removed successfully!")),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to remove item: $error")),
      );
    });
  }
}
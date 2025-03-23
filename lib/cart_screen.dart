import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/cart_item.dart';
import '../widgets/cart_adapter.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> cartItems = [];
  late DatabaseReference cartRef;

  @override
  void initState() {
    super.initState();
    determineUserCartRef();
  }

  Future<void> determineUserCartRef() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final uid = user.uid;
    final roles = ['customer', 'admin', 'restaurant', 'driver'];
    final rootRef = FirebaseDatabase.instance.ref();

    for (final role in roles) {
      final snapshot = await rootRef.child(role).child(uid).get();
      if (snapshot.exists) {
        cartRef = rootRef.child("cart").child(uid);
        listenToCartChanges();
        break;
      }
    }
  }

  void listenToCartChanges() {
    cartRef.onValue.listen((event) {
      final itemsMap = event.snapshot.value as Map<dynamic, dynamic>?;
      if (itemsMap != null) {
        final tempItems = itemsMap.entries.map((entry) {
          final itemData = Map<String, dynamic>.from(entry.value);
          return CartItem.fromMap(itemData, id: entry.key);
        }).toList();

        setState(() => cartItems = tempItems);
      } else {
        setState(() => cartItems = []);
      }
    });
  }

  void proceedToCheckout() {
    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Your cart is empty!")),
      );
      return;
    }

    Navigator.pushNamed(context, "/checkout", arguments: cartItems);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Cart"), backgroundColor: Colors.orange),
      body: cartItems.isEmpty
          ? const Center(child: Text("Your cart is empty."))
          : CartAdapter(cartItems: cartItems, cartRef: cartRef),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: proceedToCheckout,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text("Buy Now", style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ),
    );
  }
}

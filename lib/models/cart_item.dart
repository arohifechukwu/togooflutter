import 'package:flutter/foundation.dart';

class CartItem {
  String? cartItemId; // Unique key from Firebase push()
  final String foodId;
  final String foodDescription;
  final String foodImage;
  final double foodPrice;
  int quantity;


  /// Default constructor
  CartItem({
    this.cartItemId,
    required this.foodId,
    required this.foodDescription,
    required this.foodImage,
    required this.foodPrice,
    required this.quantity,
  });

  /// Factory constructor to parse from Firebase
  factory CartItem.fromMap(Map<String, dynamic> data, {String? id}) {
    return CartItem(
      cartItemId: id,
      foodId: data['foodId'] ?? '',
      foodDescription: data['foodDescription'] ?? '',
      foodImage: data['foodImage'] ?? '',
      foodPrice: (data['foodPrice'] ?? 0).toDouble(),
      quantity: data['quantity'] ?? 1,
    );
  }

  /// Converts object to a map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'foodId': foodId,
      'foodDescription': foodDescription,
      'foodImage': foodImage,
      'foodPrice': foodPrice,
      'quantity': quantity,
    };
  }

  /// Creates a copy with modified values
  CartItem copyWith({int? quantity}) {
    return CartItem(
      cartItemId: cartItemId,
      foodId: foodId,
      foodDescription: foodDescription,
      foodImage: foodImage,
      foodPrice: foodPrice,
      quantity: quantity ?? this.quantity,
    );
  }
}
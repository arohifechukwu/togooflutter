import 'package:flutter/foundation.dart';

class FoodItem {
  final String id;           // UID
  final String description;  // Description
  final String imageUrl;
  final double price;

  FoodItem({
    required this.id,
    required this.description,
    required this.imageUrl,
    required this.price,
  });

  // 🔹 Factory constructor from Realtime DB map
  factory FoodItem.fromRealtimeDB(String id, Map data) {
    return FoodItem(
      id: id,
      description: data['description'] ?? '',
      imageUrl: data['imageURL'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
    );
  }

  // 🔹 Convert object to Map (for Firebase or storage)
  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'imageURL': imageUrl,
      'price': price,
    };
  }

  // 🔹 Optional: Clone with modifications
  FoodItem copyWith({
    String? id,
    String? description,
    String? imageUrl,
    double? price,
  }) {
    return FoodItem(
      id: id ?? this.id,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
    );
  }
}
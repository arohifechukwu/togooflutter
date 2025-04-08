// import 'package:flutter/foundation.dart';
//
// class FoodItem {
//   final String id;           // UID
//   final String description;  // Description
//   final String imageUrl;
//   final double price;
//
//   FoodItem({
//     required this.id,
//     required this.description,
//     required this.imageUrl,
//     required this.price,
//   });
//
//   // 🔹 Factory constructor from Realtime DB map
//   factory FoodItem.fromRealtimeDB(String id, Map data) {
//     return FoodItem(
//       id: id,
//       description: data['description'] ?? '',
//       imageUrl: data['imageURL'] ?? '',
//       price: (data['price'] ?? 0).toDouble(),
//     );
//   }
//
//   // 🔹 Convert object to Map (for Firebase or storage)
//   Map<String, dynamic> toMap() {
//     return {
//       'description': description,
//       'imageURL': imageUrl,
//       'price': price,
//     };
//   }
//
//   // 🔹 Optional: Clone with modifications
//   FoodItem copyWith({
//     String? id,
//     String? description,
//     String? imageUrl,
//     double? price,
//   }) {
//     return FoodItem(
//       id: id ?? this.id,
//       description: description ?? this.description,
//       imageUrl: imageUrl ?? this.imageUrl,
//       price: price ?? this.price,
//     );
//   }
// }



import 'package:flutter/foundation.dart';

class FoodItem {
  String? id;
  String? description;
  String? imageUrl;
  double price;
  String? restaurantId;
  String? parentNode;
  String? category;

  FoodItem({
    this.id,
    this.description,
    this.imageUrl,
    this.price = 0.0,
    this.restaurantId,
    this.parentNode,
    this.category,
  });

  FoodItem.withDetails({
    required String id,
    required String description,
    required String imageUrl,
    required String restaurantId,
    required double price,
  }) : this(
    id: id,
    description: description,
    imageUrl: imageUrl,
    restaurantId: restaurantId,
    price: price,
  );

  /// Factory constructor from Realtime DB snapshot.
  /// NOTE: Expects three positional arguments: id, data, and restaurantId.
  factory FoodItem.fromRealtimeDB(String id, Map data, String restaurantId) {
    final description = data['description'];
    final imageUrl = data['imageURL'];
    final priceValue = data['price'];
    if (id != null && description != null && imageUrl != null && priceValue != null) {
      return FoodItem.withDetails(
        id: id,
        description: description,
        imageUrl: imageUrl,
        restaurantId: restaurantId,
        price: (priceValue).toDouble(),
      )
        ..parentNode = data['parentNode'] ?? ''
        ..category = data['category'] ?? '';
    }
    throw Exception("Invalid data snapshot for FoodItem");
  }

  // Convert object to Map (for Firebase or other storage)
  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'imageURL': imageUrl,
      'price': price,
      'restaurantId': restaurantId,
      'parentNode': parentNode,
      'category': category,
    };
  }

  // Setters

  void setRestaurantId(String restaurantId) {
    this.restaurantId = restaurantId;
  }

  void setId(String id) {
    this.id = id;
  }

  void setDescription(String description) {
    this.description = description;
  }

  void setImageUrl(String imageUrl) {
    this.imageUrl = imageUrl;
  }

  // Setter for price that handles both String and numeric inputs
  void setPrice(dynamic price) {
    if (price is String) {
      try {
        this.price = double.parse(price);
      } catch (e) {
        this.price = 0.0;
        debugPrint("Invalid price format: $price");
      }
    } else if (price is double) {
      this.price = price;
    } else if (price is int) {
      this.price = price.toDouble();
    } else {
      this.price = 0.0;
    }
  }

  void setParentNode(String parentNode) {
    this.parentNode = parentNode;
  }

  void setCategory(String category) {
    this.category = category;
  }
}
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

  /// Factory constructor from a Realtime DB snapshot.
  /// Expects [id], [data] and [restaurantId].
  /// Throws an Exception if any required field is missing.
  factory FoodItem.fromRealtimeDB(String id, Map data, String restaurantId) {
    final dynamic description = data['description'];
    final dynamic imageUrl = data['imageURL'];
    final dynamic priceValue = data['price'];

    if (description == null || imageUrl == null || priceValue == null) {
      throw Exception("Invalid data snapshot for FoodItem: Missing required field(s).");
    }

    double price;
    if (priceValue is num) {
      price = priceValue.toDouble();
    } else if (priceValue is String) {
      try {
        price = double.parse(priceValue);
      } catch (e) {
        throw Exception("Invalid data snapshot for FoodItem: Price format error.");
      }
    } else {
      throw Exception("Invalid data snapshot for FoodItem: Unrecognized price format.");
    }

    return FoodItem.withDetails(
      id: id,
      description: description.toString(),
      imageUrl: imageUrl.toString(),
      restaurantId: restaurantId,
      price: price,
    )
      ..parentNode = data['parentNode']?.toString() ?? ''
      ..category = data['category']?.toString() ?? '';
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

  /// Setter for price that handles String, int, or double.
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
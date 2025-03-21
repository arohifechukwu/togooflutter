class FoodCategory {
  final String name;
  final String imageUrl; // ✅ Now non-nullable

  FoodCategory({
    required this.name,
    required this.imageUrl,
  });

  factory FoodCategory.fromMap(Map<String, dynamic> data) {
    return FoodCategory(
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? 'assets/icons/ic_food_category_placeholder.png', // ✅ fallback image
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
    };
  }

  bool isNetworkImage() {
    return imageUrl.startsWith('http');
  }
}
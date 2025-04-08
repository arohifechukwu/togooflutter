// class FoodCategory {
//   final String name;
//   final String imageUrl; // ✅ Now non-nullable
//
//   FoodCategory({
//     required this.name,
//     required this.imageUrl,
//   });
//
//   factory FoodCategory.fromMap(Map<String, dynamic> data) {
//     return FoodCategory(
//       name: data['name'] ?? '',
//       imageUrl: data['imageUrl'] ?? 'assets/icons/ic_food_category_placeholder.png', // ✅ fallback image
//     );
//   }
//
//   Map<String, dynamic> toMap() {
//     return {
//       'name': name,
//       'imageUrl': imageUrl,
//     };
//   }
//
//   bool isNetworkImage() {
//     return imageUrl.startsWith('http');
//   }
// }


class FoodCategory {
  String? name;
  int imageResId;
  String? imageUrl;

  // Default constructor (required for Firebase)
  FoodCategory() : imageResId = 0;

  // Constructor for Drawable Resources
  FoodCategory.fromDrawable(String name, int imageResId)
      : name = name,
        imageResId = imageResId,
        imageUrl = null;

  // Constructor for URL Images (if needed)
  FoodCategory.fromUrl(String name, String imageUrl)
      : name = name,
        imageResId = 0,
        imageUrl = imageUrl;

  // Getters
  String? get getName => name;
  int get getImageResId => imageResId;
  String? get getImageUrl => imageUrl;

  // Convenience method to check if an image URL exists
  bool hasImageUrl() {
    return imageUrl != null && imageUrl!.isNotEmpty;
  }
}
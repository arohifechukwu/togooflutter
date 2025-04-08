// class FoodCategory {
//   final String name;
//   final int? imageResId; // Stores asset image reference (Drawable in Android)
//   final String? imageUrl; // Stores URL for online images
//
//   // Default constructor for Firebase
//   FoodCategory({required this.name, this.imageResId, this.imageUrl});
//
//   // Constructor for drawable resources (local assets)
//   FoodCategory.fromAsset(this.name, this.imageResId) : imageUrl = null;
//
//   // Constructor for URL images (online resources)
//   FoodCategory.fromUrl(this.name, this.imageUrl) : imageResId = null;
//
//   // Check if the category has an image URL
//   bool hasImageUrl() {
//     return imageUrl != null && imageUrl!.isNotEmpty;
//   }
// }
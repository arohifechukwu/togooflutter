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
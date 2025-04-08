// import 'package:flutter/material.dart';
// import '../models/food_category.dart';
//
// typedef OnCategoryClick = void Function(FoodCategory category);
//
// class FoodCategoryAdapter extends StatelessWidget {
//   final List<FoodCategory> categories;
//   final OnCategoryClick onCategoryClick;
//
//   const FoodCategoryAdapter({
//     Key? key,
//     required this.categories,
//     required this.onCategoryClick,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 120, // height of each category item block
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: categories.length,
//         itemBuilder: (context, index) {
//           final category = categories[index];
//
//           return GestureDetector(
//             onTap: () => onCategoryClick(category),
//             child: Container(
//               width: 100,
//               margin: const EdgeInsets.symmetric(horizontal: 8),
//               child: Column(
//                 children: [
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(10),
//                     child: Image.asset(
//                       category.imageUrl, // default fallback image
//                       width: 80,
//                       height: 80,
//                       fit: BoxFit.cover,
//                       errorBuilder: (context, error, stackTrace) => const Icon(
//                         Icons.broken_image,
//                         size: 80,
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 5),
//                   Text(
//                     category.name,
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import '../models/food_category.dart';

/// Callback when a category is clicked.
typedef OnCategoryClick = void Function(FoodCategory category);

class FoodCategoryAdapter extends StatelessWidget {
  final List<FoodCategory> categories;
  final OnCategoryClick onCategoryClick;

  const FoodCategoryAdapter({
    Key? key,
    required this.categories,
    required this.onCategoryClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // The height here approximates the size of each category item block.
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return GestureDetector(
            onTap: () => onCategoryClick(category),
            child: Container(
              width: 100,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Display category image:
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: category.hasImageUrl()
                        ? Image.network(
                      category.getImageUrl!,
                      width: 46,
                      height: 46,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Image.asset(
                            'assets/ic_food_category_placeholder.png',
                            width: 46,
                            height: 46,
                            fit: BoxFit.cover,
                          ),
                    )
                        : Image.asset(
                      // When no URL exists, load the local drawable.
                      // In a full implementation, you might map imageResId to a specific asset.
                      'assets/ic_food_category_placeholder.png',
                      width: 46,
                      height: 46,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Display category name:
                  Text(
                    category.getName ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
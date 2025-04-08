// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import '../models/food_item.dart';
// import '../models/cart_item.dart';
// import '../checkout_screen.dart';
// import '../food_detail.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
//
// typedef OnFoodClick = void Function(FoodItem foodItem);
//
// class FoodAdapter extends StatelessWidget {
//   final List<FoodItem> foodList;
//   final OnFoodClick onFoodClick;
//   final Axis scrollDirection;
//   final bool isSearchSuggestion;
//
//   const FoodAdapter({
//     Key? key,
//     required this.foodList,
//     required this.onFoodClick,
//     this.scrollDirection = Axis.horizontal,
//     this.isSearchSuggestion = false,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     if (isSearchSuggestion) {
//       // For search suggestions, use a vertical list with the custom layout.
//       return ListView.builder(
//         shrinkWrap: true,
//         physics: NeverScrollableScrollPhysics(),
//         itemCount: foodList.length,
//         itemBuilder: (context, index) => _buildSearchSuggestionItem(context, foodList[index]),
//       );
//     } else {
//       // Regular Food Adapter layout
//       return foodList.isEmpty
//           ? Center(child: Text("No food items available"))
//           : Material(
//         elevation: 6,
//         borderRadius: BorderRadius.circular(16),
//         child: Container(
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: scrollDirection == Axis.horizontal
//               ? SizedBox(
//             height: 290,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: foodList.length,
//               itemBuilder: (context, index) => _buildFoodCard(context, foodList[index]),
//             ),
//           )
//               : ListView.builder(
//             shrinkWrap: true,
//             physics: NeverScrollableScrollPhysics(),
//             itemCount: foodList.length,
//             itemBuilder: (context, index) => _buildFoodCard(context, foodList[index]),
//           ),
//         ),
//       );
//     }
//   }
//
//   Widget _buildFoodCard(BuildContext context, FoodItem food) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
//       child: Material(
//         elevation: 4,
//         borderRadius: BorderRadius.circular(12),
//         child: InkWell(
//           onTap: () => onFoodClick(food),
//           borderRadius: BorderRadius.circular(12),
//           child: Container(
//             width: scrollDirection == Axis.horizontal ? 240 : double.infinity,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(12),
//               color: Colors.white,
//             ),
//             padding: const EdgeInsets.all(10),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(10),
//                   child: CachedNetworkImage(
//                     imageUrl: food.imageUrl.isNotEmpty ? food.imageUrl : "assets/images/placeholder_food.png",
//                     height: 130,
//                     width: double.infinity,
//                     fit: BoxFit.cover,
//                     placeholder: (context, url) => CircularProgressIndicator(),
//                     errorWidget: (context, url, error) => Icon(Icons.error),
//                   ),
//                 ),
//                 SizedBox(height: 10),
//                 Text(
//                   food.id,
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//                 Text(
//                   food.description,
//                   style: TextStyle(fontSize: 14, color: Colors.grey[700]),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 SizedBox(height: 8),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       "\$${food.price.toStringAsFixed(2)}",
//                       style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
//                     ),
//                     Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         GestureDetector(
//                           onTap: () => _buyNow(context, food),
//                           child: SvgPicture.asset('assets/icons/ic_buy.svg', width: 24, height: 24),
//                         ),
//                         SizedBox(width: 12),
//                         GestureDetector(
//                           onTap: () => _addToCart(context, food),
//                           child: SvgPicture.asset('assets/icons/ic_add_to_cart.svg', width: 24, height: 24),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // Search suggestion item layout using "item_search_suggestion" style
//   Widget _buildSearchSuggestionItem(BuildContext context, FoodItem food) {
//     return GestureDetector(
//       onTap: () => onFoodClick(food),
//       child: Container(
//         padding: EdgeInsets.all(8),
//         margin: EdgeInsets.symmetric(vertical: 4),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           border: Border.all(color: Colors.grey.shade300),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Row(
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.circular(8),
//               child: CachedNetworkImage(
//                 imageUrl: food.imageUrl.isNotEmpty ? food.imageUrl : "assets/images/placeholder_food.png",
//                 width: 60,
//                 height: 60,
//                 fit: BoxFit.cover,
//                 placeholder: (context, url) => CircularProgressIndicator(),
//                 errorWidget: (context, url, error) => Icon(Icons.error),
//               ),
//             ),
//             SizedBox(width: 10),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     food.id,
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                   Text(
//                     food.description,
//                     style: TextStyle(fontSize: 14, color: Colors.grey[700]),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _addToCart(BuildContext context, FoodItem food) async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User not logged in!")));
//       return;
//     }
//
//     final userId = user.uid;
//     final userTypes = ['customer', 'admin', 'restaurant', 'driver'];
//     final rootRef = FirebaseDatabase.instance.ref();
//     String? actualUserId;
//
//     for (String role in userTypes) {
//       final roleRef = rootRef.child(role).child(userId);
//       final snapshot = await roleRef.get();
//       if (snapshot.exists) {
//         actualUserId = userId;
//         break;
//       }
//     }
//
//     if (actualUserId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Unable to identify user role.")));
//       return;
//     }
//
//     final cartRef = FirebaseDatabase.instance.ref().child("cart").child(actualUserId);
//     final cartItem = {
//       "foodId": food.id,
//       "foodDescription": food.description,
//       "foodImage": food.imageUrl,
//       "foodPrice": food.price,
//       "quantity": 1,
//     };
//
//     cartRef.push().set(cartItem).then((_) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${food.id} added to cart!")));
//     }).catchError((error) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to add to cart: $error")));
//     });
//   }
//
//
//   void _buyNow(BuildContext context, FoodItem food) {
//     List<CartItem> checkoutItems = [
//       CartItem(
//         foodId: food.id,
//         foodDescription: food.description,
//         foodImage: food.imageUrl,
//         foodPrice: food.price,
//         quantity: 1,
//       ),
//     ];
//
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => CheckoutScreen(cartItems: checkoutItems),
//       ),
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
//
// import '../models/food_item.dart';
// import '../models/restaurant.dart';
// import '../models/cart_item.dart';
// import '../checkout_screen.dart';
// import '../utils/restaurant_helper.dart';
//
// /// Callback signature for when a food item is tapped.
// typedef OnFoodClickListener = void Function(FoodItem foodItem);
//
// class FoodAdapter extends StatefulWidget {
//   final List<FoodItem> foodList;
//   // The unusedRestaurant parameter is included to mirror the Java constructor.
//   final Restaurant unusedRestaurant;
//   final OnFoodClickListener listener;
//
//   const FoodAdapter({
//     Key? key,
//     required this.foodList,
//     required this.unusedRestaurant,
//     required this.listener,
//   }) : super(key: key);
//
//   @override
//   _FoodAdapterState createState() => _FoodAdapterState();
// }
//
// class _FoodAdapterState extends State<FoodAdapter> {
//   late List<FoodItem> foodList;
//
//   @override
//   void initState() {
//     super.initState();
//     foodList = widget.foodList;
//   }
//
//   /// Update the food list data.
//   void updateData(List<FoodItem> newData) {
//     setState(() {
//       foodList.clear();
//       foodList.addAll(newData);
//     });
//   }
//
//   /// Add the specified food item to the cart.
//   void addToCart(FoodItem food) {
//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please log in to add items to cart.")),
//       );
//       return;
//     }
//
//     if (food.restaurantId == null || food.restaurantId!.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("invalid restaurant ID for this item.")),
//       );
//       return;
//     }
//
//     DatabaseReference restaurantRef = FirebaseDatabase.instance
//         .ref("restaurant")
//         .child(food.restaurantId!);
//
//     restaurantRef.once().then((DatabaseEvent event) {
//       final snapshot = event.snapshot;
//       if (snapshot.exists) {
//         // Assumes Restaurant.fromSnapshot is implemented to convert a DataSnapshot.
//         Restaurant? restaurant = Restaurant.fromSnapshot(snapshot);
//         if (restaurant != null) {
//           RestaurantHelper.setCurrentRestaurant(restaurant);
//           DatabaseReference cartRef = FirebaseDatabase.instance
//               .ref("cart")
//               .child(currentUser.uid);
//
//           CartItem cartItem = CartItem(
//             foodId: food.id,
//             foodDescription: food.description,
//             foodImage: food.imageUrl,
//             restaurantId: restaurant.id,
//             foodPrice: food.price,
//             quantity: 1,
//           );
//
//           debugPrint(
//               "AddToCart: CartItem: id=${cartItem.foodId}, desc=${cartItem.foodDescription}, image=${cartItem.foodImage}, price=${cartItem.foodPrice}, restaurantId=${cartItem.restaurantId}");
//
//           cartRef.push().set(cartItem.toMap()).then((_) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text("Added to Cart!")),
//             );
//           }).catchError((error) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text("Failed to Add to Cart")),
//             );
//           });
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("Restaurant info missing")),
//           );
//         }
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Restaurant info missing")),
//         );
//       }
//     }).catchError((error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Failed to load restaurant data")),
//       );
//     });
//   }
//
//   /// Buy the specified food item now.
//   void buyNow(FoodItem food) {
//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please log in to buy items.")),
//       );
//       return;
//     }
//
//     if (food.restaurantId == null || food.restaurantId!.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Invalid restaurant ID for this item.")),
//       );
//       return;
//     }
//
//     DatabaseReference restaurantRef = FirebaseDatabase.instance
//         .ref("restaurant")
//         .child(food.restaurantId!);
//
//     restaurantRef.once().then((DatabaseEvent event) {
//       final snapshot = event.snapshot;
//       if (snapshot.exists) {
//         Restaurant? restaurant = Restaurant.fromSnapshot(snapshot);
//         if (restaurant != null) {
//           if (restaurant.id == null || restaurant.id!.isEmpty) {
//             restaurant.id = snapshot.key;
//           }
//           RestaurantHelper.setCurrentRestaurant(restaurant);
//           List<CartItem> checkoutItems = [];
//           CartItem cartItem = CartItem(
//             foodId: food.id,
//             foodDescription: food.description,
//             foodImage: food.imageUrl,
//             restaurantId: restaurant.id,
//             foodPrice: food.price,
//             quantity: 1,
//           );
//           checkoutItems.add(cartItem);
//
//           debugPrint(
//               "BuyNow: CartItem: id=${cartItem.foodId}, desc=${cartItem.foodDescription}, image=${cartItem.foodImage}, price=${cartItem.foodPrice}, restaurantId=${cartItem.restaurantId}");
//
//           // Navigate to the Checkout page, passing the cart items and the restaurant.
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => CheckoutScreen(
//                 cartItems: checkoutItems,
//                 selectedRestaurant: restaurant,
//               ),
//             ),
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("Restaurant info missing")),
//           );
//         }
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Restaurant info missing")),
//         );
//       }
//     }).catchError((error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Failed to load restaurant data: $error")),
//       );
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       itemCount: foodList.length,
//       itemBuilder: (context, index) {
//         final food = foodList[index];
//
//         debugPrint(
//             "FoodAdapter: FoodItem: id=${food.id}, desc=${food.description}, image=${food.imageUrl}, price=${food.price}, restaurantId=${food.restaurantId}");
//
//         return Card(
//           margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//           child: InkWell(
//             onTap: () => widget.listener(food),
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Food Image
//                   SizedBox(
//                     height: 100,
//                     width: double.infinity,
//                     child: Image.network(
//                       food.imageUrl ?? '',
//                       fit: BoxFit.cover,
//                       errorBuilder: (context, error, stackTrace) => Image.asset(
//                         'assets/ic_food_placeholder.png',
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   // Food name, description, and price
//                   Text(
//                     food.id ?? '',
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   Text(food.description ?? ''),
//                   Text("\$${food.price}"),
//                   // Action buttons for adding to cart and buying now
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.shopping_cart),
//                         onPressed: () => addToCart(food),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.payment),
//                         onPressed: () => buyNow(food),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../models/food_item.dart';
import '../models/restaurant.dart';
import '../models/cart_item.dart';
import '../checkout_screen.dart';
import '../utils/restaurant_helper.dart';

/// Callback signature for when a food item is tapped.
typedef OnFoodClickListener = void Function(FoodItem foodItem);

class FoodAdapter extends StatefulWidget {
  final List<FoodItem> foodList;
  // The unusedRestaurant parameter is included to mirror the Java constructor.
  final Restaurant unusedRestaurant;
  final OnFoodClickListener listener;

  const FoodAdapter({
    Key? key,
    required this.foodList,
    required this.unusedRestaurant,
    required this.listener,
  }) : super(key: key);

  @override
  _FoodAdapterState createState() => _FoodAdapterState();
}

class _FoodAdapterState extends State<FoodAdapter> {
  late List<FoodItem> foodList;

  @override
  void initState() {
    super.initState();
    foodList = widget.foodList;
  }

  /// Update the food list data.
  void updateData(List<FoodItem> newData) {
    setState(() {
      foodList.clear();
      foodList.addAll(newData);
    });
  }

  /// Add the specified food item to the cart.
  void addToCart(FoodItem food) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in to add items to cart.")),
      );
      return;
    }

    if (food.restaurantId == null || food.restaurantId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid restaurant ID for this item.")),
      );
      return;
    }

    // Force unwrap food.restaurantId because we have already ensured it is non-null and non-empty.
    DatabaseReference restaurantRef = FirebaseDatabase.instance
        .ref("restaurant")
        .child(food.restaurantId!);

    restaurantRef.once().then((DatabaseEvent event) {
      final snapshot = event.snapshot;
      if (snapshot.exists) {
        // Assumes Restaurant.fromSnapshot is implemented to convert a DataSnapshot.
        Restaurant? restaurant = Restaurant.fromSnapshot(snapshot);
        if (restaurant != null) {
          RestaurantHelper.setCurrentRestaurant(restaurant);
          DatabaseReference cartRef = FirebaseDatabase.instance
              .ref("cart")
              .child(currentUser.uid);

          // Force unwrap food.id and provide fallback for description and image.
          CartItem cartItem = CartItem(
            foodId: food.id!, // Ensure food.id is non-null.
            foodDescription: food.description ?? "",
            foodImage: food.imageUrl ?? "",
            restaurantId: restaurant.id ?? "",
            foodPrice: food.price,
            quantity: 1,
          );

          debugPrint(
              "AddToCart: CartItem: id=${cartItem.foodId}, desc=${cartItem.foodDescription}, image=${cartItem.foodImage}, price=${cartItem.foodPrice}, restaurantId=${cartItem.restaurantId}");

          cartRef.push().set(cartItem.toMap()).then((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Added to Cart!")),
            );
          }).catchError((error) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Failed to Add to Cart")),
            );
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Restaurant info missing")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Restaurant info missing")),
        );
      }
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load restaurant data")),
      );
    });
  }

  /// Buy the specified food item now.
  void buyNow(FoodItem food) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in to buy items.")),
      );
      return;
    }

    if (food.restaurantId == null || food.restaurantId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid restaurant ID for this item.")),
      );
      return;
    }

    DatabaseReference restaurantRef = FirebaseDatabase.instance
        .ref("restaurant")
        .child(food.restaurantId!);

    restaurantRef.once().then((DatabaseEvent event) {
      final snapshot = event.snapshot;
      if (snapshot.exists) {
        Restaurant? restaurant = Restaurant.fromSnapshot(snapshot);
        if (restaurant != null) {
          if (restaurant.id == null || restaurant.id!.isEmpty) {
            restaurant.id = snapshot.key;
          }
          RestaurantHelper.setCurrentRestaurant(restaurant);
          List<CartItem> checkoutItems = [];
          CartItem cartItem = CartItem(
            foodId: food.id!, // Force unwrap because food.id is required.
            foodDescription: food.description ?? "",
            foodImage: food.imageUrl ?? "",
            restaurantId: restaurant.id ?? "",
            foodPrice: food.price,
            quantity: 1,
          );
          checkoutItems.add(cartItem);

          debugPrint(
              "BuyNow: CartItem: id=${cartItem.foodId}, desc=${cartItem.foodDescription}, image=${cartItem.foodImage}, price=${cartItem.foodPrice}, restaurantId=${cartItem.restaurantId}");

          // Navigate to the Checkout page, passing the cart items and the restaurant.
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CheckoutScreen(
                cartItems: checkoutItems,
                selectedRestaurant: restaurant,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Restaurant info missing")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Restaurant info missing")),
        );
      }
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load restaurant data: $error")),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true, // ✅ Important to avoid unbounded height
      physics: const NeverScrollableScrollPhysics(), // ✅ Prevent nested scroll conflict
      itemCount: foodList.length,
      itemBuilder: (context, index) {
        final food = foodList[index];

        debugPrint(
            "FoodAdapter: FoodItem: id=${food.id}, desc=${food.description}, image=${food.imageUrl}, price=${food.price}, restaurantId=${food.restaurantId}");

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: InkWell(
            onTap: () => widget.listener(food),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Food Image
                  SizedBox(
                    height: 100,
                    width: double.infinity,
                    child: Image.network(
                      food.imageUrl ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        'assets/ic_food_placeholder.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Food name, description, and price
                  Text(
                    food.id ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(food.description ?? ''),
                  Text("\$${food.price}"),
                  // Action buttons for adding to cart and buying now
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_cart),
                        onPressed: () => addToCart(food),
                      ),
                      IconButton(
                        icon: const Icon(Icons.payment),
                        onPressed: () => buyNow(food),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
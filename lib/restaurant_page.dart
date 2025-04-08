// import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../models/restaurant.dart';
// import '../models/food_item.dart';
// import '../widgets/food_adapter.dart';
// import '../widgets/restaurant_tile.dart';
// import '../utils/restaurant_helper.dart';
//
// class RestaurantPageScreen extends StatefulWidget {
//   final String restaurantId;
//
//   const RestaurantPageScreen({Key? key, required this.restaurantId}) : super(key: key);
//
//   @override
//   _RestaurantPageScreenState createState() => _RestaurantPageScreenState();
// }
//
// class _RestaurantPageScreenState extends State<RestaurantPageScreen> {
//   late DatabaseReference restaurantRef;
//   late DatabaseReference usersRef;
//
//   Restaurant? currentRestaurant;
//   double userLatitude = 0;
//   double userLongitude = 0;
//   List<FoodItem> featuredItems = [];
//   Map<String, List<FoodItem>> menuSections = {};
//   List<Restaurant> moreToExplore = [];
//
//   @override
//   void initState() {
//     super.initState();
//     restaurantRef = FirebaseDatabase.instance.ref("restaurant").child(widget.restaurantId);
//     usersRef = FirebaseDatabase.instance.ref();
//     _fetchRestaurantDetails();
//     _fetchUserLocation();
//     _fetchFeaturedItems();
//     _fetchMenuSections();
//   }
//
//   void _fetchRestaurantDetails() {
//     restaurantRef.once().then((snapshot) {
//       final data = snapshot.snapshot.value as Map<dynamic, dynamic>?;
//       if (data != null) {
//         final location = data['location'] as Map<dynamic, dynamic>?;
//         final restaurant = Restaurant(
//           id: widget.restaurantId,
//           name: data['name'] ?? 'Unnamed',
//           address: data['address'] ?? 'Unknown',
//           imageURL: data['imageURL'] ?? '',
//           location: location != null
//               ? LocationCoordinates(
//             latitude: double.tryParse(location['latitude'].toString()) ?? 0.0,
//             longitude: double.tryParse(location['longitude'].toString()) ?? 0.0,
//           )
//               : LocationCoordinates(latitude: 0, longitude: 0),
//           rating: double.tryParse(data['rating']?.toString() ?? '') ?? 4.5,
//         );
//
//         RestaurantHelper.setCurrentRestaurant(restaurant);
//         setState(() {
//           currentRestaurant = restaurant;
//         });
//         _fetchMoreToExplore();
//       }
//     });
//   }
//
//   void _fetchUserLocation() {
//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser == null) return;
//     FirebaseDatabase.instance
//         .ref("customer/${currentUser.uid}/location")
//         .once()
//         .then((snapshot) {
//       final data = snapshot.snapshot.value as Map<dynamic, dynamic>?;
//       if (data != null) {
//         setState(() {
//           userLatitude = double.tryParse(data['latitude'].toString()) ?? 0;
//           userLongitude = double.tryParse(data['longitude'].toString()) ?? 0;
//         });
//       }
//     });
//   }
//
//   void _fetchFeaturedItems() {
//     restaurantRef.child("Special Offers").once().then((snapshot) {
//       final items = <FoodItem>[];
//       final data = snapshot.snapshot.value as Map<dynamic, dynamic>?;
//       data?.forEach((key, value) {
//         final item = FoodItem.fromMap(Map<String, dynamic>.from(value));
//         items.add(item);
//       });
//       setState(() => featuredItems = items);
//     });
//   }
//
//   void _fetchMenuSections() {
//     restaurantRef.child("menu").once().then((snapshot) {
//       final sections = <String, List<FoodItem>>{};
//       final data = snapshot.snapshot.value as Map<dynamic, dynamic>?;
//       data?.forEach((category, itemList) {
//         final items = <FoodItem>[];
//         if (itemList is Map) {
//           itemList.forEach((key, value) {
//             items.add(FoodItem.fromMap(Map<String, dynamic>.from(value)));
//           });
//         }
//         sections[category.toString()] = items;
//       });
//       setState(() => menuSections = sections);
//     });
//   }
//
//   void _fetchMoreToExplore() {
//     FirebaseDatabase.instance.ref("restaurant").once().then((snapshot) {
//       final restaurants = <Restaurant>[];
//       final data = snapshot.snapshot.value as Map<dynamic, dynamic>?;
//
//       data?.forEach((key, value) {
//         if (key != widget.restaurantId) {
//           final restData = Map<String, dynamic>.from(value);
//           final coords = Map<String, dynamic>.from(restData['location'] ?? {});
//           final r = Restaurant(
//             id: key,
//             name: restData['name'] ?? 'Unnamed',
//             address: restData['address'] ?? 'Unknown',
//             imageURL: restData['imageURL'] ?? '',
//             location: LocationCoordinates(
//               latitude: double.tryParse(coords['latitude'].toString()) ?? 0,
//               longitude: double.tryParse(coords['longitude'].toString()) ?? 0,
//             ),
//             rating: double.tryParse(restData['rating']?.toString() ?? '') ?? 4.5,
//           );
//           restaurants.add(r);
//         }
//       });
//
//       setState(() => moreToExplore = restaurants.take(7).toList());
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(currentRestaurant?.name ?? "Restaurant"),
//         backgroundColor: Colors.deepOrange,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: currentRestaurant == null
//           ? Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Image.network(
//               currentRestaurant!.imageURL,
//               height: 200,
//               width: double.infinity,
//               fit: BoxFit.cover,
//               errorBuilder: (_, __, ___) => Container(
//                 height: 200,
//                 color: Colors.grey[200],
//                 child: Icon(Icons.image_not_supported),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(currentRestaurant!.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
//                   SizedBox(height: 4),
//                   Text("⭐ ${currentRestaurant!.rating.toStringAsFixed(1)}"),
//                   SizedBox(height: 4),
//                   Text(currentRestaurant!.address),
//                 ],
//               ),
//             ),
//             if (featuredItems.isNotEmpty)
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     child: Text("Featured Items", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                   ),
//                   FoodAdapter(foodList: featuredItems),
//                 ],
//               ),
//             for (var entry in menuSections.entries)
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                     child: Text(entry.key, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                   ),
//                   FoodAdapter(foodList: entry.value),
//                 ],
//               ),
//             if (moreToExplore.isNotEmpty)
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                     child: Text("More to Explore", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                   ),
//                   SizedBox(
//                     height: 280,
//                     child: ListView.builder(
//                       scrollDirection: Axis.horizontal,
//                       itemCount: moreToExplore.length,
//                       itemBuilder: (context, index) => RestaurantTile(restaurant: moreToExplore[index]),
//                     ),
//                   )
//                 ],
//               )
//           ],
//         ),
//       ),
//     );
//   }
// }





// import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../models/restaurant.dart';
// import '../models/food_item.dart';
// import '../widgets/food_adapter.dart';
// import '../widgets/restaurant_tile.dart';
// import '../utils/restaurant_helper.dart';
// import '../models/location_coordinates.dart';
//
// class RestaurantPageScreen extends StatefulWidget {
//   final String restaurantId;
//
//   const RestaurantPageScreen({Key? key, required this.restaurantId}) : super(key: key);
//
//   @override
//   _RestaurantPageScreenState createState() => _RestaurantPageScreenState();
// }
//
// class _RestaurantPageScreenState extends State<RestaurantPageScreen> {
//   late DatabaseReference restaurantRef;
//   late DatabaseReference usersRef;
//
//   Restaurant? currentRestaurant;
//   double userLatitude = 0;
//   double userLongitude = 0;
//   List<FoodItem> featuredItems = [];
//   Map<String, List<FoodItem>> menuSections = {};
//   List<Restaurant> moreToExplore = [];
//
//   @override
//   void initState() {
//     super.initState();
//     restaurantRef = FirebaseDatabase.instance.ref("restaurant").child(widget.restaurantId);
//     usersRef = FirebaseDatabase.instance.ref();
//     _fetchRestaurantDetails();
//     _fetchUserLocation();
//     _fetchFeaturedItems();
//     _fetchMenuSections();
//   }
//
//   void _fetchRestaurantDetails() {
//     restaurantRef.once().then((snapshot) {
//       final data = snapshot.snapshot.value as Map<dynamic, dynamic>?;
//       if (data != null) {
//         final location = data['location'] as Map<dynamic, dynamic>?;
//         final restaurant = Restaurant(
//           id: widget.restaurantId,
//           name: data['name'] ?? 'Unnamed',
//           address: data['address'] ?? 'Unknown',
//           imageUrl: data['imageURL'] ?? '',
//           location: LocationCoordinates.withCoordinates(
//             double.tryParse(location?['latitude']?.toString() ?? '0.0') ?? 0.0,
//             double.tryParse(location?['longitude']?.toString() ?? '0.0') ?? 0.0,
//           ),
//           rating: double.tryParse(data['rating']?.toString() ?? '') ?? 4.5,
//         );
//
//         RestaurantHelper.setCurrentRestaurant(restaurant);
//         setState(() {
//           currentRestaurant = restaurant;
//         });
//         _fetchMoreToExplore();
//       }
//     });
//   }
//
//   void _fetchUserLocation() {
//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser == null) return;
//     FirebaseDatabase.instance
//         .ref("customer/${currentUser.uid}/location")
//         .once()
//         .then((snapshot) {
//       final data = snapshot.snapshot.value as Map<dynamic, dynamic>?;
//       if (data != null) {
//         setState(() {
//           userLatitude = double.tryParse(data['latitude'].toString()) ?? 0;
//           userLongitude = double.tryParse(data['longitude'].toString()) ?? 0;
//         });
//       }
//     });
//   }
//
//   void _fetchFeaturedItems() {
//     restaurantRef.child("Special Offers").once().then((snapshot) {
//       final items = <FoodItem>[];
//       final data = snapshot.snapshot.value as Map<dynamic, dynamic>?;
//       data?.forEach((key, value) {
//         final item = FoodItem.fromRealtimeDB(
//             key, Map<String, dynamic>.from(value), widget.restaurantId);
//         items.add(item);
//       });
//       setState(() => featuredItems = items);
//     });
//   }
//
//   void _fetchMenuSections() {
//     restaurantRef.child("menu").once().then((snapshot) {
//       final sections = <String, List<FoodItem>>{};
//       final data = snapshot.snapshot.value as Map<dynamic, dynamic>?;
//       data?.forEach((category, itemList) {
//         final items = <FoodItem>[];
//         if (itemList is Map) {
//           itemList.forEach((key, value) {
//             items.add(FoodItem.fromRealtimeDB(
//                 key, Map<String, dynamic>.from(value), widget.restaurantId));
//           });
//         }
//         sections[category.toString()] = items;
//       });
//       setState(() => menuSections = sections);
//     });
//   }
//
//   void _fetchMoreToExplore() {
//     FirebaseDatabase.instance.ref("restaurant").once().then((snapshot) {
//       final restaurants = <Restaurant>[];
//       final data = snapshot.snapshot.value as Map<dynamic, dynamic>?;
//
//       data?.forEach((key, value) {
//         if (key != widget.restaurantId) {
//           final restData = Map<String, dynamic>.from(value);
//           final coords = Map<String, dynamic>.from(restData['location'] ?? {});
//           final r = Restaurant(
//             id: key,
//             name: restData['name'] ?? 'Unnamed',
//             address: restData['address'] ?? 'Unknown',
//             imageUrl: restData['imageURL'] ?? '',
//             location: LocationCoordinates.withCoordinates(
//               double.tryParse(coords['latitude'].toString()) ?? 0,
//               double.tryParse(coords['longitude'].toString()) ?? 0,
//             ),
//             rating: double.tryParse(restData['rating']?.toString() ?? '') ?? 4.5,
//           );
//           restaurants.add(r);
//         }
//       });
//
//       setState(() => moreToExplore = restaurants.take(7).toList());
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(currentRestaurant?.name ?? "Restaurant"),
//         backgroundColor: Colors.deepOrange,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: currentRestaurant == null
//           ? Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Image.network(
//               currentRestaurant!.imageUrl ?? '',
//               height: 200,
//               width: double.infinity,
//               fit: BoxFit.cover,
//               errorBuilder: (_, __, ___) => Container(
//                 height: 200,
//                 color: Colors.grey[200],
//                 child: Icon(Icons.image_not_supported),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(currentRestaurant!.name ?? "Unnamed", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
//                   SizedBox(height: 4),
//                   Text("⭐ ${currentRestaurant!.rating.toStringAsFixed(1)}"),
//                   SizedBox(height: 4),
//                   Text(currentRestaurant!.address ?? "No address available"),
//                 ],
//               ),
//             ),
//             if (featuredItems.isNotEmpty)
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     child: Text("Featured Items", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                   ),
//                   FoodAdapter(
//                     foodList: featuredItems,
//                     unusedRestaurant: currentRestaurant!,
//                     listener: (food) {},
//                   ),
//                 ],
//               ),
//             for (var entry in menuSections.entries)
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                     child: Text(entry.key, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                   ),
//                   FoodAdapter(
//                     foodList: entry.value,
//                     unusedRestaurant: currentRestaurant!,
//                     listener: (food) {},
//                   ),
//                 ],
//               ),
//             if (moreToExplore.isNotEmpty)
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                     child: Text("More to Explore", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                   ),
//                   SizedBox(
//                     height: 280,
//                     child: ListView.builder(
//                       scrollDirection: Axis.horizontal,
//                       itemCount: moreToExplore.length,
//                       itemBuilder: (context, index) => RestaurantTile(
//                         restaurant: moreToExplore[index],
//                         onTap: () {},
//                       ),
//                     ),
//                   )
//                 ],
//               )
//           ],
//         ),
//       ),
//     );
//   }
// }





// import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../models/restaurant.dart';
// import '../models/food_item.dart';
// import '../widgets/food_adapter.dart';
// import '../widgets/restaurant_tile.dart';
// import '../utils/restaurant_helper.dart';
// import '../models/location_coordinates.dart';
//
// class RestaurantPageScreen extends StatefulWidget {
//   final String restaurantId;
//
//   const RestaurantPageScreen({Key? key, required this.restaurantId}) : super(key: key);
//
//   @override
//   _RestaurantPageScreenState createState() => _RestaurantPageScreenState();
// }
//
// class _RestaurantPageScreenState extends State<RestaurantPageScreen> {
//   late DatabaseReference restaurantRef;
//   late DatabaseReference usersRef;
//
//   Restaurant? currentRestaurant;
//   double userLatitude = 0;
//   double userLongitude = 0;
//   List<FoodItem> featuredItems = [];
//   Map<String, List<FoodItem>> menuSections = {};
//   List<Restaurant> moreToExplore = [];
//
//   @override
//   void initState() {
//     super.initState();
//     restaurantRef = FirebaseDatabase.instance.ref("restaurant").child(widget.restaurantId);
//     usersRef = FirebaseDatabase.instance.ref();
//     _fetchRestaurantDetails();
//     _fetchUserLocation();
//     _fetchFeaturedItems();
//     _fetchMenuSections();
//   }
//
//   void _fetchRestaurantDetails() {
//     restaurantRef.once().then((snapshot) {
//       final data = snapshot.snapshot.value as Map<dynamic, dynamic>?;
//       if (data != null) {
//         final location = data['location'] as Map<dynamic, dynamic>?;
//         final restaurant = Restaurant(
//           id: widget.restaurantId,
//           name: data['name'] ?? 'Unnamed',
//           address: data['address'] ?? 'Unknown',
//           imageUrl: data['imageURL'] ?? '',
//           location: LocationCoordinates.withCoordinates(
//             double.tryParse(location?['latitude']?.toString() ?? '0.0') ?? 0.0,
//             double.tryParse(location?['longitude']?.toString() ?? '0.0') ?? 0.0,
//           ),
//           rating: double.tryParse(data['rating']?.toString() ?? '') ?? 4.5,
//         );
//
//         RestaurantHelper.setCurrentRestaurant(restaurant);
//         setState(() {
//           currentRestaurant = restaurant;
//         });
//         _fetchMoreToExplore();
//       }
//     });
//   }
//
//   void _fetchUserLocation() {
//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser == null) return;
//     FirebaseDatabase.instance
//         .ref("customer/\${currentUser.uid}/location")
//         .once()
//         .then((snapshot) {
//       final data = snapshot.snapshot.value as Map<dynamic, dynamic>?;
//       if (data != null) {
//         setState(() {
//           userLatitude = double.tryParse(data['latitude'].toString()) ?? 0;
//           userLongitude = double.tryParse(data['longitude'].toString()) ?? 0;
//         });
//       }
//     });
//   }
//
//   void _fetchFeaturedItems() {
//     restaurantRef.child("Special Offers").once().then((snapshot) {
//       final items = <FoodItem>[];
//       final data = snapshot.snapshot.value as Map<dynamic, dynamic>?;
//       data?.forEach((key, value) {
//         final item = FoodItem.fromRealtimeDB(
//             key, Map<String, dynamic>.from(value), widget.restaurantId);
//         items.add(item);
//       });
//       setState(() => featuredItems = items);
//     });
//   }
//
//   void _fetchMenuSections() {
//     restaurantRef.child("menu").once().then((snapshot) {
//       final sections = <String, List<FoodItem>>{};
//       final data = snapshot.snapshot.value as Map<dynamic, dynamic>?;
//       data?.forEach((category, itemList) {
//         final items = <FoodItem>[];
//         if (itemList is Map) {
//           itemList.forEach((key, value) {
//             items.add(FoodItem.fromRealtimeDB(
//                 key, Map<String, dynamic>.from(value), widget.restaurantId));
//           });
//         }
//         sections[category.toString()] = items;
//       });
//       setState(() => menuSections = sections);
//     });
//   }
//
//   void _fetchMoreToExplore() {
//     FirebaseDatabase.instance.ref("restaurant").once().then((snapshot) {
//       final restaurants = <Restaurant>[];
//       final data = snapshot.snapshot.value as Map<dynamic, dynamic>?;
//
//       data?.forEach((key, value) {
//         if (key != widget.restaurantId) {
//           final restData = Map<String, dynamic>.from(value);
//           final coords = Map<String, dynamic>.from(restData['location'] ?? {});
//           final r = Restaurant(
//             id: key,
//             name: restData['name'] ?? 'Unnamed',
//             address: restData['address'] ?? 'Unknown',
//             imageUrl: restData['imageURL'] ?? '',
//             location: LocationCoordinates.withCoordinates(
//               double.tryParse(coords['latitude'].toString()) ?? 0,
//               double.tryParse(coords['longitude'].toString()) ?? 0,
//             ),
//             rating: double.tryParse(restData['rating']?.toString() ?? '') ?? 4.5,
//           );
//           restaurants.add(r);
//         }
//       });
//
//       setState(() => moreToExplore = restaurants.take(7).toList());
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(currentRestaurant?.name ?? "Restaurant"),
//         backgroundColor: Colors.deepOrange,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: currentRestaurant == null
//           ? Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Image.network(
//               currentRestaurant!.imageUrl ?? '',
//               height: 200,
//               width: double.infinity,
//               fit: BoxFit.cover,
//               errorBuilder: (_, __, ___) => Container(
//                 height: 200,
//                 color: Colors.grey[200],
//                 child: Icon(Icons.image_not_supported),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(currentRestaurant!.name ?? "Unnamed", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
//                   SizedBox(height: 4),
//                   Text("⭐ \${currentRestaurant!.rating.toStringAsFixed(1)}"),
//                   SizedBox(height: 4),
//                   Text(currentRestaurant!.address ?? "No address available"),
//                 ],
//               ),
//             ),
//             if (featuredItems.isNotEmpty)
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     child: Text("Featured Items", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                   ),
//                   SizedBox(
//                     height: 230,
//                     child: ListView.builder(
//                       scrollDirection: Axis.horizontal,
//                       itemCount: featuredItems.length,
//                       itemBuilder: (context, index) => SizedBox(
//                         width: 200,
//                         child: FoodAdapter(
//                           foodList: [featuredItems[index]],
//                           unusedRestaurant: currentRestaurant!,
//                           listener: (food) {},
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             for (var entry in menuSections.entries)
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                     child: Text(entry.key, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                   ),
//                   SizedBox(
//                     height: 230,
//                     child: ListView.builder(
//                       scrollDirection: Axis.horizontal,
//                       itemCount: entry.value.length,
//                       itemBuilder: (context, index) => SizedBox(
//                         width: 200,
//                         child: FoodAdapter(
//                           foodList: [entry.value[index]],
//                           unusedRestaurant: currentRestaurant!,
//                           listener: (food) {},
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             if (moreToExplore.isNotEmpty)
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                     child: Text("More to Explore", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                   ),
//                   SizedBox(
//                     height: 280,
//                     child: ListView.builder(
//                       scrollDirection: Axis.horizontal,
//                       itemCount: moreToExplore.length,
//                       itemBuilder: (context, index) => RestaurantTile(
//                         restaurant: moreToExplore[index],
//                         onTap: () {},
//                       ),
//                     ),
//                   )
//                 ],
//               )
//           ],
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';
// import '../models/restaurant.dart';
// import '../models/food_item.dart';
// import '../widgets/food_adapter.dart';
// import '../widgets/restaurant_tile.dart';
// import '../utils/restaurant_helper.dart';
// import '../models/location_coordinates.dart';
//
// class RestaurantPageScreen extends StatefulWidget {
//   final String restaurantId;
//
//   const RestaurantPageScreen({Key? key, required this.restaurantId}) : super(key: key);
//
//   @override
//   _RestaurantPageScreenState createState() => _RestaurantPageScreenState();
// }
//
// class _RestaurantPageScreenState extends State<RestaurantPageScreen> {
//   late DatabaseReference restaurantRef;
//   Restaurant? currentRestaurant;
//   double userLatitude = 0;
//   double userLongitude = 0;
//   List<FoodItem> featuredItems = [];
//   Map<String, List<FoodItem>> menuSections = {};
//   List<Restaurant> moreToExplore = [];
//   String operatingHoursStatus = "";
//
//   @override
//   void initState() {
//     super.initState();
//     restaurantRef = FirebaseDatabase.instance.ref("restaurant").child(widget.restaurantId);
//     _fetchRestaurantDetails();
//     _fetchUserLocation();
//     _fetchFeaturedItems();
//     _fetchMenuSections();
//   }
//
//   void _fetchRestaurantDetails() {
//     restaurantRef.once().then((snapshot) {
//       final data = snapshot.snapshot.value as Map<dynamic, dynamic>?;
//       if (data != null) {
//         final location = data['location'] as Map<dynamic, dynamic>?;
//         final restaurant = Restaurant(
//           id: widget.restaurantId,
//           name: data['name'] ?? 'Unnamed',
//           address: data['address'] ?? 'Unknown',
//           imageUrl: data['imageURL'] ?? '',
//           location: LocationCoordinates.withCoordinates(
//             double.tryParse(location?['latitude']?.toString() ?? '0.0') ?? 0.0,
//             double.tryParse(location?['longitude']?.toString() ?? '0.0') ?? 0.0,
//           ),
//           rating: double.tryParse(data['rating']?.toString() ?? '') ?? 4.5,
//         );
//         RestaurantHelper.setCurrentRestaurant(restaurant);
//         setState(() {
//           currentRestaurant = restaurant;
//         });
//         _fetchMoreToExplore();
//         _fetchOperatingHoursStatus();
//       }
//     });
//   }
//
//   void _fetchUserLocation() {
//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser == null) return;
//     FirebaseDatabase.instance
//         .ref("customer/${currentUser.uid}/location")
//         .once()
//         .then((snapshot) {
//       final data = snapshot.snapshot.value as Map<dynamic, dynamic>?;
//       if (data != null) {
//         setState(() {
//           userLatitude = double.tryParse(data['latitude'].toString()) ?? 0;
//           userLongitude = double.tryParse(data['longitude'].toString()) ?? 0;
//         });
//       }
//     });
//   }
//
//   void _fetchFeaturedItems() {
//     restaurantRef.child("Special Offers").once().then((snapshot) {
//       final items = <FoodItem>[];
//       final data = snapshot.snapshot.value as Map<dynamic, dynamic>?;
//       data?.forEach((key, value) {
//         final item = FoodItem.fromRealtimeDB(key, Map<String, dynamic>.from(value), widget.restaurantId);
//         items.add(item);
//       });
//       setState(() => featuredItems = items);
//     });
//   }
//
//   void _fetchMenuSections() {
//     restaurantRef.child("menu").once().then((snapshot) {
//       final sections = <String, List<FoodItem>>{};
//       final data = snapshot.snapshot.value as Map<dynamic, dynamic>?;
//       data?.forEach((category, itemList) {
//         final items = <FoodItem>[];
//         if (itemList is Map) {
//           itemList.forEach((key, value) {
//             items.add(FoodItem.fromRealtimeDB(key, Map<String, dynamic>.from(value), widget.restaurantId));
//           });
//         }
//         sections[category.toString()] = items;
//       });
//       setState(() => menuSections = sections);
//     });
//   }
//
//   void _fetchMoreToExplore() {
//     FirebaseDatabase.instance.ref("restaurant").once().then((snapshot) {
//       final restaurants = <Restaurant>[];
//       final data = snapshot.snapshot.value as Map<dynamic, dynamic>?;
//
//       data?.forEach((key, value) {
//         if (key != widget.restaurantId) {
//           final restData = Map<String, dynamic>.from(value);
//           final coords = Map<String, dynamic>.from(restData['location'] ?? {});
//           final r = Restaurant(
//             id: key,
//             name: restData['name'] ?? 'Unnamed',
//             address: restData['address'] ?? 'Unknown',
//             imageUrl: restData['imageURL'] ?? '',
//             location: LocationCoordinates.withCoordinates(
//               double.tryParse(coords['latitude'].toString()) ?? 0,
//               double.tryParse(coords['longitude'].toString()) ?? 0,
//             ),
//             rating: double.tryParse(restData['rating']?.toString() ?? '') ?? 4.5,
//           );
//           restaurants.add(r);
//         }
//       });
//       setState(() => moreToExplore = restaurants.take(7).toList());
//     });
//   }
//
//   void _fetchOperatingHoursStatus() {
//     final day = DateFormat('EEEE').format(DateTime.now());
//     restaurantRef.child("operatingHours/$day").once().then((snapshot) {
//       final data = snapshot.snapshot.value as Map<dynamic, dynamic>?;
//       if (data != null && data.containsKey("open") && data.containsKey("close")) {
//         final openTime = data["open"];
//         final closeTime = data["close"];
//         final now = DateFormat("HH:mm").format(DateTime.now());
//         if (now.compareTo(openTime) < 0) {
//           setState(() => operatingHoursStatus = "Opens at $openTime");
//         } else if (now.compareTo(closeTime) > 0) {
//           setState(() => operatingHoursStatus = "Closed");
//         } else {
//           setState(() => operatingHoursStatus = "Closes at $closeTime");
//         }
//       } else {
//         setState(() => operatingHoursStatus = "Hours unavailable");
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(currentRestaurant?.name ?? "Restaurant"),
//         backgroundColor: Colors.deepOrange,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: currentRestaurant == null
//           ? Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Image.network(
//               currentRestaurant!.imageUrl ?? '',
//               height: 200,
//               width: double.infinity,
//               fit: BoxFit.cover,
//               errorBuilder: (_, __, ___) => Container(
//                 height: 200,
//                 color: Colors.grey[200],
//                 child: Icon(Icons.image_not_supported),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(currentRestaurant!.name ?? "Unnamed", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
//                   SizedBox(height: 4),
//                   Text("⭐ ${currentRestaurant!.rating.toStringAsFixed(1)}"),
//                   SizedBox(height: 4),
//                   Text(currentRestaurant!.address ?? "No address available"),
//                   SizedBox(height: 4),
//                   Text("$operatingHoursStatus"),
//                 ],
//               ),
//             ),
//             if (featuredItems.isNotEmpty)
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     child: Text("Featured Items", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                   ),
//                   SizedBox(
//                     height: 230,
//                     child: ListView.builder(
//                       scrollDirection: Axis.horizontal,
//                       itemCount: featuredItems.length,
//                       itemBuilder: (context, index) => SizedBox(
//                         width: 200,
//                         child: FoodAdapter(
//                           foodList: [featuredItems[index]],
//                           unusedRestaurant: currentRestaurant!,
//                           listener: (food) {},
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             for (var entry in menuSections.entries)
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                     child: Text(entry.key, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                   ),
//                   SizedBox(
//                     height: 230,
//                     child: ListView.builder(
//                       scrollDirection: Axis.horizontal,
//                       itemCount: entry.value.length,
//                       itemBuilder: (context, index) => SizedBox(
//                         width: 200,
//                         child: FoodAdapter(
//                           foodList: [entry.value[index]],
//                           unusedRestaurant: currentRestaurant!,
//                           listener: (food) {},
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             if (moreToExplore.isNotEmpty)
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                     child: Text("More to Explore", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                   ),
//                   SizedBox(
//                     height: 280,
//                     child: ListView.builder(
//                       scrollDirection: Axis.horizontal,
//                       itemCount: moreToExplore.length,
//                       itemBuilder: (context, index) => RestaurantTile(
//                         restaurant: moreToExplore[index],
//                         onTap: () => Navigator.pushReplacement(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => RestaurantPageScreen(
//                               restaurantId: moreToExplore[index].id ?? '',
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   )
//                 ],
//               )
//           ],
//         ),
//       ),
//     );
//   }
// }





import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../models/restaurant.dart';
import '../models/food_item.dart';
import '../models/location_coordinates.dart';
import '../models/review.dart'; // (optional: you can declare the Review class here or inline)
import '../utils/restaurant_helper.dart';
import '../widgets/food_adapter.dart';
import '../widgets/restaurant_tile.dart';
import 'food_detail.dart';

class RestaurantPageScreen extends StatefulWidget {
  final String restaurantId;
  const RestaurantPageScreen({Key? key, required this.restaurantId}) : super(key: key);

  @override
  _RestaurantPageScreenState createState() => _RestaurantPageScreenState();
}

class _RestaurantPageScreenState extends State<RestaurantPageScreen> {
  late DatabaseReference restaurantRef;
  Restaurant? currentRestaurant;
  double userLatitude = 0;
  double userLongitude = 0;
  List<FoodItem> featuredItems = [];
  Map<String, List<FoodItem>> menuSections = {};
  List<Restaurant> moreToExplore = [];
  String operatingHoursStatus = '';

  // Reviews related state
  List<Review> reviews = [];
  int reviewsBatch = 5;
  int reviewsTotal = 0;
  int currentReviewsShown = 0;

  @override
  void initState() {
    super.initState();
    restaurantRef = FirebaseDatabase.instance.ref("restaurant").child(widget.restaurantId);
    _fetchRestaurantDetails();
    _fetchUserLocation();
    _fetchFeaturedItems();
    _fetchMenuSections();
  }

  // Fetch the restaurant details including its location, image, rating, menu, operating hours and reviews.
  void _fetchRestaurantDetails() async {
    final snapshot = await restaurantRef.get();
    final data = snapshot.value as Map<dynamic, dynamic>?;
    if (data != null) {
      final locData = data['location'] as Map<dynamic, dynamic>?;
      final restaurant = Restaurant(
        id: widget.restaurantId,
        name: data['name'] ?? 'Unnamed',
        address: data['address'] ?? 'Unknown location',
        imageUrl: data['imageURL'] ?? '',
        location: LocationCoordinates.withCoordinates(
          double.tryParse(locData?['latitude']?.toString() ?? '0.0') ?? 0.0,
          double.tryParse(locData?['longitude']?.toString() ?? '0.0') ?? 0.0,
        ),
        rating: double.tryParse(data['rating']?.toString() ?? '') ?? 4.5,
      );
      // (Operating hours & other info such as comment count can be stored in restaurant, if needed)
      RestaurantHelper.setCurrentRestaurant(restaurant);
      setState(() {
        currentRestaurant = restaurant;
      });
      _fetchMoreToExplore();
      _fetchOperatingHoursStatus();
      _fetchReviewComments(startIndex: 0);
    }
  }

  // Fetch the user's location from the customer node in Firebase.
  void _fetchUserLocation() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;
    final snapshot = await FirebaseDatabase.instance
        .ref("customer/${currentUser.uid}/location")
        .get();
    final data = snapshot.value as Map<dynamic, dynamic>?;
    if (data != null) {
      setState(() {
        userLatitude = double.tryParse(data['latitude'].toString()) ?? 0;
        userLongitude = double.tryParse(data['longitude'].toString()) ?? 0;
      });
    }
  }

  // Calculate and return distance as a string.
  String _getDistanceString() {
    if (currentRestaurant == null || (userLatitude == 0 && userLongitude == 0)) {
      return "N/A";
    }
    double dist = calculateDistance(
      userLatitude,
      userLongitude,
      currentRestaurant!.location?.latitude ?? 0.0,
      currentRestaurant!.location?.longitude ?? 0.0,
    );
    return "${dist.toStringAsFixed(1)} km";
  }

  // Helper function to calculate distance using the Haversine formula.
  double calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // Earth's radius in km
    double dLat = _deg2rad(lat2 - lat1);
    double dLon = _deg2rad(lon2 - lon1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double deg) => deg * (pi / 180);

  // Fetch featured food items from "Special Offers" child node.
  void _fetchFeaturedItems() async {
    final snapshot = await restaurantRef.child("Special Offers").get();
    final data = snapshot.value as Map<dynamic, dynamic>?;
    final items = <FoodItem>[];
    data?.forEach((key, value) {
      final item = FoodItem.fromRealtimeDB(
          key, Map<String, dynamic>.from(value), widget.restaurantId);
      items.add(item);
    });
    setState(() => featuredItems = items);
  }

  // Fetch and organize menu sections.
  void _fetchMenuSections() async {
    final snapshot = await restaurantRef.child("menu").get();
    final data = snapshot.value as Map<dynamic, dynamic>?;
    final sections = <String, List<FoodItem>>{};
    data?.forEach((category, itemList) {
      final items = <FoodItem>[];
      if (itemList is Map) {
        itemList.forEach((key, value) {
          final item = FoodItem.fromRealtimeDB(
              key, Map<String, dynamic>.from(value), widget.restaurantId);
          items.add(item);
        });
      }
      sections[category.toString()] = items;
    });
    setState(() => menuSections = sections);
  }


  void _fetchMoreToExplore() async {
    final snapshot = await FirebaseDatabase.instance.ref("restaurant").get();
    final data = snapshot.value as Map<dynamic, dynamic>?;
    final restaurants = <Restaurant>[];

    data?.forEach((key, value) {
      if (key == widget.restaurantId) return; // skip current restaurant
      final restData = Map<String, dynamic>.from(value);
      final coords = Map<String, dynamic>.from(restData['location'] ?? {});
      final r = Restaurant(
        id: key,
        name: restData['name'] ?? 'Unnamed',
        address: restData['address'] ?? 'Unknown',
        imageUrl: restData['imageURL'] ?? '',
        location: LocationCoordinates.withCoordinates(
          double.tryParse(coords['latitude']?.toString() ?? '0') ?? 0.0,
          double.tryParse(coords['longitude']?.toString() ?? '0') ?? 0.0,
        ),
        rating: double.tryParse(restData['rating']?.toString() ?? '') ?? 4.5,
      );

      // Compute distance and ETA using this restaurant's own location
      double dist = calculateDistance(
          userLatitude,
          userLongitude,
          r.location?.latitude ?? 0.0, // Use 0.0 if latitude is null
          r.location?.longitude ?? 0.0 // Use 0.0 if longitude is null
      );
      r.distanceKm = dist;
      r.etaMinutes = (dist / 40.0 * 60).toInt();

      restaurants.add(r);
    });

    // Sort by distance
    restaurants.sort((a, b) => a.distanceKm!.compareTo(b.distanceKm!));
    setState(() => moreToExplore = restaurants.take(7).toList());
  }


  // Fetch operating hours status based on current day and time.
  void _fetchOperatingHoursStatus() async {
    final day = DateFormat('EEEE').format(DateTime.now());
    final snapshot =
    await restaurantRef.child("operatingHours").child(day).get();
    final data = snapshot.value as Map<dynamic, dynamic>?;
    if (data != null &&
        data.containsKey("open") &&
        data.containsKey("close")) {
      final openTime = data["open"];
      final closeTime = data["close"];
      final now = DateFormat("HH:mm").format(DateTime.now());
      if (now.compareTo(openTime) < 0) {
        setState(() => operatingHoursStatus = "Opens at $openTime");
      } else if (now.compareTo(closeTime) > 0) {
        setState(() => operatingHoursStatus = "Closed");
      } else {
        setState(() => operatingHoursStatus = "Closes at $closeTime");
      }
    } else {
      setState(() => operatingHoursStatus = "Hours unavailable");
    }
  }

  // Fetch review comments from the restaurant's ratings node with pagination.
  void _fetchReviewComments({required int startIndex}) async {
    final ratingsRef =
    FirebaseDatabase.instance.ref("restaurant/${widget.restaurantId}/ratings");
    final snapshot = await ratingsRef.orderByChild("timestamp").get();
    final data = snapshot.value as Map<dynamic, dynamic>?;
    if (data == null) return;

    // Convert entries to a list and filter out entries with no comment.
    List<MapEntry<dynamic, dynamic>> commentEntries = data.entries
        .where((entry) {
      final commentValue = (entry.value as Map)['comment'];
      return commentValue != null && (commentValue as String).isNotEmpty;
    })
        .toList();

    // Sort newest first.
    commentEntries.sort((a, b) {
      final aTimestamp = (a.value as Map)['timestamp'] ?? 0;
      final bTimestamp = (b.value as Map)['timestamp'] ?? 0;
      return bTimestamp.compareTo(aTimestamp);
    });

    reviewsTotal = commentEntries.length;
    // If starting a new batch, clear previous reviews.
    if (startIndex == 0) reviews.clear();

    int endIndex = (startIndex + reviewsBatch) > reviewsTotal
        ? reviewsTotal
        : (startIndex + reviewsBatch);
    for (int i = startIndex; i < endIndex; i++) {
      final entry = commentEntries[i];
      final reviewData = entry.value as Map;
      double rating = double.tryParse(reviewData['value']?.toString() ?? "") ?? 0;
      String comment = reviewData['comment'] ?? "";
      String userId = entry.key.toString();

      final review = Review(rating: rating, comment: comment, userId: userId);
      reviews.add(review);

      // Fetch the user's name for the review.
      FirebaseDatabase.instance.ref("customer/$userId").get().then((userSnapshot) {
        final userData = userSnapshot.value as Map<dynamic, dynamic>?;
        if (userData != null) {
          review.userName = userData['name'];
          if (mounted) setState(() {});
        }
      });
    }
    currentReviewsShown = reviews.length;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(currentRestaurant?.name ?? "Restaurant"),
        backgroundColor: Colors.deepOrange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: currentRestaurant == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant image
            (currentRestaurant!.imageUrl ?? '').isNotEmpty
                ? Image.network(
              currentRestaurant!.imageUrl ?? '',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 200,
                width: double.infinity,
                color: Colors.grey[200],
                child: const Icon(Icons.image, size: 100),
              ),
            )
                : Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey[200],
              child: const Icon(Icons.image, size: 100),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Restaurant name, rating, address, distance and operating hours
                  Text(
                    currentRestaurant!.name ?? 'Unnamed Restaurant',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text("⭐ ${currentRestaurant!.rating.toStringAsFixed(1)}"),
                  const SizedBox(height: 4),
                  Text(currentRestaurant!.address ?? 'No address available'),
                  const SizedBox(height: 4),
                  Text("Distance: ${_getDistanceString()}"),
                  const SizedBox(height: 4),
                  Text(operatingHoursStatus),
                ],
              ),
            ),
            // Review Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text(
                "Reviews",
                style:
                TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                  "$reviewsTotal review${reviewsTotal != 1 ? "s" : ""}"),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: reviews
                    .map((review) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    "⭐ ${review.rating} — ${review.userName ?? 'User'}: ${review.comment}",
                    style: const TextStyle(fontSize: 14),
                  ),
                ))
                    .toList(),
              ),
            ),
            if (currentReviewsShown < reviewsTotal)
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: TextButton(
                  onPressed: () =>
                      _fetchReviewComments(startIndex: currentReviewsShown),
                  child: const Text(
                    "View more",
                    style: TextStyle(
                        color: Colors.deepOrange,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            // Featured Items section.
            if (featuredItems.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text("Featured Items",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(
                    height: 230,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: featuredItems.length,
                      itemBuilder: (context, index) => SizedBox(
                        width: 200,
                        child: FoodAdapter(
                          foodList: [featuredItems[index]],
                          unusedRestaurant: currentRestaurant!,
                          listener: (food) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                builder: (_) => FoodDetailScreen(foodId: food.id!,
                                foodDescription: food.description ?? "",
                                foodImage: food.imageUrl ?? "",
                                foodPrice: food.price, food: food,), // pass your food item object
                            ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            // Dynamic Menu Sections.
            for (var entry in menuSections.entries)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Text(entry.key,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(
                    height: 230,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: entry.value.length,
                      itemBuilder: (context, index) => SizedBox(
                        width: 200,
                        child: FoodAdapter(
                          foodList: [entry.value[index]],
                          unusedRestaurant: currentRestaurant!,
                          listener: (food) {
                            // Navigate to food detail page.
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            // More to Explore section.
            if (moreToExplore.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Text("More to Explore",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(
                    height: 280,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: moreToExplore.length,
                      itemBuilder: (context, index) => RestaurantTile(
                        restaurant: moreToExplore[index],
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RestaurantPageScreen(
                                restaurantId:
                                moreToExplore[index].id ?? ''),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
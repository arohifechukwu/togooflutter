import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';

import '../models/location_coordinates.dart';
import '../models/restaurant.dart';
import '../models/food_category.dart';
import '../models/food_item.dart';
import '../widgets/food_adapter.dart';
import '../widgets/food_category_adapter.dart';
import '../cart_screen.dart';
import '../customer_home.dart' as home;
import '../view_all.dart';
import '../customer_bottom_navigation_menu.dart';
import '../restaurant_page.dart'; // Import restaurant page screen

class RestaurantScreen extends StatefulWidget {
  const RestaurantScreen({Key? key}) : super(key: key);

  @override
  _RestaurantHomeState createState() => _RestaurantHomeState();
}

class _RestaurantHomeState extends State<RestaurantScreen> {
  final TextEditingController searchController = TextEditingController();
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref("restaurant");

  List<Restaurant> restaurantList = [];
  List<FoodItem> searchSuggestions = [];
  List<FoodCategory> featuredCategories = [];
  List<FoodItem> specialOffers = [];
  List<FoodItem> topPicks = [];

  late FoodAdapter searchAdapter;

  int _currentIndex = 1;  // Use appropriate index for "Restaurant" tab

  @override
  void initState() {
    super.initState();

    searchAdapter = FoodAdapter(
      foodList: [],
      unusedRestaurant: Restaurant(),
      listener: (FoodItem food) {
        Navigator.pushNamed(context, '/food-detail', arguments: food);
      },
    );

    searchController.addListener(() {
      String query = searchController.text.trim();
      if (query.isNotEmpty) {
        searchMenuItems(query);
      } else {
        setState(() {
          searchSuggestions = [];
        });
      }
    });

    _setupCategories();
    _fetchSpecialOffers();
    _fetchTopPicks();
    fetchRestaurants();
  }

  void _setupCategories() {
    featuredCategories = [
      FoodCategory.fromUrl("Pizza", "assets/pizza.png"),
      FoodCategory.fromUrl("Burgers", "assets/burger.png"),
      FoodCategory.fromUrl("Sushi", "assets/sushi.png"),
      FoodCategory.fromUrl("Pasta", "assets/spaghetti.png"),
      FoodCategory.fromUrl("Seafood", "assets/shrimp.png"),
      FoodCategory.fromUrl("Salads", "assets/salad.png"),
      FoodCategory.fromUrl("Tacos", "assets/tacos.png"),
      FoodCategory.fromUrl("Desserts", "assets/cupcake.png"),
    ];
    setState(() {});
  }

  Future<void> searchMenuItems(String query) async {
    DataSnapshot snapshot = await dbRef.get();
    List<FoodItem> prefixMatches = [];
    List<FoodItem> substringMatches = [];
    String queryLower = query.toLowerCase();

    for (DataSnapshot restaurantSnap in snapshot.children) {
      String? restaurantId = restaurantSnap.key;
      DataSnapshot menuNode = restaurantSnap.child("menu");
      if (menuNode.exists) {
        for (DataSnapshot category in menuNode.children) {
          for (DataSnapshot foodSnap in category.children) {
            String? foodId = foodSnap.key;
            if (foodId != null) {
              FoodItem item = FoodItem.fromRealtimeDB(
                foodId,
                Map<String, dynamic>.from(foodSnap.value as Map),
                restaurantId ?? "",
              );
              if (foodId.toLowerCase().startsWith(queryLower)) {
                prefixMatches.add(item);
              } else if (foodId.toLowerCase().contains(queryLower)) {
                substringMatches.add(item);
              }
            }
          }
        }
      }
    }
    List<FoodItem> mergedResults = [...prefixMatches, ...substringMatches];
    setState(() {
      searchSuggestions = mergedResults.take(5).toList();
    });
  }

  Future<void> fetchRestaurants() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final uid = user.uid;
    final rootRef = FirebaseDatabase.instance.ref();
    List<String> roles = ["customer", "driver", "restaurant"];
    double userLat = 0.0;
    double userLon = 0.0;

    for (String role in roles) {
      DataSnapshot snapshot = await rootRef.child(role).child(uid).get();
      if (snapshot.exists) {
        final latValue = snapshot.child("location").child("latitude").value;
        final lonValue = snapshot.child("location").child("longitude").value;

        userLat = _toDouble(latValue);
        userLon = _toDouble(lonValue);
        break;
      }
    }

    loadRestaurants(userLat, userLon);
  }

  Future<void> _fetchSpecialOffers() async {
    final snapshot = await dbRef.get();
    List<FoodItem> fetchedOffers = [];

    for (var restaurant in snapshot.children) {
      String? restaurantId = restaurant.key;
      var offers = restaurant.child("Special Offers");
      if (offers.exists) {
        for (var item in offers.children) {
          if (item.key != null && item.value is Map) {
            try {
              final food = FoodItem.fromRealtimeDB(item.key!, item.value as Map, restaurantId ?? "");
              fetchedOffers.add(food);
            } catch (_) {}
          }
        }
      }
    }
    setState(() => specialOffers = fetchedOffers);
  }

  Future<void> _fetchTopPicks() async {
    final snapshot = await dbRef.get();
    List<FoodItem> fetchedPicks = [];

    for (var restaurant in snapshot.children) {
      String? restaurantId = restaurant.key;
      var picks = restaurant.child("Top Picks");
      if (picks.exists) {
        for (var item in picks.children) {
          if (item.key != null && item.value is Map) {
            try {
              final food = FoodItem.fromRealtimeDB(item.key!, item.value as Map, restaurantId ?? "");
              fetchedPicks.add(food);
            } catch (_) {}
          }
        }
      }
    }
    setState(() => topPicks = fetchedPicks);
  }

  double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Future<void> loadRestaurants(double userLat, double userLon) async {
    DataSnapshot snapshot = await dbRef.get();
    List<Restaurant> tempList = [];
    for (DataSnapshot restaurantSnap in snapshot.children) {
      String? id = restaurantSnap.key;
      String? name = restaurantSnap.child("name").value as String?;
      String? imageUrl = restaurantSnap.child("imageURL").value as String?;
      var latObj = restaurantSnap.child("location").child("latitude").value;
      var lonObj = restaurantSnap.child("location").child("longitude").value;
      String latStr = latObj?.toString() ?? "0";
      String lonStr = lonObj?.toString() ?? "0";
      double latitude = double.tryParse(latStr) ?? 0.0;
      double longitude = double.tryParse(lonStr) ?? 0.0;
      String addressString = await getAddressFromCoordinates(latitude, longitude);
      Map<String, dynamic>? opHoursMap;
      if (restaurantSnap.child("operatingHours").value != null) {
        opHoursMap = Map<String, dynamic>.from(
          restaurantSnap.child("operatingHours").value as Map,
        );
      }
      double rating = double.tryParse(restaurantSnap.child("rating").value.toString()) ?? 4.5;
      double distanceKm = sqrt(pow(userLat - latitude, 2) + pow(userLon - longitude, 2));
      int etaMinutes = (distanceKm / 40 * 60).toInt();

      if (name != null) {
        Restaurant restaurant = Restaurant.withDetails(
          id: id ?? "",
          name: name,
          address: addressString,
          imageUrl: imageUrl ?? "",
          location: LocationCoordinates.withCoordinates(latitude, longitude),
          operatingHours: {},
          rating: rating,
          distanceKm: distanceKm,
          etaMinutes: etaMinutes,
        );
        tempList.add(restaurant);
      }
    }
    setState(() {
      restaurantList = tempList;
    });
  }

  Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String address = "";
        if (place.thoroughfare?.isNotEmpty ?? false) {
          address += place.thoroughfare!;
        }
        if (place.locality?.isNotEmpty ?? false) {
          address += ", ${place.locality!}";
        }
        if (place.administrativeArea?.isNotEmpty ?? false) {
          address += ", ${place.administrativeArea!}";
        }
        return address;
      }
    } catch (e) {
      print("Error in getAddressFromCoordinates: $e");
    }
    return "Unknown location";
  }

  void onNavigationItemSelected(int index) {
    if (index == 1) return;
    if (index == 0) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => home.CustomerHome()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom header row
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Restaurants",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: Image.asset('assets/ic_cart.png', width: 25, height: 25),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CartScreen()),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Search menu...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 6),
              if (searchSuggestions.isNotEmpty)
                Column(
                  children: [
                    FoodAdapter(
                      foodList: searchSuggestions,
                      unusedRestaurant: Restaurant(),
                      listener: (foodItem) {
                        Navigator.pushNamed(context, '/food-detail', arguments: foodItem);
                      },
                    ),
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewAllScreen(foodItems: searchSuggestions),
                          ),
                        );
                      },
                      child: Text("View all ${searchSuggestions.length} results"),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              FoodCategoryAdapter(
                categories: featuredCategories,
                onCategoryClick: (category) {
                  Navigator.pushNamed(context, '/featured-category', arguments: category.name);
                },
              ),
              const SizedBox(height: 16),
              const Text(
                "Restaurants Near You",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3 / 4.3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: restaurantList.length,
                itemBuilder: (context, index) {
                  final restaurant = restaurantList[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RestaurantPageScreen(restaurantId: restaurant.id ?? ""),
                        ),
                      );
                    },
                    child: RestaurantItem(restaurant: restaurant),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      // Use the same bottom navigation as in CustomerHome.
      bottomNavigationBar: CustomerBottomNavigationMenu(selectedIndex: _currentIndex),
    );
  }
}

// Inline RestaurantItem widget
class RestaurantItem extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantItem({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    final String imageUrl = restaurant.imageUrl ?? '';
    final String name = restaurant.name ?? 'Unnamed';
    final double rating = restaurant.rating;
    final double distance = restaurant.distanceKm;
    final int eta = restaurant.etaMinutes;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              )
                  : Container(
                height: 100,
                width: double.infinity,
                color: Colors.grey.shade300,
                alignment: Alignment.center,
                child: const Icon(Icons.image_not_supported, size: 30),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text("$rating ⭐", style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              "${distance.toStringAsFixed(1)} km • $eta min",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
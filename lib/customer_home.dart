import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as gps;
import 'checkout_screen.dart';
import 'cart_screen.dart';
import 'featured_category_screen.dart';
import 'food_detail.dart';
import 'models/food_category.dart';
import 'models/food_item.dart';
import 'models/restaurant.dart';
import 'widgets/food_category_adapter.dart';
import 'widgets/food_adapter.dart';
import 'customer_bottom_navigation_menu.dart';
import 'notifications_screen.dart';
import 'utils/restaurant_helper.dart';

class CustomerHome extends StatefulWidget {
  @override
  _CustomerHomeState createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  final _dbRef = FirebaseDatabase.instance.ref();
  final _auth = FirebaseAuth.instance;
  final gps.Location _locationService = gps.Location();

  String _location = "Fetching location...";
  List<FoodCategory> categories = [];
  List<FoodItem> specialOffers = [];
  List<FoodItem> topPicks = [];

  List<FoodItem> _searchSuggestions = [];
  List<FoodItem> _allSearchResults = [];
  int _totalSearchResultsCount = 0;
  TextEditingController _searchController = TextEditingController();

  int _notificationCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
    _fetchData();
    _setupCategories();
    _listenForNotificationUpdates();
  }

  Future<void> _fetchLocation() async {
    bool serviceEnabled = await _locationService.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationService.requestService();
      if (!serviceEnabled) {
        setState(() => _location = "Location services disabled");
        return;
      }
    }
    gps.PermissionStatus permissionGranted = await _locationService.hasPermission();
    if (permissionGranted == gps.PermissionStatus.denied) {
      permissionGranted = await _locationService.requestPermission();
      if (permissionGranted != gps.PermissionStatus.granted) {
        setState(() => _location = "Location permission denied");
        return;
      }
    }
    final locData = await _locationService.getLocation();
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        locData.latitude!,
        locData.longitude!,
      );
      final place = placemarks.first;
      setState(() {
        _location = "${place.locality}, ${place.administrativeArea}";
      });
    } catch (e) {
      setState(() => _location = "Unknown location");
    }
  }

  void _fetchData() {
    _fetchSpecialOffers();
    _fetchTopPicks();
  }

  void _setupCategories() {
    categories = [
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

  Future<void> _fetchSpecialOffers() async {
    try {
      final snapshot = await _dbRef.child("restaurant").get();
      debugPrint("Fetching restaurants for Special Offers...");

      if (snapshot.exists) {
        List<FoodItem> fetchedOffers = [];

        for (var restaurant in snapshot.children) {
          String? restaurantId = restaurant.key;
          debugPrint("Checking restaurant ID: $restaurantId");

          var specialOffersNode = restaurant.child("Special Offers");
          if (specialOffersNode.exists) {
            debugPrint("Found 'Special Offers' for restaurant $restaurantId");

            for (var item in specialOffersNode.children) {
              debugPrint("  Item: ${item.key} - ${item.value}");

              if (item.key != null && item.value is Map) {
                try {
                  final itemMap = item.value as Map;
                  final offer = FoodItem.fromRealtimeDB(
                    item.key!,
                    itemMap,
                    restaurantId ?? "",
                  );
                  debugPrint("✅ Parsed Special Offer: ${offer.id} - \$${offer.price}");
                  fetchedOffers.add(offer);
                } catch (e) {
                  debugPrint("❌ Failed to parse Special Offer item: ${item.key} - $e");
                }
              }
            }
          } else {
            debugPrint("No 'Special Offers' found for $restaurantId");
          }
        }

        debugPrint("Total fetched special offers: ${fetchedOffers.length}");
        setState(() => specialOffers = fetchedOffers);
      } else {
        debugPrint("❌ No restaurants found in Firebase.");
      }
    } catch (e) {
      debugPrint("❌ Error fetching Special Offers: $e");
    }
  }

  Future<void> _fetchTopPicks() async {
    try {
      debugPrint("🔎 Fetching 'Top Picks'...");
      final snapshot = await _dbRef.child("restaurant").get();

      if (snapshot.exists) {
        List<FoodItem> fetchedPicks = [];

        for (var restaurant in snapshot.children) {
          String? restaurantId = restaurant.key;
          debugPrint("🏪 Checking restaurant: $restaurantId");

          var topPicksNode = restaurant.child("Top Picks");
          if (topPicksNode.exists) {
            debugPrint("✅ Found 'Top Picks' for restaurant: $restaurantId");

            for (var item in topPicksNode.children) {
              debugPrint("🔹 Item Key: ${item.key}, Value Type: ${item.value.runtimeType}");

              if (item.key != null && item.value is Map) {
                try {
                  final foodItem = FoodItem.fromRealtimeDB(
                    item.key!,
                    item.value as Map,
                    restaurantId ?? "",
                  );
                  debugPrint("🍽️ Parsed Top Pick: ${foodItem.id}, \$${foodItem.price}");
                  fetchedPicks.add(foodItem);
                } catch (e) {
                  debugPrint("❌ Failed to parse Top Pick item: ${item.key} - $e");
                }
              } else {
                debugPrint("⚠️ Skipped item: ${item.key} - Value was not a Map");
              }
            }
          } else {
            debugPrint("🚫 No 'Top Picks' node for restaurant: $restaurantId");
          }
        }

        debugPrint("📦 Total Top Picks fetched: ${fetchedPicks.length}");
        setState(() => topPicks = fetchedPicks);
      } else {
        debugPrint("❌ No restaurants found when fetching Top Picks.");
      }
    } catch (e) {
      debugPrint("❗ Error fetching Top Picks: $e");
    }
  }

  void _searchMenuItems(String query) {
    _dbRef.child("restaurant").once().then((DatabaseEvent event) {
      final snapshot = event.snapshot;
      List<FoodItem> prefixMatches = [];
      List<FoodItem> substringMatches = [];
      final queryLower = query.toLowerCase();

      for (var restaurant in snapshot.children) {
        final menuNode = restaurant.child("menu");
        if (menuNode.exists) {
          for (var categoryNode in menuNode.children) {
            for (var foodSnapshot in categoryNode.children) {
              final foodId = foodSnapshot.key;
              if (foodId != null) {
                // Call fromRealtimeDB with restaurant key.
                FoodItem? item = foodSnapshot.value != null
                    ? FoodItem.fromRealtimeDB(
                  foodId,
                  foodSnapshot.value as Map,
                  restaurant.key ?? "",
                )
                    : null;
                if (item != null) {
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
      }

      List<FoodItem> mergedResults = [...prefixMatches, ...substringMatches];

      setState(() {
        _allSearchResults = mergedResults;
        _searchSuggestions = mergedResults.take(5).toList();
        _totalSearchResultsCount = mergedResults.length;
      });
    }).catchError((error) {
      print("Search error: $error");
    });
  }

  void _listenForNotificationUpdates() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    _dbRef
        .child("orders")
        .orderByChild("customer/id")
        .equalTo(userId)
        .onValue
        .listen((event) {
      int count = 0;
      final snapshot = event.snapshot;
      for (var order in snapshot.children) {
        if (order.child("updateLogs").exists) {
          count += order.child("updateLogs").children.length;
        }
      }
      setState(() {
        _notificationCount = count;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar: Location, Notification, and Cart.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    "Location: $_location",
                    style: const TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis, // Prevents text overflow
                    maxLines: 1, // Ensures it's horizontal
                  ),
                ),
                Stack(
                  children: [
                    IconButton(
                      icon: Image.asset(
                        'assets/ic_notification.png',
                        width: 25,
                        height: 25,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const NotificationsScreen()),
                        );
                      },
                    ),
                    if (_notificationCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            _notificationCount.toString(),
                            style: const TextStyle(
                                fontSize: 10, color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
                IconButton(
                  icon: Image.asset(
                    'assets/ic_cart.png',
                    width: 25,
                    height: 25,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CartScreen()),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search menu...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (query) {
                if (query.trim().isNotEmpty) {
                  _searchMenuItems(query.trim());
                } else {
                  setState(() {
                    _searchSuggestions = [];
                  });
                }
              },
            ),
            if (_searchController.text.trim().isNotEmpty)
              Column(
                children: [
                  _searchSuggestions.isNotEmpty
                      ? ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _searchSuggestions.length,
                    itemBuilder: (context, index) {
                      return FoodAdapter(
                        foodList: [_searchSuggestions[index]],
                        unusedRestaurant:
                        Restaurant(), // Provide a fallback dummy Restaurant
                        listener: (food) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FoodDetailScreen(
                                foodId: food.id!,
                                foodDescription: food.description ?? "",
                                foodImage: food.imageUrl ?? "",
                                foodPrice: food.price, food: food,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  )
                      : Padding(
                    padding: const EdgeInsets.all(8),
                    child: const Text("No results found",
                        style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 4),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ViewAllScreen(foodItems: _allSearchResults),
                        ),
                      );
                    },
                    child: Text(
                      _totalSearchResultsCount > 0
                          ? "View all $_totalSearchResultsCount results"
                          : "No results found",
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            // Featured Categories
            const Text("Featured Categories",
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            FoodCategoryAdapter(
              categories: categories,
              onCategoryClick: (category) => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FeaturedCategoryScreen(
                      selectedCategory: category.name ?? ""),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Special Offers Section
            const Text("Special Offers",
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            FoodAdapter(
              foodList: specialOffers,
              unusedRestaurant: Restaurant(), // Fallback dummy Restaurant
              listener: (food) => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FoodDetailScreen(
                    foodId: food.id!,
                    foodDescription: food.description ?? "",
                    foodImage: food.imageUrl ?? "",
                    foodPrice: food.price, food: food,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Top Picks Section
            const Text("Top Picks",
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            FoodAdapter(
              foodList: topPicks,
              unusedRestaurant: Restaurant(),
              listener: (food) => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FoodDetailScreen(
                    foodId: food.id!,
                    foodDescription: food.description ?? "",
                    foodImage: food.imageUrl ?? "",
                    foodPrice: food.price, food: food,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
      CustomerBottomNavigationMenu(selectedIndex: 0),
    );
  }
}

class ViewAllScreen extends StatelessWidget {
  final List<FoodItem> foodItems;

  const ViewAllScreen({Key? key, required this.foodItems}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF18D34),
        title: const Text("Search Results"),
        titleTextStyle:
        const TextStyle(color: Colors.white, fontSize: 20),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: foodItems.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: FoodAdapter(
          foodList: foodItems,
          unusedRestaurant: Restaurant(),
          listener: (food) {
            Navigator.pushNamed(
              context,
              '/food-detail',
              arguments: food,
            );
          },
        ),
      ),
    );
  }
}
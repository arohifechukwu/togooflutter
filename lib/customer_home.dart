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
import 'widgets/food_category_adapter.dart';
import 'widgets/food_adapter.dart';
import 'customer_bottom_navigation_menu.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchLocation();
    _fetchData();
    _setupCategories();
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
      FoodCategory(name: "Pizza", imageUrl: "assets/icons/pizza.png"),
      FoodCategory(name: "Burgers", imageUrl: "assets/icons/burger.png"),
      FoodCategory(name: "Sushi", imageUrl: "assets/icons/sushi.png"),
      FoodCategory(name: "Pasta", imageUrl: "assets/icons/spaghetti.png"),
      FoodCategory(name: "Seafood", imageUrl: "assets/icons/shrimp.png"),
      FoodCategory(name: "Salads", imageUrl: "assets/icons/salad.png"),
      FoodCategory(name: "Tacos", imageUrl: "assets/icons/tacos.png"),
      FoodCategory(name: "Desserts", imageUrl: "assets/icons/cupcake.png"),
    ];
    setState(() {});
  }

  Future<void> _fetchSpecialOffers() async {
    final snapshot = await _dbRef.child("restaurant").get();
    if (snapshot.exists) {
      List<FoodItem> fetchedOffers = [];
      for (var restaurant in snapshot.children) {
        for (var item in restaurant.child("Special Offers").children) {
          fetchedOffers.add(FoodItem.fromRealtimeDB(item.key!, item.value as Map));
        }
      }
      setState(() => specialOffers = fetchedOffers);
    }
  }

  Future<void> _fetchTopPicks() async {
    final snapshot = await _dbRef.child("restaurant").get();
    if (snapshot.exists) {
      List<FoodItem> fetchedPicks = [];
      for (var restaurant in snapshot.children) {
        for (var item in restaurant.child("Top Picks").children) {
          fetchedPicks.add(FoodItem.fromRealtimeDB(item.key!, item.value as Map));
        }
      }
      setState(() => topPicks = fetchedPicks);
    }
  }

  void _searchMenuItems(String query) {
    _dbRef.child("restaurant").once().then((DatabaseEvent event) {
      final snapshot = event.snapshot;
      List<FoodItem> prefixMatches = [];
      List<FoodItem> substringMatches = [];
      final queryLower = query.toLowerCase();

      for (DataSnapshot restaurant in snapshot.children) {
        final menuNode = restaurant.child("menu");
        if (menuNode.exists) {
          for (DataSnapshot categoryNode in menuNode.children) {
            for (DataSnapshot foodSnapshot in categoryNode.children) {
              final foodId = foodSnapshot.key;
              if (foodId != null) {
                FoodItem? item = foodSnapshot.value != null
                    ? FoodItem.fromRealtimeDB(foodId, foodSnapshot.value as Map)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Location: $_location", style: TextStyle(fontSize: 16)),
                IconButton(
                  icon: Image.asset('assets/icons/ic_cart.png', width: 24, height: 24),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CartScreen()),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 10),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search menu...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (query) {
                if (query.trim().isNotEmpty) {
                  _searchMenuItems(query.trim());
                } else {
                  setState(() => _searchSuggestions = []);
                }
              },
            ),
            if (_searchController.text.trim().isNotEmpty)
              Column(
                children: [
                  _searchSuggestions.isNotEmpty
                      ? ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _searchSuggestions.length,
                    itemBuilder: (context, index) {
                      return FoodAdapter(
                        foodList: [_searchSuggestions[index]],
                        onFoodClick: (food) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FoodDetailScreen(
                                foodId: food.id,
                                foodDescription: food.description,
                                foodImage: food.imageUrl,
                                foodPrice: food.price,
                              ),
                            ),
                          );
                        },
                        isSearchSuggestion: true,
                      );
                    },
                  )
                      : Padding(
                    padding: EdgeInsets.all(8),
                    child: Text("No results found", style: TextStyle(fontSize: 16)),
                  ),
                  SizedBox(height: 4),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewAllScreen(foodItems: _allSearchResults),
                        ),
                      );
                    },
                    child: Text(_totalSearchResultsCount > 0
                        ? "View all $_totalSearchResultsCount results"
                        : "No results found"),
                  ),
                ],
              ),
            SizedBox(height: 20),
            Text("Featured Categories", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            FoodCategoryAdapter(
              categories: categories,
              onCategoryClick: (category) => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FeaturedCategoryScreen(selectedCategory: category.name),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text("Special Offers", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            FoodAdapter(
              foodList: specialOffers,
              onFoodClick: (food) => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FoodDetailScreen(
                    foodId: food.id,
                    foodDescription: food.description,
                    foodImage: food.imageUrl,
                    foodPrice: food.price,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text("Top Picks", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            FoodAdapter(
              foodList: topPicks,
              onFoodClick: (food) => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FoodDetailScreen(
                    foodId: food.id,
                    foodDescription: food.description,
                    foodImage: food.imageUrl,
                    foodPrice: food.price,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomerBottomNavigationMenu(selectedIndex: 0),
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
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: foodItems.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FoodAdapter(
            foodList: foodItems,
            onFoodClick: (food) {
              Navigator.pushNamed(
                context,
                '/food-detail',
                arguments: food,
              );
            },
            scrollDirection: Axis.vertical,
          ),
        ],
      ),
    );
  }
}
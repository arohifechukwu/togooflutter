import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:location/location.dart' as gps;
import 'models/food_item.dart';
import 'models/food_category.dart';
import 'widgets/food_category_adapter.dart';
import 'widgets/food_adapter.dart';
import 'customer_bottom_navigation_menu.dart';
import 'package:geocoding/geocoding.dart';
import 'featured_category_screen.dart';
import 'cart_screen.dart';
import 'food_detail.dart';


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

  @override
  void initState() {
    super.initState();
    _fetchLocation();
    _fetchData();
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

    // 🌍 Reverse Geocode to get readable address
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

    // 🔁 Still update coordinates to Firebase
    await updateUserLocationInFirebase(locData.latitude!, locData.longitude!);
  }


  Future<void> updateUserLocationInFirebase(double latitude, double longitude) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("User not logged in.");
      return;
    }

    final userId = user.uid;
    final rootRef = FirebaseDatabase.instance.ref();
    final userTypes = ['customer', 'admin', 'restaurant', 'driver'];

    for (String role in userTypes) {
      final userRef = rootRef.child(role).child(userId);
      final snapshot = await userRef.get();

      if (snapshot.exists) {
        final locationRef = userRef.child('location');
        await locationRef.update({
          'Latitude': latitude,
          'Longitude': longitude,
        });

        print("Location updated for $role");
        break; // Exit loop after the first match
      }
    }
    final locData = await _locationService.getLocation();
    await updateUserLocationInFirebase(locData.latitude!, locData.longitude!);
  }

  void _fetchData() {
    _fetchCategories();
    _fetchSpecialOffers();
    _fetchTopPicks();
  }

  void _fetchCategories() {
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

  void _fetchSpecialOffers() async {
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

  void _fetchTopPicks() async {
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

  void _navigateToCategory(String categoryName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FeaturedCategoryScreen(selectedCategory: categoryName),
      ),
    );
  }

  void _navigateToFoodDetail(FoodItem foodItem) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoodDetailScreen(
          foodId: foodItem.id,
          foodDescription: foodItem.description,
          foodImage: foodItem.imageUrl,
          foodPrice: foodItem.price,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home"), backgroundColor: Colors.orange),
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
                  icon: Image.asset(
                    'assets/icons/ic_cart.png',
                    width: 24,
                    height: 24,
                  ),
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
              decoration: InputDecoration(
                hintText: "Search menu...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (query) => print("Search: $query"),
            ),
            SizedBox(height: 20),
            Text("Featured Categories", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            FoodCategoryAdapter(
              categories: categories,
              onCategoryClick: (category) => _navigateToCategory(category.name),
            ),
            SizedBox(height: 20),
            Text("Special Offers", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            FoodAdapter(
              foodList: specialOffers,
              onFoodClick: _navigateToFoodDetail,
            ),
            SizedBox(height: 20),
            Text("Top Picks", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            FoodAdapter(
              foodList: topPicks,
              onFoodClick: _navigateToFoodDetail,
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomerBottomNavigationMenu(selectedIndex: 0),
    );
  }
}
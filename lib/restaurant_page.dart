import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../models/restaurant.dart';
import '../models/food_item.dart';
import '../models/location_coordinates.dart';
import '../models/review.dart'; // Ensure Review model is defined
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

  // Reviews related state.
  List<Review> reviews = [];
  final int reviewsBatch = 5;
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

  // Fetch the restaurant details and listen for realtime updates.
  void _fetchRestaurantDetails() {
    restaurantRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
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
        RestaurantHelper.setCurrentRestaurant(restaurant);
        setState(() {
          currentRestaurant = restaurant;
        });
        _fetchMoreToExplore();
        _fetchOperatingHoursStatus();
        _fetchReviewComments(startIndex: 0);
      }
    });
  }

  // Fetch the customer's location from the "customer" node.
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

  // Calculate distance using Haversine formula.
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // Earth's radius in km.
    double dLat = _deg2rad(lat2 - lat1);
    double dLon = _deg2rad(lon2 - lon1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double deg) => deg * (pi / 180);

  // Returns the distance string with " km".
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

  // Returns the ETA string with " mins". ETA is calculated using driving speed (40 km/h).
  String _getEtaString() {
    if (currentRestaurant == null || (userLatitude == 0 && userLongitude == 0)) {
      return "N/A";
    }
    double dist = calculateDistance(
      userLatitude,
      userLongitude,
      currentRestaurant!.location?.latitude ?? 0.0,
      currentRestaurant!.location?.longitude ?? 0.0,
    );
    int etaMinutes = (dist / 40.0 * 60).round();
    return "$etaMinutes mins";
  }

  // Fetch featured food items from "Special Offers" with validation.
  void _fetchFeaturedItems() async {
    final snapshot = await restaurantRef.child("Special Offers").get();
    final data = snapshot.value as Map<dynamic, dynamic>?;
    final items = <FoodItem>[];
    data?.forEach((key, value) {
      final itemMap = Map<String, dynamic>.from(value);
      if (itemMap.containsKey('description') &&
          itemMap.containsKey('imageURL') &&
          itemMap.containsKey('price')) {
        try {
          final item = FoodItem.fromRealtimeDB(key, itemMap, widget.restaurantId);
          items.add(item);
        } catch (e) {
          debugPrint("Error parsing FoodItem in Special Offers for key $key: $e");
        }
      } else {
        debugPrint("Skipping item $key in Special Offers: missing fields");
      }
    });
    setState(() => featuredItems = items);
  }

  // Fetch menu sections (from "menu") with validation.
  void _fetchMenuSections() async {
    final snapshot = await restaurantRef.child("menu").get();
    final data = snapshot.value as Map<dynamic, dynamic>?;
    final sections = <String, List<FoodItem>>{};
    data?.forEach((category, itemList) {
      final items = <FoodItem>[];
      if (itemList is Map) {
        itemList.forEach((key, value) {
          final itemMap = Map<String, dynamic>.from(value);
          if (itemMap.containsKey('description') &&
              itemMap.containsKey('imageURL') &&
              itemMap.containsKey('price')) {
            try {
              final item = FoodItem.fromRealtimeDB(key, itemMap, widget.restaurantId);
              items.add(item);
            } catch (e) {
              debugPrint("Error parsing FoodItem with key '$key' in category '$category': $e");
            }
          } else {
            debugPrint("Skipping item '$key' in category '$category': missing required fields.");
          }
        });
      }
      if (items.isNotEmpty) {
        sections[category.toString()] = items;
      }
    });
    setState(() => menuSections = sections);
  }

  // Fetch "More to Explore" restaurants; log each restaurant's imageURL for debugging.
  void _fetchMoreToExplore() async {
    DatabaseReference restaurantsRef = FirebaseDatabase.instance.ref("restaurant");
    restaurantsRef.once().then((snapshot) {
      final data = snapshot.snapshot.value as Map<dynamic, dynamic>?;
      final List<Restaurant> restaurants = [];
      if (data == null) return;
      if (userLatitude == 0 || userLongitude == 0) {
        debugPrint("User location not set. Skipping distance calculation.");
        return;
      }
      data.forEach((key, value) {
        if (key == widget.restaurantId) return;
        try {
          final restData = Map<String, dynamic>.from(value);
          final name = restData['name']?.toString() ?? 'Unnamed';
          final address = restData['address']?.toString() ?? 'Unknown';
          final imageUrl = restData['imageURL']?.toString() ?? '';
          if (imageUrl.isEmpty) {
            debugPrint("⚠️ Restaurant '$name' has an empty imageURL.");
          } else {
            debugPrint("✅ Restaurant '$name' has imageURL: $imageUrl");
          }
          final rating = double.tryParse(restData['rating']?.toString() ?? '') ?? 4.5;
          final locationMap = restData['location'];
          if (locationMap == null || locationMap is! Map) {
            debugPrint("Skipping restaurant '$name': Missing location.");
            return;
          }
          final coords = Map<String, dynamic>.from(locationMap);
          final lat = double.tryParse(coords['latitude']?.toString() ?? '');
          final lon = double.tryParse(coords['longitude']?.toString() ?? '');
          if (lat == null || lon == null) {
            debugPrint("Skipping restaurant '$name': Invalid coordinates.");
            return;
          }
          final restaurant = Restaurant(
            id: key,
            name: name,
            address: address,
            imageUrl: imageUrl,
            location: LocationCoordinates.withCoordinates(lat, lon),
            rating: rating,
          );
          double dist = calculateDistance(userLatitude, userLongitude, lat, lon);
          restaurant.distanceKm = dist;
          // ETA calculated using driving speed (40 km/h).
          restaurant.etaMinutes = (dist / 40.0 * 60).round();
          restaurants.add(restaurant);
        } catch (e) {
          debugPrint("Error reading restaurant '$key': $e");
        }
      });
      restaurants.sort((a, b) => a.distanceKm!.compareTo(b.distanceKm!));
      setState(() => moreToExplore = restaurants.take(7).toList());
    });
  }

  // Fetch operating hours status.
  void _fetchOperatingHoursStatus() async {
    final day = DateFormat('EEEE').format(DateTime.now());
    final snapshot = await restaurantRef.child("operatingHours").child(day).get();
    final data = snapshot.value as Map<dynamic, dynamic>?;
    if (data != null && data.containsKey("open") && data.containsKey("close")) {
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

  // Fetch review comments with pagination.
  void _fetchReviewComments({required int startIndex}) async {
    final ratingsRef = FirebaseDatabase.instance
        .ref("restaurant/${widget.restaurantId}/ratings");
    final snapshot = await ratingsRef.orderByChild("timestamp").get();
    final data = snapshot.value as Map<dynamic, dynamic>?;
    if (data == null) return;
    List<MapEntry<dynamic, dynamic>> commentEntries = data.entries.where((entry) {
      final commentValue = (entry.value as Map)['comment'];
      return commentValue != null && (commentValue as String).isNotEmpty;
    }).toList();
    commentEntries.sort((a, b) {
      final aTimestamp = (a.value as Map)['timestamp'] ?? 0;
      final bTimestamp = (b.value as Map)['timestamp'] ?? 0;
      return bTimestamp.compareTo(aTimestamp);
    });
    reviewsTotal = commentEntries.length;
    if (startIndex == 0) reviews.clear();
    int endIndex = (startIndex + reviewsBatch) > reviewsTotal ? reviewsTotal : (startIndex + reviewsBatch);
    for (int i = startIndex; i < endIndex; i++) {
      final entry = commentEntries[i];
      final reviewData = entry.value as Map;
      double rating = double.tryParse(reviewData['value']?.toString() ?? "") ?? 0;
      String comment = reviewData['comment'] ?? "";
      String userId = entry.key.toString();
      final review = Review(rating: rating, comment: comment, userId: userId);
      reviews.add(review);
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
            // Restaurant image.
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
                  // Restaurant details.
                  Text(
                    currentRestaurant!.name ?? 'Unnamed Restaurant',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text("⭐ ${currentRestaurant!.rating.toStringAsFixed(1)}"),
                  const SizedBox(height: 4),
                  Text(currentRestaurant!.address ?? 'No address available'),
                  const SizedBox(height: 4),
                  // Display distance with " km"
                  Text(_getDistanceString()),
                  const SizedBox(height: 4),
                  // Display ETA with " mins"
                  Text(_getEtaString()),
                  const SizedBox(height: 4),
                  Text(operatingHoursStatus),
                ],
              ),
            ),
            // Review Section.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text(
                "Reviews",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text("$reviewsTotal review${reviewsTotal != 1 ? "s" : ""}"),
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
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
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
                                builder: (_) => FoodDetailScreen(
                                  foodId: food.id!,
                                  foodDescription: food.description ?? "",
                                  foodImage: food.imageUrl ?? "",
                                  foodPrice: food.price,
                                  food: food,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            // "Menu" Section Header.
            if (menuSections.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: const Text("Menu",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ),
            // Dynamic Menu Sections.
            for (var entry in menuSections.entries)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Text(entry.key,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
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
                          // Using the same listener as for featured items.
                          listener: (food) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FoodDetailScreen(
                                  foodId: food.id!,
                                  foodDescription: food.description ?? "",
                                  foodImage: food.imageUrl ?? "",
                                  foodPrice: food.price,
                                  food: food,
                                ),
                              ),
                            );
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
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        // Navigate to display the selected restaurant.
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RestaurantPageScreen(
                                restaurantId: moreToExplore[index].id ?? ''),
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

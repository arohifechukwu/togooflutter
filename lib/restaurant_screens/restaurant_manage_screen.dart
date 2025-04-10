import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../edit_food_item.dart'; // Make sure this file exists for editing food items
import 'restaurant_new_screen.dart';
import 'restaurant_report_screen.dart';
import '../restaurant_home.dart';
import 'restaurant_account_screen.dart';
import '../restaurant_bottom_navigation_menu.dart';
import 'package:togoo/models/food_item.dart'; // Ensure your FoodItem model is defined

class RestaurantManageScreen extends StatefulWidget {
  const RestaurantManageScreen({Key? key}) : super(key: key);

  @override
  State<RestaurantManageScreen> createState() => _RestaurantManageScreenState();
}

class _RestaurantManageScreenState extends State<RestaurantManageScreen> {
  final TextEditingController _searchController = TextEditingController();
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final String restaurantUID = FirebaseAuth.instance.currentUser!.uid;
  List<Map<String, dynamic>> allItems = [];
  List<Map<String, dynamic>> filteredItems = [];
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    fetchAllSections();
    _searchController.addListener(() {
      setState(() {
        searchQuery = _searchController.text.trim().toLowerCase();
        filterItems();
      });
    });
  }

  // Fetch both section items and menu items.
  void fetchAllSections() {
    fetchSection("Special Offers");
    fetchSection("Top Picks");
    fetchMenuItems();
  }

  // Fetch a specific section from restaurant node.
  void fetchSection(String section) {
    _dbRef.child("restaurant").child(restaurantUID).child(section).onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        // Map each entry to a food item and add section information.
        final items = data.entries.map((entry) {
          final item = Map<String, dynamic>.from(entry.value);
          item['id'] = entry.key;
          item['section'] = section;
          return item;
        }).toList();

        setState(() {
          // Remove any existing items in this section
          allItems.removeWhere((e) => e['section'] == section);
          allItems.addAll(items);
          filterItems();
        });
      }
    });
  }

  // Fetch all food items from the "menu" node.
  void fetchMenuItems() {
    _dbRef.child("restaurant").child(restaurantUID).child("menu").onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        List<Map<String, dynamic>> items = [];
        data.forEach((category, categoryItems) {
          final foodMap = Map<String, dynamic>.from(categoryItems);
          foodMap.forEach((foodId, value) {
            final item = Map<String, dynamic>.from(value);
            item['id'] = foodId;
            item['section'] = "menu";
            item['category'] = category;
            items.add(item);
          });
        });
        setState(() {
          allItems.removeWhere((e) => e['section'] == "menu");
          allItems.addAll(items);
          filterItems();
        });
      }
    });
  }

  // Filter food items based on the search query.
  void filterItems() {
    if (searchQuery.isEmpty) {
      filteredItems = List.from(allItems);
    } else {
      filteredItems = allItems.where((item) {
        final id = item['id'].toString().toLowerCase();
        final section = item['section'].toString().toLowerCase();
        final category = item['category']?.toString().toLowerCase() ?? "";
        return id.contains(searchQuery) ||
            section.contains(searchQuery) ||
            category.contains(searchQuery);
      }).toList();
    }
  }

  // Delete a food item from Firebase Realtime Database and its image from Storage.
  void deleteItem(Map<String, dynamic> item) async {
    final section = item['section'];
    final id = item['id'];
    final category = item['category'];
    final imageURL = item['imageURL'];

    DatabaseReference ref;
    if (section == "menu") {
      ref = _dbRef.child("restaurant").child(restaurantUID).child("menu").child(category).child(id);
    } else {
      ref = _dbRef.child("restaurant").child(restaurantUID).child(section).child(id);
    }

    await ref.remove();

    if (imageURL != null && imageURL.toString().isNotEmpty) {
      try {
        final storageRef = FirebaseStorage.instance.refFromURL(imageURL);
        await storageRef.delete();
      } catch (e) {
        // Could not delete the image; optionally log or notify.
      }
    }
  }

  // Navigate to the edit screen with current food item data.
  void _navigateToEditFoodItem(Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditFoodItemScreen(
          foodId: item['id'],
          nodeType: item['section'],
          restaurantId: restaurantUID,
          category: item['category'] ?? '',
          foodName: item['id'],
          foodDescription: item['description'],
          foodPrice: item['price'],
          imageURL: item['imageURL'] ?? '',
        ),
      ),
    );
  }

  // Build a card widget for the given food item.
  Widget buildFoodCard(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CachedNetworkImage(
              imageUrl: item['imageURL'],
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.fastfood),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['id'] ?? "", style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(item['description'] ?? ""),
                  Text("Price: \$${item['price']}")
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => deleteItem(item),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _navigateToEditFoodItem(item),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Food Items"),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: "Search...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("Results: ${filteredItems.length}"),
            ),
          ),
          Expanded(
            child: ListView(
              children: filteredItems.map(buildFoodCard).toList(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: RestaurantBottomNavigationMenu(
        currentIndex: 3
      ),
    );
  }
}



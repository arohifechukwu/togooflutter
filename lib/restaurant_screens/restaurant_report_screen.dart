import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class RestaurantReportScreen extends StatefulWidget {
  const RestaurantReportScreen({Key? key}) : super(key: key);

  @override
  _RestaurantReportScreenState createState() => _RestaurantReportScreenState();
}

class _RestaurantReportScreenState extends State<RestaurantReportScreen> {
  late Future<List<Map<String, dynamic>>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _fetchOrders();
  }

  /// Fetch orders for the current restaurant. First, from the node
  /// "ordersByRestaurant/<restaurantId>" we get the list of order IDs.
  /// Then, for each order ID, we fetch the order details from "orders/<orderId>".
  Future<List<Map<String, dynamic>>> _fetchOrders() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception("User not logged in");
    }
    final restaurantId = currentUser.uid;

    DatabaseReference ordersByRestaurantRef = FirebaseDatabase.instance
        .ref()
        .child("ordersByRestaurant")
        .child(restaurantId);
    DatabaseEvent event = await ordersByRestaurantRef.once();

    List<Map<String, dynamic>> ordersList = [];
    if (event.snapshot.value != null) {
      Map<dynamic, dynamic> ordersMap =
      event.snapshot.value as Map<dynamic, dynamic>;
      // For each order ID, fetch the order details from "orders/<orderId>"
      for (var key in ordersMap.keys) {
        DatabaseReference orderRef = FirebaseDatabase.instance
            .ref()
            .child("orders")
            .child(key.toString());
        DatabaseEvent orderEvent = await orderRef.once();
        if (orderEvent.snapshot.value != null) {
          Map orderData = orderEvent.snapshot.value as Map;
          orderData["orderId"] = key.toString();
          ordersList.add(Map<String, dynamic>.from(orderData));
        }
      }
    }
    // Sort orders by the "placed" timestamp (assuming it's stored under timestamps/placed)
    ordersList.sort((a, b) {
      String aPlaced = a["timestamps"]?["placed"]?.toString() ?? "";
      String bPlaced = b["timestamps"]?["placed"]?.toString() ?? "";
      return bPlaced.compareTo(aPlaced);
    });
    return ordersList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Restaurant Report"),
        leading: const BackButton(),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final orders = snapshot.data!;
          if (orders.isEmpty) {
            return const Center(child: Text("No orders available."));
          }
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return OrderCard(order: order);
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // assuming the Reports tab is at index 2
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: "Orders",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: "New",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: "Reports",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_accounts),
            label: "Manage",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: "Account",
          )
        ],
        onTap: (index) {
          // Handle navigation by index.
          // For example, if the user taps a different tab, navigate accordingly.
          // This sample does not implement full navigation.
        },
      ),
    );
  }
}

/// A widget that displays the details of a single order in a card.
class OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  const OrderCard({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract order details.
    String orderId = order["orderId"] ?? "N/A";
    // Restaurant rating provided by customer.
    var rating = order["restaurantRating"];
    String restaurantRating =
    (rating != null) ? rating.toString() : "Not Rated";
    // Restaurant review.
    String restaurantReview =
        order["restaurantReview"] ?? "No review provided";

    // Driver details: expecting a Map (if exists) under "driver".
    Map? driver = order["driver"];
    String driverName = "Not Assigned";
    String driverPhone = "";
    String driverAssigned = "";
    if (driver != null) {
      driverName = driver["name"] ?? "Unknown";
      driverPhone = driver["phone"] ?? "Unknown";
      driverAssigned = driver["assignmentTimestamp"] ?? "N/A";
    }
    // Order status from "payment/status"
    String status = order["payment"]?["status"]?.toString() ?? "Unknown";
    // Timestamps: "placed" and "delivered"
    String placed = order["timestamps"]?["placed"]?.toString() ?? "";
    String delivered = order["timestamps"]?["delivered"]?.toString() ?? "";
    // Order items: from "orderDetails/items", expect a list.
    List items = order["orderDetails"]?["items"] ?? [];

    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Order ID: $orderId",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Restaurant Rating: $restaurantRating"),
            Text("Restaurant Review: $restaurantReview"),
            const SizedBox(height: 8),
            Text("Driver: $driverName"),
            if (driver != null) ...[
              Text("Driver Phone: $driverPhone"),
              Text("Driver Assigned On: $driverAssigned"),
            ],
            const SizedBox(height: 8),
            Text("Status: $status"),
            const SizedBox(height: 8),
            Text("Placed: $placed"),
            Text("Delivered: $delivered"),
            const SizedBox(height: 8),
            const Text("Order Items:", style: TextStyle(fontWeight: FontWeight.bold)),
            for (var item in items)
              Text("- ${item["foodId"] ?? "Unknown"} "
                  "(${item["foodDescription"] ?? ""}) - \$${item["foodPrice"] ?? "0"} x ${item["quantity"] ?? "0"}"),
          ],
        ),
      ),
    );
  }
}


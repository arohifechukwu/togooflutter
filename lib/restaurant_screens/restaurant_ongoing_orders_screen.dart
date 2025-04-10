import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class RestaurantOngoingOrdersScreen extends StatefulWidget {
  const RestaurantOngoingOrdersScreen({Key? key}) : super(key: key);

  @override
  State<RestaurantOngoingOrdersScreen> createState() => _RestaurantOngoingOrdersScreenState();
}

class _RestaurantOngoingOrdersScreenState extends State<RestaurantOngoingOrdersScreen> {
  final DatabaseReference ordersRef = FirebaseDatabase.instance.ref("orders");
  final DatabaseReference driversRef = FirebaseDatabase.instance.ref("driver");
  List<Map<String, dynamic>> allOrders = [];
  List<Map<String, dynamic>> displayedOrders = [];
  String restaurantId = FirebaseAuth.instance.currentUser!.uid;
  int availableDriverCount = 0;
  String filterBy = "Order ID";
  String query = "";

  @override
  void initState() {
    super.initState();
    fetchAvailableDriverCount();
    loadOngoingOrders();
  }

  void fetchAvailableDriverCount() {
    driversRef.onValue.listen((event) {
      int count = 0;
      final data = event.snapshot.value;
      if (data is Map) {
        data.forEach((key, value) {
          if (value is Map && value['availability'] == 'available') {
            count++;
          }
        });
      }
      setState(() {
        availableDriverCount = count;
      });
    });
  }

  void loadOngoingOrders() {
    DatabaseReference restaurantOrdersRef = FirebaseDatabase.instance.ref("ordersByRestaurant/$restaurantId");

    restaurantOrdersRef.onValue.listen((event) {
      final orders = <Map<String, dynamic>>[];
      if (event.snapshot.exists) {
        for (final child in event.snapshot.children) {
          final orderId = child.key;
          ordersRef.child(orderId!).onValue.listen((orderSnap) {
            final data = orderSnap.snapshot.value;
            if (data is Map) {
              final status = data['status'];
              if (status != 'declined' && status != 'delivered') {
                final order = Map<String, dynamic>.from(data);
                order['orderId'] = orderId;
                setState(() {
                  allOrders.removeWhere((e) => e['orderId'] == orderId);
                  allOrders.add(order);
                  applyFilter();
                });
              } else {
                setState(() {
                  allOrders.removeWhere((e) => e['orderId'] == orderId);
                  applyFilter();
                });
              }
            }
          });
        }
      }
    });
  }

  void applyFilter() {
    setState(() {
      displayedOrders = allOrders.where((order) {
        String field = "";
        switch (filterBy) {
          case "Order ID":
            field = order['orderId'] ?? "";
            break;
          case "Customer":
            field = order['customer']?['name'] ?? "";
            break;
          case "Status":
            field = order['status'] ?? "";
            break;
          case "Timestamp":
            field = order['timestamps']?['restaurantAccepted'] ?? "";
            break;
        }
        return field.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  void updateOrderStatus(String orderId, String newStatus) async {
    final now = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(DateTime.now());
    final updates = {
      'status': newStatus,
      'timestamps/${newStatus == "preparing" ? "preparing" : "readyForPickup"}': now,
    };

    await ordersRef.child(orderId).update(updates);
    await ordersRef.child(orderId).child("updateLogs").push().set({
      'timestamp': now,
      'status': newStatus,
      'note': 'Status updated to $newStatus by restaurant.'
    });
  }

  Widget buildOrderCard(Map<String, dynamic> order) {
    final orderId = order['orderId'] ?? "";
    final customerName = order['customer']?['name'] ?? "Unknown";
    final status = order['status'] ?? "";
    final driverName = order['driver']?['name'];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Order: $orderId\nCustomer: $customerName\nStatus: $status"),
            const SizedBox(height: 8),
            Text(driverName != null
                ? "Driver: $driverName"
                : "Driver: $availableDriverCount drivers available"),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (status == "accepted" || status == "preparing")
                  ElevatedButton(
                    onPressed: status == "accepted"
                        ? () => updateOrderStatus(orderId, "preparing")
                        : null,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    child: const Text("Mark as Preparing", style: TextStyle(color: Colors.black)),
                  ),
                const SizedBox(width: 10),
                if (status == "accepted" || status == "preparing" || status == "ready")
                  ElevatedButton(
                    onPressed: status != "ready"
                        ? () => updateOrderStatus(orderId, "ready")
                        : null,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    child: const Text("Ready for Pickup", style: TextStyle(color: Colors.black)),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ongoing Orders"),
        backgroundColor: Colors.orange, // 🟧 Set title bar background to orange
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                DropdownButton<String>(
                  value: filterBy,
                  items: ["Order ID", "Customer", "Status", "Timestamp"]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) {
                    setState(() => filterBy = val!);
                    applyFilter();
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    onChanged: (val) {
                      query = val;
                      applyFilter();
                    },
                    decoration: const InputDecoration(hintText: "Search..."),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: displayedOrders.length,
              itemBuilder: (context, index) {
                return buildOrderCard(displayedOrders[index]);
              },
            ),
          )
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../driver_screens/driver_orders.dart';
import '../driver_screens/driver_bottom_navigation_menu.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({Key? key}) : super(key: key);

  @override
  _DriverHomeScreenState createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final String driverId = FirebaseAuth.instance.currentUser!.uid;
  List<Map<String, dynamic>> notifications = [];

  // ✅ Move makeLabel here
  Widget makeLabel(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(text, style: const TextStyle(fontSize: 14)),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadDriverDetails();
  }


  void _loadDriverDetails() async {
    final snapshot = await _dbRef.child("driver").child(driverId).get();
    if (snapshot.exists) {
      final availability = snapshot.child("availability").value.toString();
      if (availability.toLowerCase() == "available") {
        _listenForNotifications();
      } else {
        _showOfflineMessage();
      }
    }
  }

  void _showOfflineMessage() {
    setState(() => notifications = []);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("You're currently offline. Update your availability to receive notifications.")),
    );
  }

  void _listenForNotifications() async {
    _dbRef.child("driver").child(driverId).child("notifications").onValue.listen((event) async {
      final data = event.snapshot.value;
      if (data != null && data is Map) {
        List<Map<String, dynamic>> tempList = [];
        final Map<String, dynamic> rawMap = Map<String, dynamic>.from(data);

        for (var entry in rawMap.entries) {
          final notifKey = entry.key;
          final notifValue = Map<String, dynamic>.from(entry.value);

          final orderId = notifValue['orderId'];
          if (orderId == null) continue;

          final orderSnapshot = await _dbRef.child("orders").child(orderId).get();
          if (!orderSnapshot.exists) continue;

          final orderData = Map<String, dynamic>.from(orderSnapshot.value as Map);
          final driverAssigned = orderData['timestamps']?['driverAssigned']?.toString().toLowerCase() ?? "";

          if (driverAssigned != "pending") continue;

          notifValue['orderId'] = orderId;
          notifValue['customerName'] = orderData['customer']?['name'] ?? 'Unknown';
          notifValue['customer'] = orderData['customer'] ?? {};
          notifValue['restaurant'] = orderData['restaurant'] ?? {};
          notifValue['payment'] = orderData['payment'] ?? {};
          notifValue['orderDetails'] = orderData['orderDetails'] ?? {};

          tempList.add({...notifValue, 'notifKey': notifKey});
        }

        setState(() => notifications = tempList);
      } else {
        setState(() => notifications = []);
      }
    });
  }

  void _deleteNotification(String notifKey) async {
    await _dbRef.child("driver").child(driverId).child("notifications").child(notifKey).remove();
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    List<Widget> orderDetailsWidgets = [];
    final rawItems = order['orderDetails']?['items'];

    if (rawItems != null) {
      List<Map<String, dynamic>> items = [];
      if (rawItems is List) {
        items = rawItems.map((e) => Map<String, dynamic>.from(e)).toList();
      } else if (rawItems is Map) {
        items = rawItems.values.map((e) => Map<String, dynamic>.from(e)).toList();
      }

      orderDetailsWidgets = items.map((item) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80,
              height: 80,
              margin: const EdgeInsets.only(right: 12, bottom: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade300,
                image: DecorationImage(
                  image: NetworkImage(item['foodImage'] ?? ""),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: Text(
                "${item['foodId'] ?? 'Item'}\n${item['foodDescription'] ?? ''}\nQty: ${item['quantity'] ?? 1} — \$${item['foodPrice'] ?? '0'}",
                style: const TextStyle(fontSize: 14),
              ),
            )
          ],
        );
      }).toList();
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Order ID: ${order['orderId']}", style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("Status: ${order['status'] ?? 'N/A'}"),
              Text("👤 Customer: ${order['customerName'] ?? 'N/A'}"),
              Text("📍 Customer Address: ${order['customer']?['address'] ?? 'N/A'}"),
              Text("🏪 Restaurant: ${order['restaurant']?['name'] ?? 'N/A'}"),
              Text("📍 Restaurant Address: ${order['restaurant']?['address'] ?? 'N/A'}"),
              Text("💳 Payment Method: ${order['payment']?['method'] ?? 'N/A'}"),
              Text("Tips: \$${order['payment']?['tips'] ?? '0'}"),
              Text("Subtotal: \$${order['payment']?['subtotalBeforeTax'] ?? '0'}"),
              Text("Delivery Fee: \$${order['payment']?['deliveryFare'] ?? '0'}"),
              Text("Total: \$${order['payment']?['total'] ?? '0'}"),
              const SizedBox(height: 12),
              const Text("Items:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...orderDetailsWidgets,
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _deleteNotification(order['notifKey']),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("Delete Notification", style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Driver Notifications"),
        backgroundColor: const Color(0xFFE37D2B),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DriverOrdersScreen()),
              );
            },
          ),
        ],
      ),
      body: notifications.isEmpty
          ? const Center(child: Text("No notifications"))
          : ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text("Order ID: ${notification['orderId']}"),
              subtitle: Text("Customer: ${notification['customerName'] ?? 'N/A'}"),
              onTap: () => _showOrderDetails(notification),
            ),
          );
        },
      ),
      bottomNavigationBar: const DriverBottomNavigationMenu(currentIndex: 0),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../driver_screens/driver_reports.dart';
import '../driver_screens/driver_account.dart';
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

  @override
  void initState() {
    super.initState();
    _loadDriverDetails();
    _listenForNotifications();
  }

  // Load driver details to check if the driver is available
  void _loadDriverDetails() {
    _dbRef.child("driver").child(driverId).get().then((snapshot) {
      if (snapshot.exists) {
        String driverAvailability = snapshot.child("availability").value.toString();
        if (driverAvailability != "available") {
          _showOfflineMessage();
        }
      }
    });
  }

  void _listenForNotifications() {
    _dbRef.child("driver").child(driverId).child("notifications").onValue.listen((event) {
      final notificationsData = event.snapshot.value;

      if (notificationsData != null && notificationsData is Map) {
        List<Map<String, dynamic>> newNotifications = [];
        Map<String, dynamic> notificationsMap = Map<String, dynamic>.from(notificationsData);

        notificationsMap.forEach((key, value) {
          if (value != null) {
            final notification = Map<String, dynamic>.from(value);

            // Ensure that 'status' and 'customer' fields are handled safely
            String status = notification['status'] ?? '';
            Map<String, dynamic>? customer = notification['customer'] as Map<String, dynamic>?;
            String customerName = customer != null ? (customer['name'] ?? 'Unknown') : 'Unknown';

            // Skip notifications with status "order accepted"
            if (status.isEmpty || status.toLowerCase() == 'order accepted') {
              return; // Skip this notification
            }

            // Add orderId and customerName to the notification map
            notification['orderId'] = key;
            notification['customerName'] = customerName; // Store customerName for safe UI access
            newNotifications.add(notification);
          }
        });

        setState(() {
          notifications = newNotifications;
        });
      } else {
        setState(() {
          notifications = []; // No notifications
        });
      }
    });
  }

  // Display no orders message
  void _showOfflineMessage() {
    setState(() {
      notifications = [];
    });
  }

  // Display individual order details (Notifications)
  void _showOrderDetails(Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Order ID: ${order['orderId']}", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Status: ${order['status']}"),
              Text("Customer: ${order['customerName']}"), // Use pre-processed customerName
              Text("Customer Address: ${order['customer'] != null ? order['customer']['address'] ?? 'N/A' : 'N/A'}"),
              Text("Restaurant: ${order['restaurant'] != null ? order['restaurant']['name'] ?? 'N/A' : 'N/A'}"),
              SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Driver Notifications"),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DriverOrdersScreen()),
              );
            },
          ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(child: Text("No notifications"))
          : ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              title: Text("Order ID: ${notification['orderId']}"),
              subtitle: Text("Customer: ${notification['customerName']}"), // Use pre-processed customerName
              onTap: () => _showOrderDetails(notification),
            ),
          );
        },
      ),
      bottomNavigationBar: DriverBottomNavigationMenu(
        currentIndex: 0, // Ensure the 'Notifications' tab is selected
        context: context,
      ),
    );
  }
}
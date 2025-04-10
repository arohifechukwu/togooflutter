import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'driver_delivery.dart'; // Ensure you create a screen for the driver's delivery journey
import '../driver_home.dart'; // For handling driver notifications
import 'driver_reports.dart'; // For reports if necessary
import 'driver_account.dart'; // For the driver account screen
import 'driver_bottom_navigation_menu.dart'; // Use centralized bottom navigation menu

class DriverOrdersScreen extends StatefulWidget {
  const DriverOrdersScreen({Key? key}) : super(key: key);

  @override
  _DriverOrdersScreenState createState() => _DriverOrdersScreenState();
}

class _DriverOrdersScreenState extends State<DriverOrdersScreen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final String driverId = FirebaseAuth.instance.currentUser!.uid;
  List<Map<String, dynamic>> availableOrders = [];

  bool isDriverAvailable = false;
  bool hasCheckedAvailability = false;

  @override
  void initState() {
    super.initState();
    _checkDriverAvailabilityAndLoadOrders();
    _loadDriverDetails();
    _loadAvailableOrders();

  }


  void _checkDriverAvailabilityAndLoadOrders() async {
    final snapshot = await _dbRef.child("driver").child(driverId).get();
    if (snapshot.exists) {
      String driverAvailability = snapshot.child("availability").value.toString();
      if (driverAvailability == "available") {
        setState(() {
          isDriverAvailable = true;
          hasCheckedAvailability = true;
        });
        _loadAvailableOrders(); // Only fetch if available
      } else {
        setState(() {
          isDriverAvailable = false;
          hasCheckedAvailability = true;
          availableOrders = [];
        });
      }
    }
  }


  // Load driver details to check if the driver is available
  void _loadDriverDetails() {
    _dbRef.child("driver").child(driverId).get().then((snapshot) {
      if (snapshot.exists) {
        // Cast the value to a String.
        String driverAvailability = snapshot.child("availability").value.toString();
        if (driverAvailability != "available") {
          _showOfflineMessage();
        }
      }
    });
  }

  // Load available orders from Firebase
  void _loadAvailableOrders() {
    _dbRef.child("orders").orderByChild("status").equalTo("ready").onValue.listen((event) {
      final ordersData = event.snapshot.value;

      if (ordersData != null && ordersData is Map) {
        List<Map<String, dynamic>> orders = [];
        Map<String, dynamic> ordersMap = Map<String, dynamic>.from(ordersData);

        ordersMap.forEach((key, value) {
          if (value['driver'] == null) { // If no driver is assigned
            final order = Map<String, dynamic>.from(value);
            order['orderId'] = key;
            orders.add(order);
          }
        });

        setState(() {
          availableOrders = orders;
        });
      }
    });
  }

  // Display no orders message
  void _showOfflineMessage() {
    setState(() {
      availableOrders = [];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("You're currently offline. Update your availability to view your orders."),
      ),
    );
  }

  // Display individual order details
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
              Text("Customer: ${order['customer']['name']}"),
              Text("Customer Address: ${order['customer']['address']}"),
              Text("Restaurant: ${order['restaurant']['name']}"),
              Text("Estimated Delivery Time: Not Assigned"),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _acceptOrder(order),
                    child: Text("Accept", style: TextStyle(color: Colors.black)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                  ElevatedButton(
                    onPressed: () => _declineOrder(order),
                    child: Text("Decline", style: TextStyle(color: Colors.black)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }



  void _acceptOrder(Map<String, dynamic> order) async {
    final driverSnapshot = await _dbRef.child("driver").child(driverId).get();

    if (driverSnapshot.exists) {
      final driverData = Map<String, dynamic>.from(driverSnapshot.value as Map);
      final String driverName = driverData["name"] ?? "Unnamed";
      final String driverPhone = driverData["phone"] ?? "N/A";

      // Update order with driver info
      await _dbRef.child("orders").child(order['orderId']).update({
        'status': 'out for delivery',
        'driver': {
          'id': driverId,
          'name': driverName,
          'phone': driverPhone,
        },
      });

      // Update ordersByDriver node
      await _dbRef
          .child("ordersByDriver")
          .child(driverId)
          .child(order['orderId'])
          .set(true);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DriverDeliveryScreen(orderId: order['orderId']),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Could not retrieve driver info.")),
      );
    }
  }


  // Decline the order
  void _declineOrder(Map<String, dynamic> order) {
    _dbRef.child("orders").child(order['orderId']).update({
      'status': 'declined',
    }).then((_) {
      setState(() {
        availableOrders.removeWhere((item) => item['orderId'] == order['orderId']);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Available Orders",),
        backgroundColor: const Color(0xFFE37D2B),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DriverHomeScreen()),
              );
            },
          ),
        ],
      ),
      body: hasCheckedAvailability
          ? isDriverAvailable
          ? (availableOrders.isEmpty
          ? Center(child: Text("No available orders at the moment."))
          : ListView.builder(
        itemCount: availableOrders.length,
        itemBuilder: (context, index) {
          final order = availableOrders[index];
          return Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              title: Text("Order ID: ${order['orderId']}"),
              subtitle: Text("Customer: ${order['customer']['name']}"),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () => _showOrderDetails(order),
              ),
            ),
          );
        },
      ))
          : Center(
        child: Text(
          "You're currently offline. Update your availability to view your orders.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
      )
          : const Center(child: CircularProgressIndicator()),
      // Use the centralized custom bottom navigation menu widget instead of inline code
      bottomNavigationBar: DriverBottomNavigationMenu(
        currentIndex: 1, // Set to 'Orders' tab
      ),
    );
  }
}
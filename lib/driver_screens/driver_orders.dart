// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:cached_network_image/cached_network_image.dart';
//
// import 'driver_delivery.dart'; // Ensure you create a screen for the driver's delivery journey
// import '../driver_home.dart'; // For handling driver notifications
// import 'driver_reports.dart'; // For reports if necessary
// import 'driver_account.dart'; // For the driver account screen
//
// class DriverOrdersScreen extends StatefulWidget {
//   const DriverOrdersScreen({Key? key}) : super(key: key);
//
//   @override
//   _DriverOrdersScreenState createState() => _DriverOrdersScreenState();
// }
//
// class _DriverOrdersScreenState extends State<DriverOrdersScreen> {
//   final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
//   final String driverId = FirebaseAuth.instance.currentUser!.uid;
//   List<Map<String, dynamic>> availableOrders = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _loadDriverDetails();
//     _loadAvailableOrders();
//   }
//
//   // Load driver details to check if the driver is available
//   void _loadDriverDetails() {
//     _dbRef.child("driver").child(driverId).get().then((snapshot) {
//       if (snapshot.exists) {
//         // Make sure to cast the value to a String.
//         String driverAvailability = snapshot.child("availability").value.toString();
//         if (driverAvailability != "available") {
//           _showOfflineMessage();
//         }
//       }
//     });
//   }
//
//   // Load available orders from Firebase
//   void _loadAvailableOrders() {
//     _dbRef.child("orders").orderByChild("status").equalTo("ready").onValue.listen((event) {
//       final ordersData = event.snapshot.value;
//
//       // Check if the ordersData is not null and is a Map
//       if (ordersData != null && ordersData is Map) {
//         List<Map<String, dynamic>> orders = [];
//
//         // Cast the ordersData to a Map<String, dynamic>
//         Map<String, dynamic> ordersMap = Map<String, dynamic>.from(ordersData);
//
//         ordersMap.forEach((key, value) {
//           if (value['driver'] == null) { // If the order doesn't have a driver assigned
//             final order = Map<String, dynamic>.from(value);
//             order['orderId'] = key;
//             orders.add(order);
//           }
//         });
//
//         setState(() {
//           availableOrders = orders;
//         });
//       }
//     });
//   }
//   // Display no orders message
//   void _showOfflineMessage() {
//     setState(() {
//       availableOrders = [];
//     });
//   }
//
//   // Display individual order details
//   void _showOrderDetails(Map<String, dynamic> order) {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) {
//         return Container(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text("Order ID: ${order['orderId']}", style: TextStyle(fontWeight: FontWeight.bold)),
//               Text("Status: ${order['status']}"),
//               Text("Customer: ${order['customer']['name']}"),
//               Text("Customer Address: ${order['customer']['address']}"),
//               Text("Restaurant: ${order['restaurant']['name']}"),
//               Text("Estimated Delivery Time: Not Assigned"),
//               // You can add more details here...
//               SizedBox(height: 16),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   ElevatedButton(
//                     onPressed: () => _acceptOrder(order),
//                     child: Text("Accept"),
//                     style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//                   ),
//                   ElevatedButton(
//                     onPressed: () => _declineOrder(order),
//                     child: Text("Decline"),
//                     style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   // Accept the order
//   void _acceptOrder(Map<String, dynamic> order) {
//     _dbRef.child("orders").child(order['orderId']).update({
//       'status': 'out for delivery',
//       'driver': {
//         'id': driverId,
//         'name': 'Driver Name', // Retrieve driver name if available
//         'phone': 'Driver Phone', // Retrieve driver phone if available
//       },
//     }).then((_) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => DriverDeliveryScreen(orderId: order['orderId'])),
//       );
//     });
//   }
//
//   // Decline the order
//   void _declineOrder(Map<String, dynamic> order) {
//     _dbRef.child("orders").child(order['orderId']).update({
//       'status': 'declined',
//     }).then((_) {
//       setState(() {
//         availableOrders.removeWhere((item) => item['orderId'] == order['orderId']);
//       });
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Available Orders"),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.notifications),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => DriverHomeScreen()),
//               );
//             },
//           ),
//         ],
//       ),
//       body: availableOrders.isEmpty
//           ? Center(child: Text("No available orders"))
//           : ListView.builder(
//         itemCount: availableOrders.length,
//         itemBuilder: (context, index) {
//           final order = availableOrders[index];
//           return Card(
//             margin: EdgeInsets.all(8),
//             child: ListTile(
//               contentPadding: EdgeInsets.all(16),
//               title: Text("Order ID: ${order['orderId']}"),
//               subtitle: Text("Customer: ${order['customer']['name']}"),
//               trailing: IconButton(
//                 icon: Icon(Icons.edit),
//                 onPressed: () => _showOrderDetails(order),
//               ),
//             ),
//           );
//         },
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.list),
//             label: 'Orders',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.notifications),
//             label: 'Notifications',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.account_circle),
//             label: 'Account',
//           ),
//         ],
//         onTap: (index) {
//           if (index == 0) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (_) => DriverOrdersScreen()),
//             );
//           } else if (index == 1) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => DriverHomeScreen()),
//             );
//           } else if (index == 2) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => DriverAccountScreen()),
//             );
//           }
//         },
//       ),
//     );
//   }
// }





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

  @override
  void initState() {
    super.initState();
    _loadDriverDetails();
    _loadAvailableOrders();
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
                    child: Text("Accept"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                  ElevatedButton(
                    onPressed: () => _declineOrder(order),
                    child: Text("Decline"),
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

  // Accept the order
  void _acceptOrder(Map<String, dynamic> order) {
    _dbRef.child("orders").child(order['orderId']).update({
      'status': 'out for delivery',
      'driver': {
        'id': driverId,
        'name': 'Driver Name', // Retrieve actual driver name if available
        'phone': 'Driver Phone', // Retrieve actual driver phone if available
      },
    }).then((_) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DriverDeliveryScreen(orderId: order['orderId'])),
      );
    });
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
        title: Text("Available Orders"),
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
      body: availableOrders.isEmpty
          ? Center(child: Text("No available orders"))
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
      ),
      // Use the centralized custom bottom navigation menu widget instead of inline code
      bottomNavigationBar: DriverBottomNavigationMenu(
        currentIndex: 1, // Set to 'Orders' tab
        context: context,
      ),
    );
  }
}
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../widgets/driver_info_tile.dart';      // Your custom tile for driver info
// import '../widgets/rating_dialog_tile.dart';     // Your custom tile for rating dialog
//
// class NotificationsScreen extends StatefulWidget {
//   const NotificationsScreen({Key? key}) : super(key: key);
//
//   @override
//   _NotificationsScreenState createState() => _NotificationsScreenState();
// }
//
// class _NotificationsScreenState extends State<NotificationsScreen> {
//   // Reference to ordersByCustomer node for current user.
//   late DatabaseReference ordersRef;
//   final List<Widget> notificationsWidgets = [];
//   final DateFormat inputFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
//   final DateFormat dateOnlyFormat = DateFormat("yyyy-MM-dd");
//
//   @override
//   void initState() {
//     super.initState();
//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser != null) {
//       ordersRef = FirebaseDatabase.instance
//           .ref("ordersByCustomer")
//           .child(currentUser.uid);
//       listenForOrderUpdates();
//     }
//   }
//
//   void listenForOrderUpdates() {
//     ordersRef.onValue.listen((event) {
//       setState(() {
//         notificationsWidgets.clear();
//       });
//       DataSnapshot snapshot = event.snapshot;
//       if (!snapshot.exists) {
//         showMessage("No orders yet.");
//         return;
//       }
//       for (DataSnapshot orderSnap in snapshot.children) {
//         String? orderId = orderSnap.key;
//         if (orderId != null) {
//           loadOrderNotifications(orderId);
//         }
//       }
//     }, onError: (error) {
//       showMessage("Failed to load your orders.");
//     });
//   }
//
//   Future<void> loadOrderNotifications(String orderId) async {
//     DatabaseReference orderRef =
//     FirebaseDatabase.instance.ref("orders").child(orderId);
//     DataSnapshot snapshot = await orderRef.get();
//     if (!snapshot.exists) return;
//
//     // Extract basic order info.
//     String? restaurantId =
//     snapshot.child("restaurant/id").value as String?;
//     String? driverId = snapshot.child("driver/id").value as String?;
//     String? orderStatus = snapshot.child("status").value as String?;
//     String estimatedTime = snapshot.child("estimatedDeliveryTime").value as String? ?? "";
//
//     // Create a Column to hold the order notifications.
//     List<Widget> orderChildren = [];
//     orderChildren.add(Text(
//       "Order ID: $orderId",
//       style: const TextStyle(
//           fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
//     ));
//
//     // Process updateLogs: group by date.
//     DataSnapshot logsSnap = snapshot.child("updateLogs");
//     Map<String, List<DataSnapshot>> groupedLogs = {};
//     for (DataSnapshot logSnap in logsSnap.children) {
//       String? timestamp = logSnap.child("timestamp").value as String?;
//       if (timestamp != null) {
//         try {
//           DateTime parsedDate = inputFormat.parse(timestamp);
//           String dateKey = dateOnlyFormat.format(parsedDate);
//           if (!groupedLogs.containsKey(dateKey)) {
//             groupedLogs[dateKey] = [];
//           }
//           groupedLogs[dateKey]!.add(logSnap);
//         } catch (e) {
//           debugPrint("Timestamp parse error: $e");
//         }
//       }
//     }
//     // Sort logs inside each date group in descending order.
//     for (var logList in groupedLogs.values) {
//       logList.sort((a, b) {
//         try {
//           DateTime dateA = inputFormat.parse(a.child("timestamp").value as String);
//           DateTime dateB = inputFormat.parse(b.child("timestamp").value as String);
//           return dateB.compareTo(dateA);
//         } catch (e) {
//           return 0;
//         }
//       });
//     }
//     // Sort the group keys descending.
//     List<String> sortedDates = groupedLogs.keys.toList()
//       ..sort((a, b) => b.compareTo(a));
//     // Build widgets for each group.
//     for (String dateKey in sortedDates) {
//       orderChildren.add(Padding(
//         padding: const EdgeInsets.only(top: 8),
//         child: Text("📅 $dateKey",
//             style: const TextStyle(fontSize: 15, color: Colors.blue)),
//       ));
//       for (DataSnapshot log in groupedLogs[dateKey]!) {
//         String? status = log.child("status").value as String?;
//         String? note = log.child("note").value as String?;
//         String? timestamp = log.child("timestamp").value as String?;
//         orderChildren.add(Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8),
//           child: Text.rich(
//             TextSpan(
//               children: [
//                 TextSpan(
//                   text: "$status: ",
//                   style: const TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 TextSpan(text: note ?? ""),
//                 const TextSpan(text: "\n"),
//                 TextSpan(
//                   text: timestamp ?? "",
//                   style: const TextStyle(fontSize: 12, color: Colors.grey),
//                 ),
//               ],
//             ),
//           ),
//         ));
//       }
//     }
//
//     // Add a Rate button if order is delivered.
//     if (orderStatus != null && orderStatus.toLowerCase() == "delivered") {
//       orderChildren.add(ElevatedButton(
//         onPressed: () {
//           showRatingDialog(orderId, restaurantId, driverId);
//         },
//         child: const Text("Rate Your Order"),
//         style: ElevatedButton.styleFrom(
//             primary: Colors.blue, onPrimary: Colors.white),
//       ));
//     }
//
//     // Add a "Know Your Driver" button if a driver is assigned.
//     if (driverId != null && driverId.isNotEmpty) {
//       orderChildren.add(ElevatedButton(
//         onPressed: () {
//           showDriverInfoDialog(driverId, estimatedTime);
//         },
//         child: const Text("Know Your Driver"),
//         style: ElevatedButton.styleFrom(
//             primary: Colors.orange, onPrimary: Colors.white),
//       ));
//     }
//
//     Widget orderWidget = Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         boxShadow: const [
//           BoxShadow(color: Colors.black12, blurRadius: 4)
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: orderChildren,
//       ),
//     );
//
//     setState(() {
//       notificationsWidgets.insert(0, orderWidget);
//     });
//   }
//
//   void showDriverInfoDialog(String driverId, String estimatedTime) async {
//     final driverRef = FirebaseDatabase.instance.ref("driver").child(driverId);
//     final snapshot = await driverRef.get();
//
//     if (snapshot.exists) {
//       final data = snapshot.value as Map;
//
//       showDialog(
//         context: context,
//         builder: (context) {
//           return AlertDialog(
//             title: const Text("Your Delivery Driver"),
//             content: DriverInfoTile(
//               driverImageUrl: data['imageURL'] ?? '',
//               driverName: data['name'] ?? 'Unknown',
//               driverPhone: data['phone'] ?? 'N/A',
//               carImageUrl: data['carImageUrl'] ?? '',
//               carType: data['carType'] ?? '',
//               carModel: data['carModel'] ?? '',
//               licensePlate: data['plate'] ?? '',
//               estimatedTime: estimatedTime,
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text("Close"),
//               ),
//             ],
//           );
//         },
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Driver info not found")),
//       );
//     }
//   }
//
//   void showRatingDialog(String orderId, String? restaurantId, String? driverId) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text("Rate Your Order"),
//           content: RatingDialogTile(),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 // In a complete implementation, you would retrieve the ratings from the dialog's state.
//                 double restaurantRating = 5.0; // Replace with actual value from dialog
//                 double driverRating = 5.0; // Replace with actual value from dialog
//                 if (restaurantId != null) {
//                   updateRating("restaurant", restaurantId, restaurantRating);
//                 }
//                 if (driverId != null && driverId.isNotEmpty) {
//                   updateRating("driver", driverId, driverRating);
//                 }
//                 Navigator.pop(context);
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text("Thanks for your feedback!")),
//                 );
//               },
//               child: const Text("Submit"),
//             ),
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("Cancel"),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void updateRating(String role, String uid, double newRating, {required String customerComment}) {
//     final ratingRef = FirebaseDatabase.instance.ref(role).child(uid);
//
//     ratingRef.child("rating").runTransaction((currentData) {
//       double? existing = currentData.value as double?;
//       if (existing == null) {
//         currentData.value = newRating;
//       } else {
//         double average = (existing + newRating) / 2.0;
//         currentData.value = average;
//       }
//       return Transaction.success(currentData);
//     });
//
//     // Store the comment under a sub-node
//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser != null) {
//       final commentRef = ratingRef.child("comments").child(currentUser.uid);
//       commentRef.set({"comment": customerComment});
//     }
//   }
//
//   void showMessage(String message) {
//     setState(() {
//       notificationsWidgets.add(Padding(
//         padding: const EdgeInsets.all(30),
//         child: Center(child: Text(message, textAlign: TextAlign.center)),
//       ));
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Notifications"),
//         backgroundColor: Colors.blue,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.pushReplacementNamed(context, '/account');
//           },
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: notificationsWidgets,
//         ),
//       ),
//     );
//   }
// }




import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/driver_info_tile.dart';
import '../widgets/rating_dialog_tile.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late DatabaseReference ordersRef;
  final List<Widget> notificationsWidgets = [];
  final DateFormat inputFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
  final DateFormat dateOnlyFormat = DateFormat("yyyy-MM-dd");

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      ordersRef = FirebaseDatabase.instance.ref("ordersByCustomer").child(currentUser.uid);
      listenForOrderUpdates();
    }
  }

  void listenForOrderUpdates() {
    ordersRef.onValue.listen((event) {
      setState(() => notificationsWidgets.clear());
      final snapshot = event.snapshot;
      if (!snapshot.exists) {
        showMessage("No orders yet.");
        return;
      }
      for (final orderSnap in snapshot.children) {
        final orderId = orderSnap.key;
        if (orderId != null) loadOrderNotifications(orderId);
      }
    }, onError: (_) => showMessage("Failed to load your orders."));
  }

  Future<void> loadOrderNotifications(String orderId) async {
    final orderRef = FirebaseDatabase.instance.ref("orders").child(orderId);
    final snapshot = await orderRef.get();
    if (!snapshot.exists) return;

    final restaurantId = snapshot.child("restaurant/id").value as String?;
    final driverId = snapshot.child("driver/id").value as String?;
    final orderStatus = snapshot.child("status").value as String?;
    final estimatedTime = snapshot.child("estimatedDeliveryTime").value as String? ?? "";

    final orderChildren = <Widget>[
      Text("Order ID: $orderId", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
    ];

    final logsSnap = snapshot.child("updateLogs");
    final groupedLogs = <String, List<DataSnapshot>>{};

    for (final logSnap in logsSnap.children) {
      final timestamp = logSnap.child("timestamp").value as String?;
      if (timestamp != null) {
        try {
          final parsedDate = inputFormat.parse(timestamp);
          final dateKey = dateOnlyFormat.format(parsedDate);
          groupedLogs.putIfAbsent(dateKey, () => []).add(logSnap);
        } catch (_) {}
      }
    }

    for (final logList in groupedLogs.values) {
      logList.sort((a, b) {
        try {
          final dateA = inputFormat.parse(a.child("timestamp").value as String);
          final dateB = inputFormat.parse(b.child("timestamp").value as String);
          return dateB.compareTo(dateA);
        } catch (_) {
          return 0;
        }
      });
    }

    final sortedDates = groupedLogs.keys.toList()..sort((a, b) => b.compareTo(a));
    for (final dateKey in sortedDates) {
      orderChildren.add(Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text("📅 $dateKey", style: const TextStyle(fontSize: 15, color: Colors.blue)),
      ));

      for (final log in groupedLogs[dateKey]!) {
        final status = log.child("status").value as String? ?? "";
        final note = log.child("note").value as String? ?? "";
        final timestamp = log.child("timestamp").value as String? ?? "";
        orderChildren.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text.rich(TextSpan(children: [
            TextSpan(text: "$status: ", style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: note),
            const TextSpan(text: "\n"),
            TextSpan(text: timestamp, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ])),
        ));
      }
    }

    if (orderStatus?.toLowerCase() == "delivered") {
      orderChildren.add(ElevatedButton(
        onPressed: () => showRatingDialog(orderId, restaurantId, driverId),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
        child: const Text("Rate Your Order", style: TextStyle(color: Colors.white)),
      ));
    }

    if (driverId != null && driverId.isNotEmpty) {
      orderChildren.add(ElevatedButton(
        onPressed: () => showDriverInfoDialog(driverId, estimatedTime),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
        child: const Text("Know Your Driver", style: TextStyle(color: Colors.white)),
      ));
    }

    final orderWidget = Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: orderChildren,
      ),
    );

    setState(() => notificationsWidgets.insert(0, orderWidget));
  }

  Future<void> showDriverInfoDialog(String driverId, String estimatedTime) async {
    final snapshot = await FirebaseDatabase.instance.ref("driver").child(driverId).get();
    if (!snapshot.exists) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Driver info not found")));
      return;
    }

    final data = snapshot.value as Map;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Your Delivery Driver"),
        content: DriverInfoTile(
          driverImageUrl: data['imageURL'] ?? '',
          driverName: data['name'] ?? 'Unknown',
          driverPhone: data['phone'] ?? 'N/A',
          carImageUrl: data['carPicture'] ?? '',
          carType: data['carBrand'] ?? '',
          carModel: data['carModel'] ?? '',
          licensePlate: data['licensePlate'] ?? '',
          estimatedTime: estimatedTime,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
        ],
      ),
    );
  }

  void showRatingDialog(String orderId, String? restaurantId, String? driverId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Rate Your Order"),
          content: RatingDialogTile(
            onSubmit: (restaurantRating, driverRating, restaurantComment, driverComment) {
              if (restaurantId != null) {
                updateRating(
                  "restaurant",
                  restaurantId,
                  restaurantRating,
                  customerComment: restaurantComment,
                );
              }
              if (driverId != null && driverId.isNotEmpty) {
                updateRating(
                  "driver",
                  driverId,
                  driverRating,
                  customerComment: driverComment,
                );
              }

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Thanks for your feedback!")),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }


  void updateRating(String role, String uid, double newRating, {required String customerComment}) {
    final ratingRef = FirebaseDatabase.instance.ref(role).child(uid);

    ratingRef.child("rating").runTransaction((value) {
      double average;

      if (value == null) {
        average = newRating;
      } else if (value is int) {
        average = (value.toDouble() + newRating) / 2.0;
      } else if (value is double) {
        average = (value + newRating) / 2.0;
      } else {
        average = newRating;
      }

      return Transaction.success(average);
    });

    // Save the customer comment under 'comments/<customerId>'
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final commentRef = ratingRef.child("comments").child(currentUser.uid);
      commentRef.set({"comment": customerComment});
    }
  }

  void showMessage(String message) {
    setState(() {
      notificationsWidgets.add(Padding(
        padding: const EdgeInsets.all(30),
        child: Center(child: Text(message, textAlign: TextAlign.center)),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, '/account'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: notificationsWidgets),
      ),
    );
  }
}
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/order_tile.dart';
import '../customer_bottom_navigation_menu.dart'; // bottom nav widget

/// A simple generic Pair class for sorting orders.
class Pair<F, S> {
  final F first;
  final S second;
  Pair(this.first, this.second);
}

class MyOrderScreen extends StatefulWidget {
  const MyOrderScreen({Key? key}) : super(key: key);

  @override
  _MyOrderScreenState createState() => _MyOrderScreenState();
}

class _MyOrderScreenState extends State<MyOrderScreen> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final DatabaseReference ordersRef = FirebaseDatabase.instance.ref("orders");
  List<Map<String, dynamic>> orderList = [];

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }


  Future<void> fetchOrders() async {
    try {
      // Query orders for the current user based on their UID under customer/id.
      final snapshot = await ordersRef.orderByChild("customer/id").equalTo(currentUserId).once();
      final List<Pair<String, int>> orderPairs = [];

      // Collect order IDs and their placement timestamps.
      for (DataSnapshot orderSnap in snapshot.snapshot.children) {
        final orderId = orderSnap.key;
        int placedMillis = 0;
        final millisObj = orderSnap.child("timestamps/placedMillis").value;
        if (millisObj != null) {
          placedMillis = int.tryParse(millisObj.toString()) ?? 0;
        }
        orderPairs.add(Pair(orderId ?? "", placedMillis));
      }

      // Sort orders by most recent first.
      orderPairs.sort((a, b) => b.second.compareTo(a.second));

      // Fetch the full order details for each ID.
      final results = await Future.wait(orderPairs.map((pair) async {
        final orderSnap = await ordersRef.child(pair.first).get();

        if (orderSnap.exists && orderSnap.value is Map<Object?, Object?>) {
          final rawMap = orderSnap.value as Map<Object?, Object?>;

          // Convert raw map to a properly typed Map<String, dynamic>
          final orderData = Map<String, dynamic>.from(
            rawMap.map((key, value) => MapEntry(key.toString(), value)),
          );

          orderData["orderId"] = pair.first; // Attach the order ID
          return orderData;
        }
        return null;
      }));

      // Filter and update UI
      setState(() {
        orderList = results.whereType<Map<String, dynamic>>().toList();
      });
    } catch (error) {
      // Error handling
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load orders")),
      );
      debugPrint("Error fetching orders: $error");
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Orders"),
        backgroundColor: Colors.deepOrange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: orderList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: fetchOrders,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orderList.length,
          itemBuilder: (context, index) {
            final orderData = orderList[index];
            return OrderTile(orderData: orderData);
          },
        ),
      ),
      // Bottom navigation bar (using your custom menu)
      bottomNavigationBar: CustomerBottomNavigationMenu(selectedIndex: 2),
    );
  }
}
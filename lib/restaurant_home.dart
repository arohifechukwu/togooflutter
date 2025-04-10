import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:togoo/restaurant_bottom_navigation_menu.dart';
import '../widgets/order_tile.dart';
import '../restaurant_screens/restaurant_ongoing_orders_screen.dart';

class RestaurantHomeScreen extends StatefulWidget {
  const RestaurantHomeScreen({Key? key}) : super(key: key);

  @override
  _RestaurantHomeScreenState createState() => _RestaurantHomeScreenState();
}

class _RestaurantHomeScreenState extends State<RestaurantHomeScreen> {
  final DatabaseReference ordersByRestaurantRef = FirebaseDatabase.instance.ref();
  final DatabaseReference ordersRef = FirebaseDatabase.instance.ref("orders");
  final String restaurantId = FirebaseAuth.instance.currentUser!.uid;
  List<String> orderIds = [];

  @override
  void initState() {
    super.initState();
    listenToOrders();
  }


  void listenToOrders() {
    DatabaseReference ref = FirebaseDatabase.instance.ref("ordersByRestaurant").child(restaurantId);
    ref.onValue.listen((DatabaseEvent event) async {
      final snapshot = event.snapshot;
      if (!snapshot.exists) {
        setState(() => orderIds = []);
        return;
      }

      Map<dynamic, dynamic>? ordersMap = snapshot.value as Map<dynamic, dynamic>?;
      if (ordersMap != null) {
        List<String> filteredIds = [];

        for (var key in ordersMap.keys) {
          final orderSnapshot = await ordersRef.child(key.toString()).get();
          if (orderSnapshot.exists) {
            final data = orderSnapshot.value as Map<Object?, Object?>;
            final status = (data["status"] ?? "").toString().toLowerCase();
            if (status == "placed") {
              filteredIds.add(key.toString());
            }
          }
        }

        setState(() => orderIds = filteredIds);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Orders"),
        backgroundColor: Colors.orange,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Orders",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RestaurantOngoingOrdersScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "View Ongoing Orders",
                    style: TextStyle(color: Colors.orange, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: orderIds.isEmpty
                  ? Center(
                child: Text(
                  "No available orders.",
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: orderIds.length,
                itemBuilder: (context, index) {
                  String orderId = orderIds[index];
                  return FutureBuilder<DataSnapshot>(
                    future: ordersRef.child(orderId).get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return const ListTile(title: Text("Order data not found."));
                      }
                      final rawData = snapshot.data!.value as Map<Object?, Object?>;
                      final orderDataMap = <String, dynamic>{};
                      rawData.forEach((key, value) {
                        orderDataMap[key.toString()] = value;
                      });
                      orderDataMap["orderId"] = orderId;
                      // Only display orders with status "placed".
                      final orderStatus =
                      (orderDataMap["status"] ?? "").toString().toLowerCase();
                      if (orderStatus != "placed") {
                        return const SizedBox.shrink();
                      }
                      // For restaurant view, pass isCustomerView: false.
                      return OrderTile(orderData: orderDataMap, isCustomerView: false);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: RestaurantBottomNavigationMenu(
        currentIndex: 0
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({Key? key}) : super(key: key);

  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  List<Map<String, dynamic>> orders = [];
  final DatabaseReference ordersRef = FirebaseDatabase.instance.ref("orders");

  @override
  void initState() {
    super.initState();
    fetchAllOrdersForAdmin();
  }

  /// Fetch all orders under the "orders" node.
  Future<void> fetchAllOrdersForAdmin() async {
    try {
      DataSnapshot snapshot = await ordersRef.get();
      List<Map<String, dynamic>> tempOrders = [];
      if (snapshot.value != null) {
        // Iterate over each order snapshot
        for (DataSnapshot orderSnap in snapshot.children) {
          String? orderId = orderSnap.key;
          if (orderId != null) {
            // Convert order data to a map
            Map<String, dynamic> orderData =
            Map<String, dynamic>.from(orderSnap.value as Map);
            orderData["orderId"] = orderId;

            // If a customer ID exists, fetch user details and add to the order map
            if (orderData.containsKey("customerId") &&
                orderData["customerId"] != null) {
              String customerId = orderData["customerId"];
              DataSnapshot userSnap = await FirebaseDatabase.instance
                  .ref("users")
                  .child(customerId)
                  .get();
              if (userSnap.value != null) {
                Map<String, dynamic> userData =
                Map<String, dynamic>.from(userSnap.value as Map);
                orderData["username"] = userData["username"];
                orderData["phone"] = userData["phone"];
              }
            }
            tempOrders.add(orderData);
          }
        }
      }
      setState(() {
        orders = tempOrders;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load orders.")),
      );
      debugPrint("Error fetching orders: $error");
    }
  }

  /// Builds an individual order card widget.
  Widget buildOrderCard(Map<String, dynamic> order) {
    final orderId = order["orderId"] ?? "N/A";
    List<Widget> widgets = [];

    // Order title label
    widgets.add(Text(
      "📅 Order ID: $orderId",
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ));

    // Display order items
    if (order["orderDetails"] != null &&
        order["orderDetails"]["items"] != null) {
      // Items may be stored as a List or a Map. We support both.
      List<dynamic> items = [];
      if (order["orderDetails"]["items"] is List) {
        items = order["orderDetails"]["items"];
      } else if (order["orderDetails"]["items"] is Map) {
        items = (order["orderDetails"]["items"] as Map).values.toList();
      }
      for (var item in items) {
        String foodDesc = item["foodDescription"]?.toString() ?? "";
        String foodImage = item["foodImage"]?.toString() ?? "";
        String quantity = item["quantity"]?.toString() ?? "";
        String price = item["foodPrice"]?.toString() ?? "";
        widgets.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Container(
                width: 100,
                height: 100,
                color: Colors.grey[300],
                child: foodImage.isNotEmpty
                    ? Image.network(foodImage, fit: BoxFit.cover)
                    : null,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  "$foodDesc\nQty: $quantity\nUnit Price: \$$price",
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ));
      }
    }

    // Payment status – style text based on status value
    String status = order["payment"]?["status"]?.toString() ?? "Unknown";
    Color statusColor;
    if (status.toLowerCase() == "delivered") {
      statusColor = Colors.green;
    } else if (status.toLowerCase() == "pending") {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.red;
    }
    widgets.add(Text("Status: $status",
        style: TextStyle(fontSize: 16, color: statusColor)));

    widgets.add(Text("Total: \$${order["payment"]?["total"]?.toString() ?? ""}"));
    widgets.add(Text(
        "Payment Method: ${order["payment"]?["method"]?.toString() ?? ""}"));
    widgets.add(Text("Placed At: ${order["timestamps"]?["placed"]?.toString() ?? ""}"));

    // Display customer details if they exist
    if (order.containsKey("username") && order.containsKey("phone")) {
      widgets.add(Text("👤 Customer: ${order["username"]}"));
      widgets.add(Text("📞 Phone: ${order["phone"]}"));
    }

    // Return a Card containing all views
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widgets,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Orders"),
      ),
      body: orders.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: fetchAllOrdersForAdmin,
        child: ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            return buildOrderCard(orders[index]);
          },
        ),
      ),
    );
  }
}

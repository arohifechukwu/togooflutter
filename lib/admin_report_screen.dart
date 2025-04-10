import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AdminReportScreen extends StatefulWidget {
  const AdminReportScreen({Key? key}) : super(key: key);

  @override
  _AdminReportScreenState createState() => _AdminReportScreenState();
}

class _AdminReportScreenState extends State<AdminReportScreen> {
  final DatabaseReference ordersRef = FirebaseDatabase.instance.ref("orders");
  List<Map<String, dynamic>> reportList = [];

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  /// Fetches all orders (reports) from the "orders" node.
  Future<void> fetchReports() async {
    try {
      final snapshot = await ordersRef.once();
      final List<Map<String, dynamic>> tempList = [];
      if (snapshot.snapshot.value != null) {
        final ordersMap = snapshot.snapshot.value as Map<dynamic, dynamic>;
        ordersMap.forEach((key, value) {
          if (value is Map) {
            // Convert keys to strings and add the orderId.
            final orderData = Map<String, dynamic>.from(
              value.map((k, v) => MapEntry(k.toString(), v)),
            );
            orderData["orderId"] = key.toString();
            tempList.add(orderData);
          }
        });
      }
      // Optionally sort the orders by the "placed" timestamp (if available).
      tempList.sort((a, b) {
        String aPlaced = a["timestamps"]?["placed"]?.toString() ?? "";
        String bPlaced = b["timestamps"]?["placed"]?.toString() ?? "";
        return bPlaced.compareTo(aPlaced);
      });
      setState(() {
        reportList = tempList;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load reports")),
      );
      debugPrint("Error fetching orders: $error");
    }
  }

  /// Opens a review dialog for the given order.
  void _showReviewDialog(Map<String, dynamic> order) {
    String reviewType = "driver";
    final TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Review Order"),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: commentController,
                    decoration: const InputDecoration(
                      labelText: "Comment",
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: reviewType,
                    isExpanded: true,
                    items: <String>["driver", "customer", "restaurant"]
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          reviewType = newValue;
                        });
                      }
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (commentController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter a comment")),
                  );
                  return;
                }
                // Create a new "orderReview" entry in Firebase with the UTC ISO8601 timestamp.
                final DatabaseReference reviewRef =
                FirebaseDatabase.instance.ref("orderReviews").push();
                await reviewRef.set({
                  "orderId": order["orderId"],
                  "comment": commentController.text.trim(),
                  "reviewType": reviewType,
                  "timestamp": DateTime.now().toUtc().toIso8601String(),
                });
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Review submitted successfully")),
                );
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  /// Builds an individual report card displaying comprehensive order details.
  Widget buildReportCard(Map<String, dynamic> order) {
    // Extract key order details
    String orderId = order["orderId"] ?? "N/A";
    String status = order["payment"]?["status"]?.toString() ?? "Unknown";
    String placed = order["timestamps"]?["placed"]?.toString() ?? "N/A";
    String delivered = order["timestamps"]?["delivered"]?.toString() ?? "N/A";
    String restaurantReview =
        order["restaurantReview"]?.toString() ?? "No review";
    String restaurantRating =
        order["restaurantRating"]?.toString() ?? "Not rated";

    // Driver details (if available)
    Map? driver = order["driver"];
    String driverName = driver?["name"] ?? "Not assigned";
    String driverPhone = driver?["phone"] ?? "N/A";

    // Order items: expecting a list under "orderDetails/items"
    List<dynamic> items = order["orderDetails"]?["items"] ?? [];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Order ID: $orderId",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text("Status: $status"),
            const SizedBox(height: 4),
            Text("Placed: $placed"),
            const SizedBox(height: 4),
            Text("Delivered: $delivered"),
            const SizedBox(height: 8),
            Text("Restaurant Rating: $restaurantRating"),
            Text("Restaurant Review: $restaurantReview"),
            const SizedBox(height: 8),
            Text("Driver: $driverName"),
            Text("Driver Phone: $driverPhone"),
            const SizedBox(height: 8),
            const Text("Order Items:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            ...items.map((item) {
              String foodId = item["foodId"]?.toString() ?? "Unknown";
              String foodDescription =
                  item["foodDescription"]?.toString() ?? "";
              String foodPrice = item["foodPrice"]?.toString() ?? "0";
              String quantity = item["quantity"]?.toString() ?? "0";
              return Text("- $foodId: $foodDescription - \$${foodPrice} x $quantity");
            }).toList(),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                _showReviewDialog(order);
              },
              child: const Text("Review"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Reports"),
        backgroundColor: Colors.deepOrange,
      ),
      body: reportList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: fetchReports,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reportList.length,
          itemBuilder: (context, index) {
            final order = reportList[index];
            return buildReportCard(order);
          },
        ),
      ),
    );
  }
}

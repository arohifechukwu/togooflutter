import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class OrderTile extends StatefulWidget {
  final Map<String, dynamic> orderData;
  final bool isCustomerView;

  const OrderTile({
    Key? key,
    required this.orderData,
    this.isCustomerView = false,
  }) : super(key: key);

  @override
  _OrderTileState createState() => _OrderTileState();
}

class _OrderTileState extends State<OrderTile> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  // Date formats similar to the Java code.
  final DateFormat inputFormat =
  DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", "en_US");
  final DateFormat dateOnlyFormat = DateFormat("yyyy-MM-dd", "en_US");
  // Group update logs by date.
  Map<String, List<Map<String, dynamic>>> groupedLogs = {};
  Map<String, dynamic>? restaurantInfo;
  Map<String, dynamic>? driverInfo;

  bool hasRated = false;

  @override
  void initState() {
    super.initState();
    groupUpdateLogs();
    if (widget.orderData["restaurant"]?["id"] != null) {
      fetchRestaurantInfo(widget.orderData["restaurant"]["id"]);
    }
    if (widget.orderData["driver"] != null &&
        widget.orderData["driver"] is Map &&
        widget.orderData["driver"]["id"] != null) {
      fetchDriverInfo(widget.orderData["driver"]["id"]);
    }
  }

  /// Group update logs by date. If no "placed" update exists, add one.
  void groupUpdateLogs() {
    final logsData = widget.orderData["updateLogs"];
    List<Map<String, dynamic>> logsList = [];
    if (logsData != null && logsData is Map) {
      logsData.forEach((key, value) {
        if (value is Map) {
          logsList.add((value as Map<Object?, Object?>)
              .map((k, v) => MapEntry(k.toString(), v)));
        }
      });
    }
    if (widget.orderData["timestamps"]?["placed"] != null) {
      String placedTimestamp = widget.orderData["timestamps"]["placed"];
      bool hasPlaced = logsList.any(
              (log) => (log["status"]?.toString().toLowerCase() ?? "") == "placed");
      if (!hasPlaced) {
        logsList.add({
          "timestamp": placedTimestamp,
          "status": "placed",
          "note": "Order placed"
        });
      }
    }
    logsList.sort((a, b) {
      try {
        DateTime dateA = inputFormat.parse(a["timestamp"] ?? "");
        DateTime dateB = inputFormat.parse(b["timestamp"] ?? "");
        return dateB.compareTo(dateA);
      } catch (e) {
        return 0;
      }
    });
    Map<String, List<Map<String, dynamic>>> temp = {};
    for (var log in logsList) {
      try {
        DateTime dt = inputFormat.parse(log["timestamp"] ?? "");
        String dateStr = dateOnlyFormat.format(dt);
        temp.putIfAbsent(dateStr, () => []);
        temp[dateStr]!.add(log);
      } catch (e) {
        // Ignore invalid timestamps.
      }
    }
    final sortedKeys = temp.keys.toList()..sort((a, b) => b.compareTo(a));
    groupedLogs = {for (var k in sortedKeys) k: temp[k]!};
  }

  void fetchRestaurantInfo(String restaurantId) async {
    final snapshot =
    await _dbRef.child("restaurant").child(restaurantId).get();
    if (snapshot.exists) {
      setState(() {
        restaurantInfo = (snapshot.value as Map<Object?, Object?>)
            .map((k, v) => MapEntry(k.toString(), v));
      });
    }
  }

  void fetchDriverInfo(String driverId) async {
    final snapshot = await _dbRef.child("driver").child(driverId).get();
    if (snapshot.exists) {
      setState(() {
        driverInfo = (snapshot.value as Map<Object?, Object?>)
            .map((k, v) => MapEntry(k.toString(), v));
      });
    }
  }

  Widget makeLabel(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  Widget addDivider(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        "== $label ==",
        style: const TextStyle(fontSize: 16, color: Colors.blue),
      ),
    );
  }

  // --- Methods used exclusively in the restaurant view ---

  void updateOrderStatus(String newStatus) async {
    String now =
    DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", "en_US").format(DateTime.now().toUtc());
    Map<String, dynamic> updates = {"status": newStatus};
    if (newStatus == "accepted") {
      updates["timestamps/restaurantAccepted"] = now;
    } else if (newStatus == "declined") {
      updates["timestamps/restaurantDeclined"] = now;
    }
    await FirebaseDatabase.instance
        .ref("orders")
        .child(widget.orderData["orderId"])
        .update(updates);
    Map<String, dynamic> logEntry = {
      "timestamp": now,
      "status": newStatus,
      "note": "Status updated to $newStatus by restaurant."
    };
    await FirebaseDatabase.instance
        .ref("orders")
        .child(widget.orderData["orderId"])
        .child("updateLogs")
        .push()
        .set(logEntry);
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Order status updated to $newStatus")));
  }


  void notifyDrivers(Map<String, dynamic> customerData) async {
    Map<String, dynamic> notification = {
      "orderId": widget.orderData["orderId"],
      "customer": customerData, // ✅ Include the full customer map
      "status": "awaiting_driver", // 🔁 Optional: lowercase to match everywhere
    };

    final driverSnapshot = await FirebaseDatabase.instance.ref("driver").get();
    if (driverSnapshot.exists) {
      (driverSnapshot.value as Map<Object?, Object?>).forEach((key, value) {
        final driverData = (value as Map<Object?, Object?>)
            .map((k, v) => MapEntry(k.toString(), v));
        if ((driverData["availability"] ?? "").toString().toLowerCase() == "available") {
          FirebaseDatabase.instance
              .ref("driver")
              .child(key.toString())
              .child("notifications")
              .push()
              .set(notification);
        }
      });
    }
  }

  // --- Dialog functions for rating and dispute remain unchanged ---

  void showRatingDialog(String orderId, String restaurantId, String driverId) {
    final restaurantRatingController = TextEditingController();
    final driverRatingController = TextEditingController();
    final restaurantCommentController = TextEditingController();
    final driverCommentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Rate Your Order"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              const Text("Rate the Restaurant"),
              const SizedBox(height: 8),
              RatingBarWidget(controller: restaurantRatingController),
              const SizedBox(height: 8),
              TextField(
                controller: restaurantCommentController,
                decoration: const InputDecoration(
                  hintText: "Comment for restaurant",
                ),
              ),
              const SizedBox(height: 16),
              const Text("Rate the Driver"),
              const SizedBox(height: 8),
              RatingBarWidget(controller: driverRatingController),
              const SizedBox(height: 8),
              TextField(
                controller: driverCommentController,
                decoration: const InputDecoration(
                  hintText: "Comment for driver",
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () {
                String currentUserId = FirebaseAuth.instance.currentUser!.uid;
                double restRating =
                    double.tryParse(restaurantRatingController.text) ?? 0.0;
                double drvRating =
                    double.tryParse(driverRatingController.text) ?? 0.0;
                updateRatingWithComment("restaurant", restaurantId, currentUserId,
                    restRating, restaurantCommentController.text);
                updateRatingWithComment("driver", driverId, currentUserId, drvRating,
                    driverCommentController.text);
                setState(() => hasRated = true);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Thanks for your feedback!")));
              },
              child: const Text("Submit")),
        ],
      ),
    );
  }



  void updateRatingWithComment(String role, String uid, String customerId,
      double rating, String comment) {
    final ratingRef =
    _dbRef.child(role).child(uid).child("ratings").child(customerId);

    final String timestamp = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", "en_US")
        .format(DateTime.now().toUtc());

    Map<String, dynamic> data = {
      "value": rating,
      "comment": comment,
      "timestamp": timestamp,
    };
    ratingRef.set(data);
    updateAverageRating(role, uid);
  }

  void updateAverageRating(String role, String uid) {
    _dbRef.child(role).child(uid).child("ratings").once().then((event) {
      double sum = 0;
      int count = 0;
      final raw = event.snapshot.value;
      if (raw != null && raw is Map) {
        final ratingsData = Map<String, dynamic>.from(
          (raw as Map<Object?, Object?>).map((k, v) => MapEntry(k.toString(), v)),
        );
        ratingsData.forEach((key, value) {
          if (value is Map && value["value"] != null) {
            final rating = double.tryParse(value["value"].toString());
            if (rating != null) {
              sum += rating;
              count++;
            }
          }
        });
      }
      double avg = count == 0 ? 0 : sum / count;
      _dbRef.child(role).child(uid).child("rating").set(avg);
    });
  }

  // --- Display driver info using the provided driver ID (extracted from order data) ---
  void showDriverInfoDialog(String driverId, String eta) {
    if (driverId.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Driver ID is missing")));
      return;
    }
    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder(
          future:
          FirebaseDatabase.instance.ref("driver").child(driverId).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const AlertDialog(
                content: SizedBox(
                    height: 100,
                    child: Center(child: CircularProgressIndicator())),
              );
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const AlertDialog(
                title: Text("Driver Not Found"),
                content: Text("Could not load driver information."),
              );
            }
            final raw = snapshot.data!.value as Map<Object?, Object?>;
            final data = <String, dynamic>{};
            raw.forEach((key, value) {
              data[key.toString()] = value;
            });
            return AlertDialog(
              title: const Text("Your Delivery Driver"),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    data["imageURL"] != null &&
                        (data["imageURL"] as String).isNotEmpty
                        ? ClipOval(
                        child: Image.network(
                          data["imageURL"],
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ))
                        : const CircleAvatar(
                        radius: 50, child: Icon(Icons.person, size: 50)),
                    const SizedBox(height: 12),
                    Text("Name: ${data["name"] ?? "N/A"}"),
                    Text("Phone: ${data["phone"] ?? "N/A"}"),
                    Text("Vehicle: ${data["carBrand"] ?? ""} ${data["carModel"] ?? ""}"),
                    Text("Plate: ${data["licensePlate"] ?? "N/A"}"),
                    Text("ETA: $eta"),
                    const SizedBox(height: 12),
                    data["carPicture"] != null &&
                        (data["carPicture"] as String).isNotEmpty
                        ? Image.network(
                      data["carPicture"],
                      height: 120,
                      width: 200,
                      fit: BoxFit.cover,
                    )
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showDisputeDialog(String orderId) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Log A Complaint"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(hintText: "Dispute Title"),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descController,
                decoration: const InputDecoration(hintText: "Description"),
                maxLines: 3,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(hintText: "Reason"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              storeDispute(orderId, titleController.text.trim(),
                  descController.text.trim(), reasonController.text.trim(), null);
              Navigator.pop(context);
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text("Dispute submitted")));
            },
            child: const Text("Submit"),
          )
        ],
      ),
    );
  }

  void storeDispute(String orderId, String title, String desc, String reason, String? imageURL) {
    final disputeRef =
    _dbRef.child("orders").child(orderId).child("dispute");
    disputeRef.child("details").child("disputeTitle").set(title);
    disputeRef.child("details").child("description").set(desc);
    if (imageURL != null) {
      disputeRef.child("details").child("imageURL").set(imageURL);
    }
    disputeRef.child("reason").set(reason);
    disputeRef.child("status").set("pending");
    String timestamp = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", "en_US")
        .format(DateTime.now().toUtc());
    disputeRef.child("timestamp").set(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.orderData.isEmpty) return const SizedBox.shrink();
    final orderId = widget.orderData["orderId"] ?? "Unknown Order";
    final orderStatus =
    (widget.orderData["status"] ?? "").toString().toLowerCase();

    // Extract driver ID from order data.
    String driverIdFromOrder = "";
    if (widget.orderData["driver"] != null) {
      if (widget.orderData["driver"] is Map) {
        driverIdFromOrder = widget.orderData["driver"]["id"] ?? "";
      } else {
        driverIdFromOrder = widget.orderData["driver"].toString();
      }
    }
    final eta = widget.orderData["estimatedDeliveryTime"] ?? "N/A";

    List<Widget> buildOrderItems() {
      List<Widget> itemsWidget = [];
      if (widget.orderData["orderDetails"] != null &&
          widget.orderData["orderDetails"]["items"] != null) {
        final itemsData = widget.orderData["orderDetails"]["items"];
        List<Map<String, dynamic>> items = [];
        if (itemsData is List) {
          items = itemsData
              .map((item) => (item as Map<Object?, Object?>)
              .map((k, v) => MapEntry(k.toString(), v)))
              .toList();
        } else if (itemsData is Map) {
          items = (itemsData as Map<Object?, Object?>)
              .map((k, v) => MapEntry(k.toString(), v))
              .values
              .map((e) =>
              (e as Map<Object?, Object?>).map((k, v) => MapEntry(k.toString(), v)))
              .toList();
        }
        for (var item in items) {
          final foodId = item["foodId"] ?? "";
          final foodDesc = item["foodDescription"] ?? "";
          final foodImage = item["foodImage"] ?? "";
          final quantity = item["quantity"] ?? "1";
          final price = item["foodPrice"] ?? "0";
          itemsWidget.add(Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey.shade300,
                  child: (foodImage.toString().isNotEmpty)
                      ? CachedNetworkImage(
                    imageUrl: foodImage,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) =>
                    const Icon(Icons.image_not_supported),
                  )
                      : const Icon(Icons.image_not_supported),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                      "• $foodId\n$foodDesc\nQty: $quantity\nUnit Price: \$$price"),
                ),
              ],
            ),
          ));
        }
      }
      return itemsWidget;
    }

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: const EdgeInsets.only(bottom: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order header.
            Text("📄 Order ID: $orderId",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            // For customer view: show activity updates.
            // For restaurant view: show customer info.
            if (widget.isCustomerView)
              ...[
                addDivider("Activity Updates"),
                ...groupedLogs.entries.expand((entry) {
                  return [
                    Text("Date: ${entry.key}",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    ...entry.value.map((log) {
                      final status = log["status"] ?? "";
                      final note = log["note"] ?? "";
                      final ts = log["timestamp"] ?? "";
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(color: Colors.black),
                            children: [
                              TextSpan(
                                  text: "$status: ",
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(text: "$note\n"),
                              TextSpan(
                                  text: ts,
                                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                      );
                    })
                  ];
                }).toList(),
              ]
            else
              ...[
                // Restaurant view: show customer information.
                if (widget.orderData["customer"] != null &&
                    widget.orderData["customer"] is Map) ...[
                  makeLabel("👤 Customer: ${widget.orderData["customer"]["name"] ?? "N/A"}"),
                  makeLabel("📍 Address: ${widget.orderData["customer"]["address"] ?? "N/A"}"),
                  makeLabel("📞 Phone: ${widget.orderData["customer"]["phone"] ?? "N/A"}"),
                ],
              ],
            addDivider("Order Summary"),
            ...buildOrderItems(),
            // Payment Info (different for customer vs. restaurant)
            if (widget.isCustomerView)
              ...[
                makeLabel("💳 Payment Method: ${widget.orderData["payment"]?["method"] ?? "N/A"}"),
                makeLabel("Tips: \$${widget.orderData["payment"]?["tips"] ?? "0"}"),
                makeLabel("Subtotal: \$${widget.orderData["payment"]?["subtotalBeforeTax"] ?? "0"}"),
                makeLabel("Delivery Fee: \$${widget.orderData["payment"]?["deliveryFare"] ?? "0"}"),
                makeLabel("Total: \$${widget.orderData["payment"]?["total"] ?? "0"}"),
                makeLabel("Status: $orderStatus"),
                makeLabel("Transaction Ref: ${widget.orderData["payment"]?["transactionId"] ?? "N/A"}"),
                makeLabel("📆 Placed: ${widget.orderData["timestamps"]?["placed"] ?? "N/A"}"),
                makeLabel("🏁 Delivered: ${widget.orderData["timestamps"]?["delivered"] ?? "N/A"}"),
                makeLabel("📝 Notes: ${widget.orderData["notes"] ?? ""}"),
              ]
            else
              ...[
                makeLabel("💳 Payment Method: ${widget.orderData["payment"]?["method"] ?? "N/A"}"),
                makeLabel("Tips: \$${widget.orderData["payment"]?["tips"] ?? "0"}"),
                makeLabel("Subtotal: \$${widget.orderData["payment"]?["subtotalBeforeTax"] ?? "0"}"),
                makeLabel("Delivery Fee: \$${widget.orderData["payment"]?["deliveryFare"] ?? "0"}"),
                makeLabel("Total: \$${widget.orderData["payment"]?["total"] ?? "0"}"),
                makeLabel("Status: $orderStatus"),
                makeLabel("📆 Placed: ${widget.orderData["timestamps"]?["placed"] ?? "N/A"}"),
                makeLabel("🏁 Delivered: ${widget.orderData["timestamps"]?["delivered"] ?? "N/A"}"),
              ],
            // Restaurant view: show Accept/Decline buttons.
            if (!widget.isCustomerView)
              Builder(
                builder: (context) {
                  if (orderStatus == "placed") {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            updateOrderStatus("accepted");
                            // Notify drivers using customer details.
                            final rawCustomer = widget.orderData["customer"];
                            if (rawCustomer is Map) {
                              final customerMap = Map<String, dynamic>.from(
                                  rawCustomer.map((k, v) => MapEntry(k.toString(), v))
                              );
                              notifyDrivers(customerMap);
                            }
                          }, // <-- ✅ CLOSE the onPressed function before child
                          child: const Text("Accept",
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            updateOrderStatus("declined");
                          },
                          child: const Text("Decline",
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                        ),
                      ],
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            // In customer view, show driver information and related actions.
            if (widget.isCustomerView &&
                (driverInfo != null || driverIdFromOrder.isNotEmpty)) ...[
              makeLabel("👤 Driver: ${driverInfo?["name"] ?? "N/A"}"),
              makeLabel("📞 Phone: ${driverInfo?["phone"] ?? "N/A"}"),
              makeLabel("🚗 Vehicle: ${driverInfo?["carBrand"] ?? ""} ${driverInfo?["carModel"] ?? ""}"),
              makeLabel("📋 Plate: ${driverInfo?["licensePlate"] ?? "N/A"}"),
              ElevatedButton(
                onPressed: () {
                  showDriverInfoDialog(driverIdFromOrder, eta);
                },
                child: const Text("Know Your Driver",
                    style: TextStyle(color: Colors.black)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              ),
              if (orderStatus == "delivered") ...[
                ElevatedButton(
                  onPressed: hasRated
                      ? null
                      : () {
                    String restaurantIdFromOrder = widget.orderData["restaurant"]?["id"] ?? "";
                    showRatingDialog(orderId, restaurantIdFromOrder, driverIdFromOrder);
                  },
                  child: const Text(
                    "Rate Your Order",
                    style: TextStyle(color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hasRated ? Colors.grey : Colors.orange,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    showDisputeDialog(orderId);
                  },
                  child: const Text("Log A Complaint",
                      style: TextStyle(color: Colors.black)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

/// A simple star-rating widget that updates a TextEditingController with the rating.
class RatingBarWidget extends StatefulWidget {
  final TextEditingController controller;
  const RatingBarWidget({Key? key, required this.controller}) : super(key: key);

  @override
  _RatingBarWidgetState createState() => _RatingBarWidgetState();
}

class _RatingBarWidgetState extends State<RatingBarWidget> {
  double _rating = 0.0;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: Icon(
            index < _rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
          ),
          onPressed: () {
            setState(() {
              _rating = index + 1.0;
              widget.controller.text = _rating.toString();
            });
          },
        );
      }),
    );
  }
}
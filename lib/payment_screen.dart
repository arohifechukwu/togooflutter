import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/cart_item.dart';
import '../models/customer.dart';
import '../models/restaurant.dart';
import '../utils/restaurant_helper.dart';
import 'success_screen.dart';

class PaymentScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final double checkoutTotal;
  final Customer currentCustomer;
  final Restaurant selectedRestaurant;
  final String orderNote;
  final String paymentMethod; // e.g., "Card", "Cash", "Apple Pay"

  const PaymentScreen({
    Key? key,
    required this.cartItems,
    required this.checkoutTotal,
    required this.currentCustomer,
    required this.selectedRestaurant,
    required this.orderNote,
    required this.paymentMethod,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  // Stripe configuration
  static const String publishableKey =
      "pk_test_51Pju1z08k0nHIvbw5cvH5RvHpaKxzOJBcNCKKRpkJnXw96nsbEQ3FLKQOUYNVF6w5fff34S2pgn7J3fdzkdEi8Kk003V6xBVlv";
  // Change BASE_URL to your backend endpoint.
  static const String BASE_URL =
      "https://0921-185-205-247-241.ngrok-free.app";

  String? customerId;
  String? ephemeralKey;
  String? clientSecret;

  // PaymentSheet instance is managed by flutter_stripe package.
  // We'll call Stripe.instance.initPaymentSheet() and presentPaymentSheet().

  @override
  void initState() {
    super.initState();
    // Initialize Stripe with your publishable key.
    Stripe.publishableKey = publishableKey;
    _createCustomer();
  }

  Future<void> _createCustomer() async {
    try {
      final url = Uri.parse("$BASE_URL/create-customer");
      final response = await http.post(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        customerId = data["id"];
        // Delay briefly then fetch the ephemeral key.
        Future.delayed(const Duration(milliseconds: 400), _getEphemeralKey);
      } else {
        _showError("Failed to create customer");
      }
    } catch (e) {
      _showError("Failed to create customer: $e");
    }
  }

  Future<void> _getEphemeralKey() async {
    try {
      final url = Uri.parse("$BASE_URL/create-ephemeral-key");
      final params = jsonEncode({"customerId": customerId});
      final response = await http.post(url,
          body: params, headers: {"Content-Type": "application/json"});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        ephemeralKey = data["secret"];
        // Proceed to create the payment intent.
        _createPaymentIntent();
      } else {
        _showError("Failed to get ephemeral key");
      }
    } catch (e) {
      _showError("Error getting ephemeral key: $e");
    }
  }

  Future<void> _createPaymentIntent() async {
    try {
      final url = Uri.parse("$BASE_URL/create-payment-intent");
      final params = jsonEncode({
        "amount": (widget.checkoutTotal * 100).toInt(), // in cents
        "currency": "cad",
        "customerId": customerId,
      });
      final response = await http.post(url,
          body: params, headers: {"Content-Type": "application/json"});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        clientSecret = data["clientSecret"];
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ready to pay")),
        );
      } else {
        _showError("Failed to create payment intent");
      }
    } catch (e) {
      _showError("Error creating payment intent: $e");
    }
  }

  Future<void> _presentPaymentSheet() async {
    if (clientSecret == null || customerId == null || ephemeralKey == null) {
      _showError("Payment not ready yet");
      return;
    }

    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret!,
          merchantDisplayName: "ToGoo Checkout",
          customerId: customerId!,
          customerEphemeralKeySecret: ephemeralKey!,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      // Payment succeeded 🎉
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment successful!")),
      );

      await _storeOrderToFirebase("succeeded", clientSecret ?? "");

    } on StripeException catch (e) {
      _showError("Payment failed: ${e.error.localizedMessage}");
    } catch (e) {
      _showError("Unexpected error: $e");
    }
  }


  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    debugPrint("StripeError: $message");
  }

  // Build order data and store the order to Firebase.
  Future<void> _storeOrderToFirebase(String status, String transactionId) async {
    // Retrieve payment method from widget.paymentMethod
    String paymentMethod = widget.paymentMethod.isNotEmpty
        ? widget.paymentMethod
        : "Card";

    // Calculate subtotal before tax
    double subtotalBeforeTax = widget.cartItems.fold(
        0.0, (sum, item) => sum + item.foodPrice * item.quantity);
    double tips = subtotalBeforeTax * 0.10;

    // Generate order ID using Firebase push key
    final orderRef = FirebaseDatabase.instance.ref("orders").push();
    final orderId = orderRef.key;
    if (orderId == null) {
      debugPrint("Failed to generate order ID");
      return;
    }

    // Format the placed time in ISO 8601 format
    final placedTime =
    DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(DateTime.now());
    final placedMillis = DateTime.now().millisecondsSinceEpoch;

    // Build customer info map
    final customerInfo = {
      "id": widget.currentCustomer.id,
      "name": widget.currentCustomer.name,
      "phone": widget.currentCustomer.phone,
      "address": widget.currentCustomer.address,
    };

    // Build restaurant info map
    final restaurant = widget.selectedRestaurant;
    final restaurantInfo = {
      "id": restaurant.id,
      "name": restaurant.name,
      "address": restaurant.address,
    };

    // Build order details map (here we simply include the cart items)
    final orderDetails = {"items": widget.cartItems.map((e) => e.toMap()).toList()};

    // Build payment info map
    final paymentInfo = {
      "subtotalBeforeTax": subtotalBeforeTax,
      "deliveryFare": 5.00,
      "tips": tips,
      "total": widget.checkoutTotal,
      "status": status,
      "transactionId": transactionId,
      "method": paymentMethod,
    };

    // Build timestamps map
    final timestamps = {
      "placed": placedTime,
      "placedMillis": placedMillis,
      "restaurantAccepted": "pending",
      "driverAssigned": "pending",
      "delivered": "pending",
    };

    // Build a log entry
    final logEntry = {
      "timestamp": placedTime,
      "status": "placed",
      "note": "Order placed by customer."
    };

    // Build dispute info map
    final disputeInfo = {"status": "none", "reason": "", "details": ""};

    // Combine everything into the order data
    final orderData = {
      "customer": customerInfo,
      "restaurant": restaurantInfo,
      "driver": null,
      "orderDetails": orderDetails,
      "payment": paymentInfo,
      "status": "placed",
      "timestamps": timestamps,
      "updateLogs": [logEntry],
      "dispute": disputeInfo,
      "notes": widget.orderNote,
    };

    debugPrint("Storing order for restaurant: ${restaurant.name}");

    // Write order data to /orders/orderId
    await FirebaseDatabase.instance
        .ref("orders")
        .child(orderId)
        .set(orderData)
        .then((_) => debugPrint("Order added to /orders"))
        .catchError((e) => debugPrint("Failed to add to /orders: $e"));

    // Link order to customer
    await FirebaseDatabase.instance
        .ref("ordersByCustomer")
        .child(widget.currentCustomer.id!)
        .child(orderId)
        .set(true)
        .then((_) => debugPrint("Order linked to customer"))
        .catchError((e) => debugPrint("Failed to link order to customer: $e"));

    // Link order to restaurant
    await FirebaseDatabase.instance
        .ref("ordersByRestaurant")
        .child(restaurant.id!)
        .child(orderId)
        .set(true)
        .then((_) => debugPrint("Order linked to restaurant"))
        .catchError((e) => debugPrint("Failed to link order to restaurant: $e"));

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Order placed!")));

    // Navigate to a success screen.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SuccessScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Layout: Two buttons in a ConstraintLayout-like style.
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment"),
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Credit Card Payment Button
            ElevatedButton(
              onPressed: _presentPaymentSheet,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              ),
              child: const Text(
                "Credit Card Payment",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            // Pick Up Order Button
            ElevatedButton(
              onPressed: () {
                // For pick-up, we can directly store the order with a specific status.
                _storeOrderToFirebase("pickup", "pickup").then((_) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const SuccessScreen()),
                  );
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              ),
              child: const Text(
                "Pick Up Order",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
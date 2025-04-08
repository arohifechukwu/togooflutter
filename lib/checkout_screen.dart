// import 'package:flutter/material.dart';
// import 'package:togoo/admin_home.dart';
// import '../models/cart_item.dart';
// import '../widgets/checkout_adapter.dart';
// import 'customer_home.dart';
//
// class CheckoutScreen extends StatefulWidget {
//   final List<CartItem> cartItems;
//
//   const CheckoutScreen({Key? key, required this.cartItems}) : super(key: key);
//
//   @override
//   State<CheckoutScreen> createState() => _CheckoutScreenState();
// }
//
// class _CheckoutScreenState extends State<CheckoutScreen> {
//   late List<CartItem> checkoutItems;
//   double subtotal = 0.0;
//   double gst = 0.0;
//   double qst = 0.0;
//   double total = 0.0;
//
//   @override
//   void initState() {
//     super.initState();
//     checkoutItems = widget.cartItems;
//     _calculateTotal();
//   }
//
//   void _calculateTotal() {
//     subtotal = checkoutItems.fold(0.0, (sum, item) => sum + item.foodPrice * item.quantity);
//     gst = subtotal * 0.05;
//     qst = subtotal * 0.09975;
//     total = subtotal + gst + qst;
//     setState(() {});
//   }
//
//   void _proceedToPayment() {
//     // Add logic to go to payment screen
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Proceeding to payment...")),
//     );
//   }
//
//   void _cancelOrder() {
//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(builder: (context) => CustomerHome()),
//           (route) => false,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Checkout"), backgroundColor: Colors.orange),
//       body: Column(
//         children: [
//           Expanded(
//             child: CheckoutAdapter(
//               checkoutItems: checkoutItems,
//               onQuantityChanged: _calculateTotal,
//             ),
//           ),
//           Container(
//             color: Colors.grey.shade200,
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             child: Column(
//               children: [
//                 _buildSummaryRow("Subtotal", subtotal),
//                 _buildSummaryRow("GST (5%)", gst),
//                 _buildSummaryRow("QST (9.975%)", qst),
//                 const Divider(thickness: 1),
//                 _buildSummaryRow("Total", total, isBold: true),
//                 const SizedBox(height: 12),
//                 ElevatedButton(
//                   onPressed: _proceedToPayment,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     minimumSize: const Size.fromHeight(50),
//                   ),
//                   child: const Text("Proceed to Payment", style: TextStyle(color: Colors.white, fontSize: 16)),
//                 ),
//                 const SizedBox(height: 10),
//                 ElevatedButton(
//                   onPressed: _cancelOrder,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: primaryVariant,
//                     minimumSize: const Size.fromHeight(50),
//                   ),
//                   child: const Text("Cancel Order", style: TextStyle(color: Colors.white, fontSize: 16)),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSummaryRow(String label, double value, {bool isBold = false}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label, style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
//           Text("\$${value.toStringAsFixed(2)}", style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
//         ],
//       ),
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/cart_item.dart';
import '../models/customer.dart';
import '../models/restaurant.dart';
import '../utils/restaurant_helper.dart';
import '../widgets/checkout_adapter.dart';
import 'customer_home.dart';
import 'payment_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final Restaurant selectedRestaurant;

  const CheckoutScreen({Key? key, required this.cartItems, required this.selectedRestaurant,
  }) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late List<CartItem> checkoutItems;
  double subtotal = 0.0;
  double deliveryFare = 5.00;
  double tip = 0.0;
  double gst = 0.0;
  double qst = 0.0;
  double total = 0.0;

  // Constants (as in Java)
  static const double GST_RATE = 0.05;
  static const double QST_RATE = 0.09975;
  static const double DELIVERY_FARE = 5.00;
  static const double TIP_PERCENTAGE = 0.10;

  // Order note controller
  final TextEditingController orderNoteController = TextEditingController();

  // Payment method selection
  String paymentMethod = "Card";

  // Current customer fetched from Firebase
  Customer? currentCustomer;

  @override
  void initState() {
    super.initState();
    checkoutItems = widget.cartItems;
    _calculateTotal();
    _fetchCustomer();
  }

  void _calculateTotal() {
    subtotal = checkoutItems.fold(
        0.0, (sum, item) => sum + item.foodPrice * item.quantity);
    tip = subtotal * TIP_PERCENTAGE;
    gst = subtotal * GST_RATE;
    qst = subtotal * QST_RATE;
    total = subtotal + tip + deliveryFare + gst + qst;
    setState(() {});
  }

  Future<void> _fetchCustomer() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final uid = user.uid;
    final customerRef =
    FirebaseDatabase.instance.ref("customer").child(uid);
    final snapshot = await customerRef.get();
    if (snapshot.exists) {
      // Assuming you have a Customer.fromMap(Map, {String? id}) constructor
      setState(() {
        currentCustomer = Customer.fromMap(
          Map<String, dynamic>.from(snapshot.value as Map),
          id: uid,
        );
      });
    } else {
      // Handle missing customer info if needed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Customer info missing.")),
      );
    }
  }

  void _proceedToPayment() {
    // Ensure the current restaurant is set
    Restaurant? currentRestaurant =
        ModalRoute.of(context)!.settings.arguments as Restaurant? ??
            RestaurantHelper.getCurrentRestaurant();
    if (currentRestaurant == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Restaurant info missing. Please try again.")),
      );
      return;
    }
    // Verify all cart items are from the same restaurant
    for (CartItem item in checkoutItems) {
      if (item.restaurantId == null ||
          item.restaurantId != currentRestaurant.id) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Cart contains items from different or invalid restaurants.")),
        );
        return;
      }
    }
    // Retrieve the selected payment method (already stored in [paymentMethod])
    // Prepare order note
    String orderNote = orderNoteController.text.trim();

    // Navigate to PaymentScreen with all details
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          cartItems: checkoutItems,
          checkoutTotal: total,
          currentCustomer: currentCustomer!,
          selectedRestaurant: currentRestaurant,
          orderNote: orderNote,
          paymentMethod: paymentMethod,
        ),
      ),
    );
  }

  void _cancelOrder() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => CustomerHome()),
          (route) => false,
    );
  }

  Widget _buildSummaryRow(String label, double value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text("\$${value.toStringAsFixed(2)}",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Payment Method",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Radio<String>(
              value: "Card",
              groupValue: paymentMethod,
              onChanged: (value) {
                setState(() {
                  paymentMethod = value!;
                });
              },
            ),
            const Text("Card"),
            Radio<String>(
              value: "Cash",
              groupValue: paymentMethod,
              onChanged: (value) {
                setState(() {
                  paymentMethod = value!;
                });
              },
            ),
            const Text("Cash"),
            Radio<String>(
              value: "Apple Pay",
              groupValue: paymentMethod,
              onChanged: (value) {
                setState(() {
                  paymentMethod = value!;
                });
              },
            ),
            const Text("Apple Pay"),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // The layout follows the XML: a Scrollable Column with checkout items and summary section.
    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout"),
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: CheckoutAdapter(
              checkoutItems: checkoutItems,
              onQuantityChanged: _calculateTotal,
            ),
          ),
          // Price Summary Container
          Container(
            color: Colors.grey.shade200,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                _buildSummaryRow("Delivery Fare", deliveryFare),
                _buildSummaryRow("Tips (10%)", subtotal * TIP_PERCENTAGE),
                _buildSummaryRow("Subtotal", subtotal),
                _buildSummaryRow("GST (5%)", gst),
                _buildSummaryRow("QST (9.975%)", qst),
                const Divider(thickness: 1),
                _buildSummaryRow("Total", total, isBold: true),
                const SizedBox(height: 12),
                // Order Note Input
                TextField(
                  controller: orderNoteController,
                  decoration: const InputDecoration(
                    hintText: "Add a note for your order (optional)",
                    border: OutlineInputBorder(),
                  ),
                  minLines: 2,
                  maxLines: 4,
                ),
                const SizedBox(height: 12),
                _buildPaymentMethodSelector(),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _proceedToPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text(
                    "Proceed to Payment",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _cancelOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text(
                    "Cancel Order",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
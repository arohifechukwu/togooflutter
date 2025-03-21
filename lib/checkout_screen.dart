import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../widgets/checkout_adapter.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> cartItems;

  const CheckoutScreen({Key? key, required this.cartItems}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late List<CartItem> checkoutItems;
  double subtotal = 0.0;
  double gst = 0.0;
  double qst = 0.0;
  double total = 0.0;

  @override
  void initState() {
    super.initState();
    checkoutItems = widget.cartItems;
    _calculateTotal();
  }

  void _calculateTotal() {
    subtotal = checkoutItems.fold(0.0, (sum, item) => sum + item.foodPrice * item.quantity);
    gst = subtotal * 0.05;
    qst = subtotal * 0.09975;
    total = subtotal + gst + qst;
    setState(() {});
  }

  void _proceedToPayment() {
    // Add logic to go to payment screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Proceeding to payment...")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Checkout"), backgroundColor: Colors.orange),
      body: Column(
        children: [
          Expanded(
            child: CheckoutAdapter(
              checkoutItems: checkoutItems,
              onQuantityChanged: _calculateTotal,
            ),
          ),
          Container(
            color: Colors.grey.shade200,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                _buildSummaryRow("Subtotal", subtotal),
                _buildSummaryRow("GST (5%)", gst),
                _buildSummaryRow("QST (9.975%)", qst),
                const Divider(thickness: 1),
                _buildSummaryRow("Total", total, isBold: true),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _proceedToPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text("Proceed to Payment", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text("\$${value.toStringAsFixed(2)}", style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
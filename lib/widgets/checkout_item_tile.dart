import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/cart_item.dart';

class CheckoutItemList extends StatelessWidget {
  final List<CartItem> checkoutItems;
  final VoidCallback onQuantityChanged;

  CheckoutItemList({
    required this.checkoutItems,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: checkoutItems.length,
      itemBuilder: (context, index) {
        return CheckoutItemTile(
          item: checkoutItems[index],
          onQuantityChanged: onQuantityChanged,
        );
      },
    );
  }
}

class CheckoutItemTile extends StatefulWidget {
  final CartItem item;
  final VoidCallback onQuantityChanged;

  CheckoutItemTile({
    required this.item,
    required this.onQuantityChanged,
  });

  @override
  _CheckoutItemTileState createState() => _CheckoutItemTileState();
}

class _CheckoutItemTileState extends State<CheckoutItemTile> {
  void _increaseQuantity() {
    setState(() {
      widget.item.quantity += 1;
    });
    widget.onQuantityChanged();
  }

  void _decreaseQuantity() {
    if (widget.item.quantity > 1) {
      setState(() {
        widget.item.quantity -= 1;
      });
      widget.onQuantityChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          children: [
            CachedNetworkImage(
              imageUrl: widget.item.foodImage,
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.foodDescription,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "\$${widget.item.foodPrice.toStringAsFixed(2)}",
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: Icon(Icons.add_circle, color: Colors.green),
                  onPressed: _increaseQuantity,
                ),
                Text(
                  widget.item.quantity.toString(),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: _decreaseQuantity,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

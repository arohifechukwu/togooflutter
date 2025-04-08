// import 'package:flutter/material.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import '../models/cart_item.dart';
//
// class CheckoutAdapter extends StatelessWidget {
//   final List<CartItem> checkoutItems;
//   final VoidCallback onQuantityChanged;
//
//   const CheckoutAdapter({
//     Key? key,
//     required this.checkoutItems,
//     required this.onQuantityChanged,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       shrinkWrap: true,
//       physics: NeverScrollableScrollPhysics(),
//       itemCount: checkoutItems.length,
//       itemBuilder: (context, index) {
//         final item = checkoutItems[index];
//         return Card(
//           margin: const EdgeInsets.symmetric(vertical: 8),
//           elevation: 3,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//           child: Padding(
//             padding: const EdgeInsets.all(10),
//             child: Row(
//               children: [
//                 CachedNetworkImage(
//                   imageUrl: item.foodImage,
//                   width: 80,
//                   height: 80,
//                   fit: BoxFit.cover,
//                   placeholder: (context, url) => CircularProgressIndicator(),
//                   errorWidget: (context, url, error) => Icon(Icons.error),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(item.foodDescription, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                       SizedBox(height: 6),
//                       Text("\$${item.foodPrice.toStringAsFixed(2)}", style: TextStyle(fontSize: 15, color: Colors.red)),
//                     ],
//                   ),
//                 ),
//                 Row(
//                   children: [
//                     ElevatedButton(
//                       onPressed: () {
//                         if (item.quantity > 1) {
//                           item.quantity--;
//                           onQuantityChanged();
//                         }
//                       },
//                       child: Text("-", style: TextStyle(color: Colors.white)),
//                       style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 10),
//                       child: Text("${item.quantity}", style: TextStyle(fontSize: 16)),
//                     ),
//                     ElevatedButton(
//                       onPressed: () {
//                         item.quantity++;
//                         onQuantityChanged();
//                       },
//                       child: Text("+", style: TextStyle(color: Colors.white)),
//                       style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/cart_item.dart';

class CheckoutAdapter extends StatelessWidget {
  final List<CartItem> checkoutItems;
  final VoidCallback onQuantityChanged;

  const CheckoutAdapter({
    Key? key,
    required this.checkoutItems,
    required this.onQuantityChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: checkoutItems.length,
      itemBuilder: (context, index) {
        final item = checkoutItems[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                // Food Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: item.foodImage,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                    const Icon(Icons.error),
                  ),
                ),
                const SizedBox(width: 12),
                // Description and Price
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.foodDescription,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "\$${item.foodPrice.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                // Quantity Controls: Decrease and Increase buttons with quantity text
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (item.quantity > 1) {
                          item.quantity--;
                          onQuantityChanged();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text(
                        "-",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "${item.quantity}",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        item.quantity++;
                        onQuantityChanged();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text(
                        "+",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
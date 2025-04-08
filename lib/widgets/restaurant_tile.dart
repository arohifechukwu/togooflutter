// import 'package:flutter/material.dart';
// import '../models/restaurant.dart';
//
// class RestaurantTile extends StatelessWidget {
//   final Restaurant restaurant;
//   final VoidCallback onTap;
//
//   const RestaurantTile({
//     Key? key,
//     required this.restaurant,
//     required this.onTap,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       elevation: 4,
//       child: InkWell(
//         borderRadius: BorderRadius.circular(12),
//         onTap: onTap,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Restaurant image
//             ClipRRect(
//               borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
//               child: Image.network(
//                 restaurant.imageUrl ?? '',
//                 height: 160,
//                 width: double.infinity,
//                 fit: BoxFit.cover,
//                 errorBuilder: (context, error, stackTrace) => Image.asset(
//                   'assets/ic_restaurant_placeholder.png',
//                   height: 160,
//                   width: double.infinity,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(12),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     restaurant.name ?? 'Unnamed Restaurant',
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     '⭐ ${restaurant.rating?.toStringAsFixed(1) ?? '4.5'}',
//                     style: const TextStyle(fontSize: 14, color: Colors.orangeAccent),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     restaurant.address ?? 'Address unavailable',
//                     style: const TextStyle(fontSize: 14, color: Colors.grey),
//                   ),
//                   const SizedBox(height: 2),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         '${restaurant.etaMinutes ?? 0} mins',
//                         style: const TextStyle(fontSize: 14, color: Colors.grey),
//                       ),
//                       Text(
//                         '${restaurant.distanceKm?.toStringAsFixed(1) ?? '?'} km',
//                         style: const TextStyle(fontSize: 14, color: Colors.grey),
//                       ),
//                     ],
//                   )
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }





// import 'package:flutter/material.dart';
// import '../models/restaurant.dart';
//
// class RestaurantTile extends StatelessWidget {
//   final Restaurant restaurant;
//   final VoidCallback onTap;
//
//   const RestaurantTile({
//     Key? key,
//     required this.restaurant,
//     required this.onTap,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       elevation: 4,
//       child: InkWell(
//         borderRadius: BorderRadius.circular(12),
//         onTap: onTap,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Restaurant image
//             ClipRRect(
//               borderRadius:
//               const BorderRadius.vertical(top: Radius.circular(12)),
//               child: Image.network(
//                 restaurant.imageUrl ?? '',
//                 height: 160,
//                 width: double.infinity,
//                 fit: BoxFit.cover,
//                 errorBuilder: (context, error, stackTrace) => Image.asset(
//                   'assets/ic_restaurant_placeholder.png',
//                   height: 160,
//                   width: double.infinity,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(12),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     restaurant.name ?? 'Unnamed Restaurant',
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     '⭐ ${restaurant.rating?.toStringAsFixed(1) ?? '4.5'}',
//                     style: const TextStyle(
//                         fontSize: 14, color: Colors.orangeAccent),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     restaurant.address ?? 'Address unavailable',
//                     style:
//                     const TextStyle(fontSize: 14, color: Colors.grey),
//                   ),
//                   const SizedBox(height: 2),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         '${restaurant.etaMinutes ?? 0} mins',
//                         style:
//                         const TextStyle(fontSize: 14, color: Colors.grey),
//                       ),
//                       Text(
//                         '${restaurant.distanceKm?.toStringAsFixed(1) ?? '?'} km',
//                         style:
//                         const TextStyle(fontSize: 14, color: Colors.grey),
//                       ),
//                     ],
//                   )
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }



// In your restaurant_tile.dart file
import 'package:flutter/material.dart';
import '../models/restaurant.dart';

class RestaurantTile extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback onTap;

  const RestaurantTile({
    Key? key,
    required this.restaurant,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: (restaurant.imageUrl ?? '').isNotEmpty
                  ? Image.network(
                restaurant.imageUrl!,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  'assets/ic_restaurant_placeholder.png',
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
                  : Image.asset(
                'assets/ic_restaurant_placeholder.png',
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name ?? 'Unnamed Restaurant',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '⭐ ${restaurant.rating?.toStringAsFixed(1) ?? '4.5'}',
                    style: const TextStyle(fontSize: 14, color: Colors.orangeAccent),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    restaurant.address ?? 'Address unavailable',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${restaurant.etaMinutes ?? 0} mins',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      Text(
                        '${restaurant.distanceKm?.toStringAsFixed(1) ?? '?'} km',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
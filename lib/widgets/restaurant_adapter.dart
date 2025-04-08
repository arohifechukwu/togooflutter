import 'package:flutter/material.dart';
import '../models/restaurant.dart';

/// Callback signature for when a restaurant is tapped.
typedef OnRestaurantClickListener = void Function(Restaurant restaurant);

/// A widget that builds a list view of Restaurant items.
class RestaurantAdapter extends StatelessWidget {
  final List<Restaurant> restaurantList;
  final OnRestaurantClickListener listener;

  const RestaurantAdapter({
    Key? key,
    required this.restaurantList,
    required this.listener,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: restaurantList.length,
      itemBuilder: (context, index) {
        final restaurant = restaurantList[index];
        return GestureDetector(
          onTap: () => listener(restaurant),
          child: RestaurantItem(restaurant: restaurant),
        );
      },
    );
  }
}

/// A widget that displays a single restaurant item, mirroring the XML layout.
class RestaurantItem extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantItem({
    Key? key,
    required this.restaurant,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.secondary, // approximates primary_variant
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                restaurant.getImageUrl ?? '',
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  'assets/ic_restaurant_placeholder.png',
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Restaurant Name
            Text(
              restaurant.getName ?? '',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            // Restaurant Rating
            if (restaurant.getRating > 0)
              Text(
                "\u2B50 ${restaurant.getRating}",
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            const SizedBox(height: 2),
            // Restaurant Location
            Text(
              restaurant.getAddress ?? '',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 6),
            // ETA and Distance Row
            Row(
              children: [
                // ETA
                Expanded(
                  child: restaurant.getEtaMinutes > 0
                      ? Text(
                    "${restaurant.getEtaMinutes} mins",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  )
                      : Container(),
                ),
                // Distance
                if (restaurant.getDistanceKm > 0)
                  Text(
                    "${restaurant.getDistanceKm.toStringAsFixed(1)} km",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
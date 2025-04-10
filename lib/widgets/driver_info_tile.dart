import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DriverInfoTile extends StatelessWidget {
  final String driverImageUrl;
  final String driverName;
  final String driverPhone;
  final String carImageUrl;
  final String carType;
  final String carModel;
  final String licensePlate;
  final String estimatedTime;

  const DriverInfoTile({
    Key? key,
    required this.driverImageUrl,
    required this.driverName,
    required this.driverPhone,
    required this.carImageUrl,
    required this.carType,
    required this.carModel,
    required this.licensePlate,
    required this.estimatedTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Driver Profile Picture
          ClipOval(
            child: CachedNetworkImage(
              imageUrl: driverImageUrl,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.account_circle, size: 100),
            ),
          ),
          const SizedBox(height: 12),
          Text(driverName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text("Phone: $driverPhone", style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: carImageUrl,
              width: 200,
              height: 120,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey,
                child: const Icon(Icons.directions_car, size: 60),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text("Car Type: $carType", style: const TextStyle(fontSize: 16)),
          Text("Model: $carModel", style: const TextStyle(fontSize: 16)),
          Text("License Plate: $licensePlate", style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text("ETA: $estimatedTime", style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}

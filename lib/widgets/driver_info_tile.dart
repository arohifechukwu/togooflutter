// import 'package:flutter/material.dart';
// import 'package:cached_network_image/cached_network_image.dart';
//
// // DRIVER INFO TILE WIDGET
// class DriverInfoTile extends StatelessWidget {
//   final String driverImageUrl;
//   final String driverName;
//   final String driverPhone;
//   final String carImageUrl;
//   final String carType;
//   final String carModel;
//   final String licensePlate;
//   final String estimatedTime;
//
//   const DriverInfoTile({
//     Key? key,
//     required this.driverImageUrl,
//     required this.driverName,
//     required this.driverPhone,
//     required this.carImageUrl,
//     required this.carType,
//     required this.carModel,
//     required this.licensePlate,
//     required this.estimatedTime,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             // Driver Profile Picture
//             ClipOval(
//               child: CachedNetworkImage(
//                 imageUrl: driverImageUrl,
//                 width: 100,
//                 height: 100,
//                 fit: BoxFit.cover,
//                 placeholder: (context, url) =>
//                 const CircularProgressIndicator(),
//                 errorWidget: (context, url, error) =>
//                 const Icon(Icons.account_circle, size: 100),
//               ),
//             ),
//             const SizedBox(height: 12),
//             // Driver Name
//             Text(
//               driverName,
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 4),
//             // Driver Phone
//             Text(
//               "Phone: $driverPhone",
//               style: const TextStyle(fontSize: 16),
//             ),
//             const SizedBox(height: 12),
//             // Car Image
//             ClipRRect(
//               borderRadius: BorderRadius.circular(8),
//               child: CachedNetworkImage(
//                 imageUrl: carImageUrl,
//                 width: 200,
//                 height: 120,
//                 fit: BoxFit.cover,
//                 placeholder: (context, url) =>
//                     Container(width: 200, height: 120, color: Colors.grey),
//                 errorWidget: (context, url, error) => Container(
//                   width: 200,
//                   height: 120,
//                   color: Colors.grey,
//                   child: const Icon(Icons.directions_car, size: 60),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 12),
//             // Car Type
//             Text("Car Type: $carType", style: const TextStyle(fontSize: 16)),
//             const SizedBox(height: 4),
//             // Car Model
//             Text("Model: $carModel", style: const TextStyle(fontSize: 16)),
//             const SizedBox(height: 4),
//             // License Plate
//             Text("License Plate: $licensePlate", style: const TextStyle(fontSize: 16)),
//             const SizedBox(height: 8),
//             // Estimated Time
//             Text(
//               "ETA: $estimatedTime",
//               style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // DEMO USAGE IN A SCREEN
// class DriverInfoScreen extends StatelessWidget {
//   const DriverInfoScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Your Driver"),
//         backgroundColor: Colors.green,
//       ),
//       body: DriverInfoTile(
//         driverImageUrl: "https://i.pravatar.cc/150?img=12",
//         driverName: "Alex Johnson",
//         driverPhone: "+1 (514) 987-6543",
//         carImageUrl: "https://cdn.pixabay.com/photo/2012/05/29/00/43/car-49278_1280.jpg",
//         carType: "SUV",
//         carModel: "Ford Escape",
//         licensePlate: "QC-8X5H23",
//         estimatedTime: "12 mins",
//       ),
//     );
//   }
// }



// DRIVER INFO TILE
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

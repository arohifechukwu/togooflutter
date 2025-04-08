// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';  // Import google_maps_flutter
// import 'package:intl/intl.dart';
// import 'package:location/location.dart';
// import 'package:togoo/driver_home.dart';
//
// class DriverDeliveryScreen extends StatefulWidget {
//   final String orderId;
//   const DriverDeliveryScreen({Key? key, required this.orderId}) : super(key: key);
//
//   @override
//   _DriverDeliveryScreenState createState() => _DriverDeliveryScreenState();
// }
//
// class _DriverDeliveryScreenState extends State<DriverDeliveryScreen> {
//   late GoogleMapController mapController;
//   late LatLng driverLatLng;
//   late LatLng restaurantLatLng;
//   late LatLng customerLatLng;
//
//   String driverAddress = '';
//   String restaurantAddress = '';
//   String customerAddress = '';
//   String orderId = '';
//   late DatabaseReference ordersRef;
//   late DatabaseReference driversRef;
//
//   bool isTripStarted = false;
//   Set<Marker> _markers = {};  // Set for holding markers
//   Set<Polyline> _polylines = {};  // Set for holding polylines
//
//   @override
//   void initState() {
//     super.initState();
//     orderId = widget.orderId;
//     ordersRef = FirebaseDatabase.instance.ref('orders');
//     driversRef = FirebaseDatabase.instance.ref('driver');
//     _fetchAddressesAndInitializeMap();
//   }
//
//   // Fetch address details from Firebase and initialize the map.
//   void _fetchAddressesAndInitializeMap() {
//     driversRef.child(FirebaseAuth.instance.currentUser!.uid).get().then((snapshot) {
//       if (snapshot.exists) {
//         driverAddress = snapshot.child("address").value.toString();
//         ordersRef.child(orderId).get().then((orderSnapshot) {
//           if (orderSnapshot.exists) {
//             restaurantAddress = orderSnapshot.child("restaurant/address").value.toString();
//             customerAddress = orderSnapshot.child("customer/address").value.toString();
//             if (driverAddress.isNotEmpty && restaurantAddress.isNotEmpty && customerAddress.isNotEmpty) {
//               _initializeMap();
//             } else {
//               _showErrorMessage("Address is missing");
//             }
//           }
//         });
//       }
//     });
//   }
//
//   // Initialize the map and add markers for the driver, restaurant, and customer.
//   void _initializeMap() {
//     Location().getLocation().then((locationData) {
//       driverLatLng = LatLng(locationData.latitude!, locationData.longitude!);
//       restaurantLatLng = _getLatLngFromAddress(restaurantAddress);
//       customerLatLng = _getLatLngFromAddress(customerAddress);
//
//       setState(() {
//         // Add markers for driver, restaurant, and customer
//         _markers.add(Marker(
//           markerId: MarkerId("driver"),
//           position: driverLatLng,
//           infoWindow: InfoWindow(title: "Driver"),
//         ));
//         _markers.add(Marker(
//           markerId: MarkerId("restaurant"),
//           position: restaurantLatLng,
//           infoWindow: InfoWindow(title: "Restaurant"),
//         ));
//         _markers.add(Marker(
//           markerId: MarkerId("customer"),
//           position: customerLatLng,
//           infoWindow: InfoWindow(title: "Customer"),
//         ));
//       });
//
//       // Update camera to show all markers
//       _updateCameraPosition();
//     });
//   }
//
//   // Get LatLng from address
//   LatLng _getLatLngFromAddress(String address) {
//     // Implement a function to geocode address to LatLng
//     return LatLng(0, 0); // Placeholder
//   }
//
//   // Update the camera to fit all markers
//   void _updateCameraPosition() {
//     LatLngBounds bounds = _getLatLngBounds();
//     mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
//   }
//
//   // Get bounds for the markers to fit in camera
//   LatLngBounds _getLatLngBounds() {
//     double minLat = driverLatLng.latitude;
//     double minLng = driverLatLng.longitude;
//     double maxLat = driverLatLng.latitude;
//     double maxLng = driverLatLng.longitude;
//
//     // Get the bounds from the three markers
//     List<LatLng> positions = [driverLatLng, restaurantLatLng, customerLatLng];
//     for (var position in positions) {
//       if (position.latitude < minLat) minLat = position.latitude;
//       if (position.latitude > maxLat) maxLat = position.latitude;
//       if (position.longitude < minLng) minLng = position.longitude;
//       if (position.longitude > maxLng) maxLng = position.longitude;
//     }
//
//     return LatLngBounds(
//       southwest: LatLng(minLat, minLng),
//       northeast: LatLng(maxLat, maxLng),
//     );
//   }
//
//   // Start the trip
//   void _startTrip() {
//     setState(() {
//       isTripStarted = true;
//     });
//     _drawRoute();
//   }
//
//   // Mark as arrived at customer
//   void _markArrived() {
//     String now = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(DateTime.now());
//     ordersRef.child(orderId).update({
//       'status': 'delivered',
//       'timestamps/arrived': now,
//     }).then((_) {
//       Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DriverHomeScreen()));
//     });
//   }
//
//   // Draw the route between driver, restaurant, and customer
//   void _drawRoute() {
//     if (driverLatLng == null || restaurantLatLng == null || customerLatLng == null) {
//       return;
//     }
//
//     // Clear existing polylines
//     _polylines.clear();
//
//     // Add route polyline
//     _polylines.add(Polyline(
//       polylineId: PolylineId("route"),
//       points: [driverLatLng, restaurantLatLng, customerLatLng],
//       width: 10,
//       color: Colors.blue,
//     ));
//
//     setState(() {});
//   }
//
//   // Display an error message in case of missing address or any issue
//   void _showErrorMessage(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Driver Delivery'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: GoogleMap(
//               onMapCreated: (controller) {
//                 mapController = controller;
//               },
//               initialCameraPosition: CameraPosition(
//                 target: driverLatLng,
//                 zoom: 12,
//               ),
//               markers: _markers,
//               polylines: _polylines,
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 ElevatedButton(
//                   onPressed: _startTrip,
//                   child: Text('Start Trip'),
//                 ),
//                 SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: _markArrived,
//                   child: Text('Mark as Arrived'),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
// Alias the location package to avoid name conflicts:
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';
import 'package:togoo/driver_home.dart';

class DriverDeliveryScreen extends StatefulWidget {
  final String orderId;
  const DriverDeliveryScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  _DriverDeliveryScreenState createState() => _DriverDeliveryScreenState();
}

class _DriverDeliveryScreenState extends State<DriverDeliveryScreen> {
  GoogleMapController? mapController;
  late LatLng driverLatLng;
  late LatLng restaurantLatLng;
  late LatLng customerLatLng;

  String driverAddress = '';
  String restaurantAddress = '';
  String customerAddress = '';
  String orderId = '';
  late DatabaseReference ordersRef;
  late DatabaseReference driversRef;

  bool isTripStarted = false;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _isMapInitialized = false;

  @override
  void initState() {
    super.initState();
    orderId = widget.orderId;
    ordersRef = FirebaseDatabase.instance.ref('orders');
    driversRef = FirebaseDatabase.instance.ref('driver');
    _fetchAddressesAndInitializeMap();
  }

  void _fetchAddressesAndInitializeMap() {
    driversRef.child(FirebaseAuth.instance.currentUser!.uid).get().then((snapshot) {
      if (snapshot.exists) {
        driverAddress = snapshot.child("address").value.toString();
        ordersRef.child(orderId).get().then((orderSnapshot) {
          if (orderSnapshot.exists) {
            restaurantAddress = orderSnapshot.child("restaurant/address").value.toString();
            customerAddress = orderSnapshot.child("customer/address").value.toString();
            if (driverAddress.isNotEmpty && restaurantAddress.isNotEmpty && customerAddress.isNotEmpty) {
              _initializeMap();
            } else {
              _showErrorMessage("Address is missing");
            }
          }
        });
      }
    });
  }

  // Marked as async to await asynchronous operations.
  void _initializeMap() async {
    // Use the aliased loc.Location() to get the current location.
    loc.LocationData locationData = await loc.Location().getLocation();
    driverLatLng = LatLng(locationData.latitude!, locationData.longitude!);
    restaurantLatLng = await _getLatLngFromAddress(restaurantAddress);
    customerLatLng = await _getLatLngFromAddress(customerAddress);

    setState(() {
      _isMapInitialized = true;
      _markers.add(Marker(
        markerId: MarkerId("driver"),
        position: driverLatLng,
        infoWindow: InfoWindow(title: "Driver"),
      ));
      _markers.add(Marker(
        markerId: MarkerId("restaurant"),
        position: restaurantLatLng,
        infoWindow: InfoWindow(title: "Restaurant"),
      ));
      _markers.add(Marker(
        markerId: MarkerId("customer"),
        position: customerLatLng,
        infoWindow: InfoWindow(title: "Customer"),
      ));
    });
  }

  // Updated to return a Future and marked as async.
  Future<LatLng> _getLatLngFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return LatLng(locations.first.latitude, locations.first.longitude);
      }
    } catch (e) {
      print("Error geocoding address: $e");
    }
    return LatLng(0, 0);
  }

  void _updateCameraPosition() {
    if (mapController == null) return;
    LatLngBounds bounds = _getLatLngBounds();
    mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

  LatLngBounds _getLatLngBounds() {
    double minLat = driverLatLng.latitude;
    double minLng = driverLatLng.longitude;
    double maxLat = driverLatLng.latitude;
    double maxLng = driverLatLng.longitude;

    List<LatLng> positions = [driverLatLng, restaurantLatLng, customerLatLng];
    for (var position in positions) {
      if (position.latitude < minLat) minLat = position.latitude;
      if (position.latitude > maxLat) maxLat = position.latitude;
      if (position.longitude < minLng) minLng = position.longitude;
      if (position.longitude > maxLng) maxLng = position.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  void _startTrip() {
    setState(() {
      isTripStarted = true;
    });
    _drawRoute();
  }

  void _markArrived() {
    String now = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(DateTime.now());
    ordersRef.child(orderId).update({
      'status': 'delivered',
      'timestamps/arrived': now,
    }).then((_) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DriverHomeScreen()));
    });
  }

  void _drawRoute() {
    if (driverLatLng == null || restaurantLatLng == null || customerLatLng == null) {
      return;
    }
    _polylines.clear();
    _polylines.add(Polyline(
      polylineId: PolylineId("route"),
      points: [driverLatLng, restaurantLatLng, customerLatLng],
      width: 10,
      color: Colors.blue,
    ));
    setState(() {});
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Delivery'),
      ),
      body: _isMapInitialized
          ? Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: (controller) {
                mapController = controller;
                _updateCameraPosition();
              },
              initialCameraPosition: CameraPosition(
                target: LatLng(0, 0),
                zoom: 12,
              ),
              markers: _markers,
              polylines: _polylines,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: _startTrip,
                  child: Text('Start Trip'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _markArrived,
                  child: Text('Mark as Arrived'),
                ),
              ],
            ),
          ),
        ],
      )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
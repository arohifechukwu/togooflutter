import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
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

  void _initializeMap() async {
    loc.LocationData locationData = await loc.Location().getLocation();
    driverLatLng = LatLng(locationData.latitude!, locationData.longitude!);
    restaurantLatLng = await _getLatLngFromAddress(restaurantAddress);
    customerLatLng = await _getLatLngFromAddress(customerAddress);

    setState(() {
      _isMapInitialized = true;
      _markers.add(Marker(
        markerId: const MarkerId("driver"),
        position: driverLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: "Driver (Start)"),
      ));
      _markers.add(Marker(
        markerId: const MarkerId("restaurant"),
        position: restaurantLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: "Restaurant (First Stop)"),
      ));
      _markers.add(Marker(
        markerId: const MarkerId("customer"),
        position: customerLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: "Customer (Last Stop)"),
      ));
    });
  }

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

  void _startTrip() async {
    setState(() {
      isTripStarted = true;
    });

    String now = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(DateTime.now().toUtc());

    await ordersRef.child(orderId).update({
      'status': 'out for delivery',
      'timestamps/driverAssigned': now,
    });

    await ordersRef.child(orderId).child('updateLogs').push().set({
      'timestamp': now,
      'status': 'out for delivery',
      'note': 'Status updated to out for delivery by driver',
    });

    _drawRoute();
  }

  void _markArrived() async {
    String now = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(DateTime.now().toUtc());

    await ordersRef.child(orderId).update({
      'status': 'delivered',
      'timestamps/delivered': now,
    });

    await ordersRef.child(orderId).child('updateLogs').push().set({
      'timestamp': now,
      'status': 'delivered',
      'note': 'Status updated to delivered by driver',
    });

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DriverHomeScreen()),
    );
  }

  void _drawRoute() {
    if (driverLatLng == null || restaurantLatLng == null || customerLatLng == null) {
      return;
    }
    _polylines.clear();
    _polylines.add(Polyline(
      polylineId: const PolylineId("route"),
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
        title: const Text("Driver Delivery",),
        backgroundColor: const Color(0xFFE37D2B),
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
              initialCameraPosition: const CameraPosition(
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
                Visibility(
                  visible: !isTripStarted,
                  child: ElevatedButton(
                    onPressed: _startTrip,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Start Trip', style: TextStyle(color: Colors.black)),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _markArrived,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Mark as Arrived', style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          ),
        ],
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

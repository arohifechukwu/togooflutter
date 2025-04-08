import 'package:firebase_database/firebase_database.dart';
import 'location_coordinates.dart';
import 'operating_hours.dart';

class Restaurant {
  String? id;
  String? name;
  String? address;
  String? imageUrl;
  String? email;
  double rating;
  double distanceKm;
  int etaMinutes;
  LocationCoordinates? location;
  String? restaurantLicense;
  String? retailLicense;
  Map<String, OperatingHours>? operatingHours;

  // 🔹 Default constructor (required for Firebase)
  Restaurant({
    this.id,
    this.name,
    this.address,
    this.imageUrl,
    this.email,
    this.rating = 4.5,
    this.distanceKm = 0.0,
    this.etaMinutes = 0,
    this.location,
    this.restaurantLicense,
    this.retailLicense,
    this.operatingHours,
  });

  // 🔹 Main constructor used in app logic (Firebase usually doesn't use this)
  Restaurant.withDetails({
    required String id,
    required String name,
    required String address,
    required String imageUrl,
    required LocationCoordinates location,
    required Map<String, OperatingHours> operatingHours,
    required double rating,
    required double distanceKm,
    required int etaMinutes,
  }) : this(
    id: id,
    name: name,
    address: address,
    imageUrl: imageUrl,
    location: location,
    operatingHours: operatingHours,
    rating: rating,
    distanceKm: distanceKm,
    etaMinutes: etaMinutes,
  );

  // Factory constructor to create Restaurant from a Map
  factory Restaurant.fromMap(Map<String, dynamic> map, {required String id}) {
    return Restaurant(
      id: id,
      name: map['name'] as String?,
      address: map['address'] as String?,
      imageUrl: map['imageURL'] as String?,
      email: map['email'] as String?,
      rating: (map['rating'] ?? 4.5).toDouble(),
      distanceKm: (map['distanceKm'] ?? 0.0).toDouble(),
      etaMinutes: map['etaMinutes'] ?? 0,
      // Optionally parse location and operatingHours here if needed.
    );
  }

  // Static method to create a Restaurant from a Firebase DataSnapshot.
  static Restaurant? fromSnapshot(DataSnapshot snapshot) {
    final data = snapshot.value as Map<dynamic, dynamic>?;
    if (data == null) return null;
    return Restaurant.fromMap(Map<String, dynamic>.from(data), id: snapshot.key!);
  }


  // 🔹 Getters
  String? get getId => id;
  String? get getName => name;
  String? get getAddress => address;
  String? get getImageUrl => imageUrl;
  String? get getEmail => email;
  String? get getRestaurantLicense => restaurantLicense;
  String? get getRetailLicense => retailLicense;
  LocationCoordinates? get getLocation => location;
  Map<String, OperatingHours>? get getOperatingHours => operatingHours;
  double get getRating => rating;
  double get getDistanceKm => distanceKm;
  int get getEtaMinutes => etaMinutes;

  // 🔹 Setters
  void setId(String id) {
    this.id = id;
  }

  void setName(String name) {
    this.name = name;
  }

  void setAddress(String address) {
    this.address = address;
  }

  void setImageUrl(String imageUrl) {
    this.imageUrl = imageUrl;
  }

  void setEmail(String email) {
    this.email = email;
  }

  void setRestaurantLicense(String restaurantLicense) {
    this.restaurantLicense = restaurantLicense;
  }

  void setRetailLicense(String retailLicense) {
    this.retailLicense = retailLicense;
  }

  void setLocation(LocationCoordinates location) {
    this.location = location;
  }

  void setOperatingHours(Map<String, OperatingHours> operatingHours) {
    this.operatingHours = operatingHours;
  }

  // Setter for rating that handles both String and numeric inputs
  void setRating(dynamic rating) {
    if (rating is String) {
      try {
        this.rating = double.parse(rating);
      } catch (e) {
        this.rating = 4.5; // Default rating
        print("Invalid rating format: $rating");
      }
    } else if (rating is double) {
      this.rating = rating;
    } else {
      this.rating = 4.5;
    }
  }

  // Setter for distanceKm that handles both String and numeric inputs
  void setDistanceKm(dynamic distanceKm) {
    if (distanceKm is String) {
      try {
        this.distanceKm = double.parse(distanceKm);
      } catch (e) {
        this.distanceKm = 0.0;
        print("Invalid distanceKm format: $distanceKm");
      }
    } else if (distanceKm is double) {
      this.distanceKm = distanceKm;
    } else {
      this.distanceKm = 0.0;
    }
  }

  void setEtaMinutes(int etaMinutes) {
    this.etaMinutes = etaMinutes;
  }

  // 🔹 Convenience methods
  double getLatitudeAsDouble() {
    return location != null ? location!.getLatitudeAsDouble() : 0.0;
  }

  double getLongitudeAsDouble() {
    return location != null ? location!.getLongitudeAsDouble() : 0.0;
  }
}
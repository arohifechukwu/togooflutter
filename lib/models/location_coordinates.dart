class LocationCoordinates {
  double? latitude;
  double? longitude;

  // Default constructor (required for Firebase)
  LocationCoordinates();

  // Optional parameterized constructor
  LocationCoordinates.withCoordinates(this.latitude, this.longitude);

  // Getters for raw values
  double? get getLatitude => latitude;
  double? get getLongitude => longitude;

  // Setter for latitude that handles String or numeric inputs
  void setLatitude(dynamic lat) {
    if (lat is String) {
      try {
        latitude = double.parse(lat);
      } catch (e) {
        latitude = 0.0;
        print("Invalid latitude format: $lat");
      }
    } else if (lat is double) {
      latitude = lat;
    } else if (lat is int) {
      latitude = lat.toDouble();
    } else {
      latitude = 0.0;
    }
  }

  // Setter for longitude that handles String or numeric inputs
  void setLongitude(dynamic lng) {
    if (lng is String) {
      try {
        longitude = double.parse(lng);
      } catch (e) {
        longitude = 0.0;
        print("Invalid longitude format: $lng");
      }
    } else if (lng is double) {
      longitude = lng;
    } else if (lng is int) {
      longitude = lng.toDouble();
    } else {
      longitude = 0.0;
    }
  }

  // Convenience method to return latitude as a non-nullable double
  double getLatitudeAsDouble() {
    return latitude ?? 0.0;
  }

  // Convenience method to return longitude as a non-nullable double
  double getLongitudeAsDouble() {
    return longitude ?? 0.0;
  }
}
import '../models/restaurant.dart';

class RestaurantHelper {
  static Restaurant? _currentRestaurant;

  /// Sets the globally accessible restaurant.
  static void setCurrentRestaurant(Restaurant restaurant) {
    _currentRestaurant = restaurant;
  }

  /// Returns the globally accessible restaurant.
  static Restaurant? getCurrentRestaurant() {
    return _currentRestaurant;
  }

  /// Returns the selected restaurant if available, otherwise returns the current restaurant.
  static Restaurant? resolveSelectedRestaurant(Restaurant? selectedRestaurant) {
    return selectedRestaurant ?? _currentRestaurant;
  }

  /// Checks if a restaurant has been set.
  static bool isRestaurantSet() {
    return _currentRestaurant != null;
  }
}
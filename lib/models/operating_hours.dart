class OperatingHours {
  String? open;
  String? close;

  // Default constructor (required for Firebase)
  OperatingHours();

  // Parameterized constructor
  OperatingHours.withTimes(String open, String close) {
    this.open = open;
    this.close = close;
  }

  // Factory constructor to create an OperatingHours from a Map.
  factory OperatingHours.fromMap(Map<String, dynamic> map) {
    return OperatingHours.withTimes(
      map['open']?.toString() ?? "",
      map['close']?.toString() ?? "",
    );
  }

  // Getters
  String? getOpen() => open;
  String? getClose() => close;
}
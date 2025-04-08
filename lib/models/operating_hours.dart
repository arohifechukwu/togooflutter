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

  // Getters
  String? getOpen() => open;
  String? getClose() => close;
}
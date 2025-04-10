class Driver {
  String? id;
  String? name;
  String? email;
  String? phone;
  String? address;
  String? role;
  String? status;
  String? driverLicense;
  String? vehicleRegistration;
  String? imageURL;

  // Default constructor
  Driver();

  // Named constructor with required fields
  Driver.withDetails({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.role,
    required this.status,
    required this.driverLicense,
    required this.vehicleRegistration,
    required this.imageURL,
  });

  // Factory constructor to create from Firebase data
  factory Driver.fromMap(Map<String, dynamic> map, {String? id}) {
    return Driver.withDetails(
      id: id ?? map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      role: map['role'] ?? '',
      status: map['status'] ?? '',
      driverLicense: map['driverLicense'] ?? '',
      vehicleRegistration: map['vehicleRegistration'] ?? '',
      imageURL: map['imageURL'] ?? '',
    );
  }

  // Convert this object to a map for saving to Firebase
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "email": email,
      "phone": phone,
      "address": address,
      "role": role,
      "status": status,
      "driverLicense": driverLicense,
      "vehicleRegistration": vehicleRegistration,
      "imageURL": imageURL,
    };
  }
}
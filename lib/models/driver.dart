// class Driver {
//   String? id;
//   String? name;
//   String? email;
//   String? phone;
//   String? address;
//   String? role;
//   String? status;
//   String? driverLicense;
//   String? vehicleRegistration;
//   String? imageURL;
//
//   // Default constructor (required for Firebase)
//   Driver();
//
//   // Parameterized constructor
//   Driver.withDetails({
//     required this.id,
//     required this.name,
//     required this.email,
//     required this.phone,
//     required this.address,
//     required this.role,
//     required this.status,
//     required this.driverLicense,
//     required this.vehicleRegistration,
//     required this.imageURL,
//   });
//
//   // Getters
//   String? get getId => id;
//   String? get getName => name;
//   String? get getEmail => email;
//   String? get getPhone => phone;
//   String? get getAddress => address;
//   String? get getRole => role;
//   String? get getStatus => status;
//   String? get getDriverLicense => driverLicense;
//   String? get getVehicleRegistration => vehicleRegistration;
//   String? get getImageURL => imageURL;
//
//   // Setters
//   void setId(String id) {
//     this.id = id;
//   }
//
//   void setName(String name) {
//     this.name = name;
//   }
//
//   void setEmail(String email) {
//     this.email = email;
//   }
//
//   void setPhone(String phone) {
//     this.phone = phone;
//   }
//
//   void setAddress(String address) {
//     this.address = address;
//   }
//
//   void setRole(String role) {
//     this.role = role;
//   }
//
//   void setStatus(String status) {
//     this.status = status;
//   }
//
//   void setDriverLicense(String driverLicense) {
//     this.driverLicense = driverLicense;
//   }
//
//   void setVehicleRegistration(String vehicleRegistration) {
//     this.vehicleRegistration = vehicleRegistration;
//   }
//
//   void setImageURL(String imageURL) {
//     this.imageURL = imageURL;
//   }
// }



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
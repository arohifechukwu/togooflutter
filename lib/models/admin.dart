class Admin {
  String? id;
  String? name;
  String? email;
  String? phone;
  String? address;
  String? role;
  String? status;
  String? imageURL;

  // Default constructor (required for Firebase)
  Admin();

  // Parameterized constructor
  Admin.withDetails({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.role,
    required this.status,
    required this.imageURL,
  });

  // Getters
  String? get getId => id;
  String? get getName => name;
  String? get getEmail => email;
  String? get getPhone => phone;
  String? get getAddress => address;
  String? get getRole => role;
  String? get getStatus => status;
  String? get getImageURL => imageURL;

  // Setters
  void setId(String id) {
    this.id = id;
  }

  void setName(String name) {
    this.name = name;
  }

  void setEmail(String email) {
    this.email = email;
  }

  void setPhone(String phone) {
    this.phone = phone;
  }

  void setAddress(String address) {
    this.address = address;
  }

  void setRole(String role) {
    this.role = role;
  }

  void setStatus(String status) {
    this.status = status;
  }

  void setImageURL(String imageURL) {
    this.imageURL = imageURL;
  }
}
class Customer {
  String? id;
  String? name;
  String? phone;
  String? address;

  // Default constructor (required for Firebase)
  Customer();

  // Parameterized constructor
  Customer.withDetails({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
  });

  // 🔧 Add this factory constructor
  factory Customer.fromMap(Map<String, dynamic> map, {required String id}) {
    return Customer.withDetails(
      id: id,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
    );
  }

  // Optional: convert back to map if needed for saving
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
    };
  }

  // Getters
  String? get getId => id;
  String? get getName => name;
  String? get getPhone => phone;
  String? get getAddress => address;

  // Setters
  void setId(String id) {
    this.id = id;
  }

  void setName(String name) {
    this.name = name;
  }

  void setPhone(String phone) {
    this.phone = phone;
  }

  void setAddress(String address) {
    this.address = address;
  }
}
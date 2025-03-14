class UserModel {
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String role;
  final String status;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.role,
    required this.status,
  });

  /// ✅ Factory method to create a user model from Firebase Realtime Database (RTDB)
  factory UserModel.fromRealtimeDB(String id, Map<dynamic, dynamic> data) {
    return UserModel(
      userId: id,
      name: data['name'] ?? 'Unknown',
      email: data['email'] ?? 'No Email',
      phone: data['phone'] ?? 'No Phone',
      address: data['address'] ?? 'No Address',
      role: data['role'] ?? 'Unknown',
      status: data.containsKey('status') ? data['status'] : 'unknown',
    );
  }

  /// ✅ Factory method to create a user model from Firestore document
  factory UserModel.fromFirestore(dynamic document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    return UserModel(
      userId: document.id,
      name: data['name'] ?? 'Unknown',
      email: data['email'] ?? 'No Email',
      phone: data['phone'] ?? 'No Phone',
      address: data['address'] ?? 'No Address',
      role: data['role'] ?? 'Unknown',
      status: data['status'] ?? 'unknown',
    );
  }

  /// ✅ Convert user model to map for storing in Firebase RTDB or Firestore
  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "email": email,
      "phone": phone,
      "address": address,
      "role": role,
      "status": status,
    };
  }

  /// ✅ **Fix: Add `copyWith` method**
  /// This allows updating only specific fields while keeping others unchanged.
  UserModel copyWith({
    String? userId,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? role,
    String? status,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      role: role ?? this.role,
      status: status ?? this.status,
    );
  }
}
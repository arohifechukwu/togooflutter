class UserModel {
  String id;
  String name;
  String email;
  String userBio;
  String userPhotoUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.userBio,
    required this.userPhotoUrl,
  });

  /// Convert JSON from Firebase to `UserModel` object
  factory UserModel.fromMap(Map<dynamic, dynamic> data) {
    return UserModel(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      userBio: data['userBio'] ?? '',
      userPhotoUrl: data['userPhotoUrl'] ?? '',
    );
  }

  /// Convert `UserModel` object to JSON for Firebase
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "email": email,
      "userBio": userBio,
      "userPhotoUrl": userPhotoUrl,
    };
  }
}

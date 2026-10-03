class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String profileImage;
  final dynamic createdAt;
  final dynamic updatedAt;

  const UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    this.phone = '',
    this.profileImage = '',
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      fullName: map['fullName'] ?? map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      profileImage: map['profileImage'] ?? '',
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }

  UserModel copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? profileImage,
  }) {
    return UserModel(
      uid: uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

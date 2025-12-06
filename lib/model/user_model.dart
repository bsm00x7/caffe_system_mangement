class UserModel {
  final String? id;
  final String name;
  final String email;
  final String? profileImageUrl;
  final bool? isAdmin;
  final DateTime? createdAt;

  UserModel({
    required this.email,
    required this.name,
    this.profileImageUrl,
    this.id,
    this.isAdmin,
    this.createdAt,
  });

  factory UserModel.toUserModel(Map<String, dynamic> map) {
    return UserModel(
      id: map["id"],
      email: map['email'] as String,
      name: map['name'] as String,
      profileImageUrl: map['profile_image_url'],
      isAdmin: map['is_admin'] as bool?,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profile_image_url': profileImageUrl,
      'is_admin': isAdmin,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

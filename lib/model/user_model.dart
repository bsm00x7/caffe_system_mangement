class UserModel {
  final String? id;
  final String name;
  final String email;
  final String? profile_image_url;

  UserModel({
    required this.email,
    required this.name,
    this.profile_image_url,
    this.id,
  });

  factory UserModel.toUserModel(Map<String, dynamic> map) {
    return UserModel(
      id: map["id"],
      email: map['email'] as String,
      name: map['name'] as String,
      profile_image_url: map['profile_image_url'] ,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profile_image_url': profile_image_url,
    };
  }
}

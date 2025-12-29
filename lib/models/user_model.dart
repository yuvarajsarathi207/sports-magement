enum UserRole {
  organization,
  player,
}

class UserModel {
  final String id;
  final String email;
  final String mobile;
  final String username;
  final UserRole role;

  UserModel({
    required this.id,
    required this.email,
    required this.mobile,
    required this.username,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      username: json['username'] ?? '',
      role: json['role'] == 'organization' 
          ? UserRole.organization 
          : UserRole.player,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'mobile': mobile,
      'username': username,
      'role': role == UserRole.organization ? 'organization' : 'player',
    };
  }
}


class AdminUser {
  final int? id;
  final String username;
  final bool? isSuperAdmin;
  final DateTime? createdAt;

  AdminUser({
    this.id,
    required this.username,
    this.isSuperAdmin,
    this.createdAt,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'],
      username: json['username'] ?? '',
      isSuperAdmin: json['is_super_admin'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
    };
  }
}

class AdminLogin {
  final String username;
  final String password;

  AdminLogin({required this.username, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}

class AdminCreate {
  final String username;
  final String password;
  final bool isSuperAdmin;

  AdminCreate({
    required this.username,
    required this.password,
    this.isSuperAdmin = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'is_super_admin': isSuperAdmin,
    };
  }
}

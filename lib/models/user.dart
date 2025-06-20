class User {
  final String id;
  final String username;
  final String password;
  final String role; // admin or customer

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'role': role,
    };
  }

  @override
  String toString() {
    return '$username | Role: $role';
  }
}
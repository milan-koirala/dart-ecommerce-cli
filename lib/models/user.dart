// lib/models/user.dart
class User {
  String id;
  String username;
  String password;
  String role;
  String? email;
  String? address;
  String? securityQuestion;
  String? securityAnswer;

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.role,
    this.email,
    this.address,
    this.securityQuestion,
    this.securityAnswer,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'password': password,
    'role': role,
    'email': email,
    'address': address,
    'securityQuestion': securityQuestion,
    'securityAnswer': securityAnswer,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    username: json['username'],
    password: json['password'],
    role: json['role'],
    email: json['email'],
    address: json['address'],
    securityQuestion: json['securityQuestion'],
    securityAnswer: json['securityAnswer'],
  );
}

class RomanUser {
  final int id;
  final String username;
  final String email;
  final String role;
  RomanUser({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
  });
  factory RomanUser.fromJson(Map<String, dynamic> json) {
    return RomanUser(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      role: json['role'],
    );
  }
}

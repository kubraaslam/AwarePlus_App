class User {
  final String username;
  final String email;
  final String? password;
  final DateTime? dob;

  User({required this.username, required this.email, this.password, this.dob});
}
class User {
  final String username;
  final String email;
  final DateTime? dob;
  final String password;

  User({required this.username, required this.email, this.dob, required this.password});
}

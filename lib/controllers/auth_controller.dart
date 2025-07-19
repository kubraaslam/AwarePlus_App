import 'package:aware_plus/models/user.dart';

class AuthController {
  // Simulating a user database
  final List<User> _userDB = [];

  // Signup method
  Future<bool> signup(User user) async {
    await Future.delayed(Duration(milliseconds: 300));
    // Check if user already exists
    if (_userDB.any((u) => u.email == user.email)) {
      return false; // Email already registered
    }

    _userDB.add(user);
    return true;
  }

  // Login method
  bool login(String email, String password) {
    return _userDB.any(
      (u) => u.email == email.trim() && u.password == password.trim(),
    );
  }
}

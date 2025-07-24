import 'package:aware_plus/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

class AuthController {
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> signup(User user) async {
    try {
      // Create user in Firebase Auth
      fb_auth.UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: user.email,
            password: user.password!,
          );

      // Save additional data in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'username': user.username,
        'email': user.email,
        'dob': user.dob?.toIso8601String(),
        'createdAt': Timestamp.now(),
      });

      return true;
    } catch (e) {
      // ignore: avoid_print
      print('Signup error: $e');
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      await fb_auth.FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } catch (e) {
      // ignore: avoid_print
      print('Login error: $e');
      return false;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw e.toString();
    }
  }
}

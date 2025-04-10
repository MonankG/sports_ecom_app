import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:sample_app/views/home/homepage.dart';

class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger _logger = Logger();

  Future<void> initialSignUp (String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password.trim()
      );
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<void> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String dob,
    required String password,
  }) async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid) // ✅ Set document ID to user's UID
            .set({
          'first_name': firstName,
          'last_name': lastName,
          'password': password,
          'email': email,
          'phone_number': phone,
          'date_of_birth': dob,
          'createdAt': FieldValue.serverTimestamp(),
          'userId': user.uid, // Optional, for cross-checking
        });

        Get.offAll(() => Homepage());
      }
    } catch (e) {
      _logger.e("Error saving user details: $e");
      throw e;
    }
  }



  // Login user with email and password
  Future<void> loginUser(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } catch (e) {
      _logger.e(e); // Log error with details
      throw e;
    }
  }

  // Logout user
  Future<void> logoutUser() async {
    try {
      await _auth.signOut();
    } catch (e) {
      _logger.e(e); // Log error if logout fails
      throw e;
    }
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}

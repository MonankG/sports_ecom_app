import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:sample_app/views/auth/signupform.dart';
import 'package:sample_app/views/home/homepage.dart';

import '../services/auth_services.dart';
import '../views/auth/login.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  final AuthServices _authServices = AuthServices();

  Rx<User?> firebaseUser = Rx<User?>(null);

  @override
  void onReady() {
    super.onReady();
    firebaseUser.bindStream(FirebaseAuth.instance.authStateChanges());
  }

  Future<void> loginUser(String email, String password) async {
    try {
      await _authServices.loginUser(email, password);
      Get.snackbar("Success", "Logged in successfully!");
      Get.offAll(() => Homepage()); // Navigate to home page after login
    } catch (e) {
      Get.snackbar("Error", "Invalid email or password");
    }
  }

  Future<void> initialSignUp(String email, String password) async {
    try {
      await _authServices.initialSignUp(email, password);
      Get.snackbar("Success", "Signed In successfully!");
      Get.offAll(() => UserDetailsFormPage());
    } catch (e) {
      Get.snackbar("Error", "Invalid email or password");
    }
  }

  Future<void> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String dob,
    required String password
  }) async {
    try {
      await _authServices.signUp(
        firstName: firstName,
        lastName: lastName,
        password: password,
        email: email,
        phone: phone,
        dob: dob,
      );
      Get.snackbar("Success", "Account Created Successfully!");
      Get.offAll(() => LoginPage());
    } catch (e) {
      Get.snackbar("Error", "Failed to create your account!");
    }
  }

  // Logout user
  Future<void> logoutUser() async {
    await _authServices.logoutUser();
    Get.offAll(() => LoginPage()); // Navigate back to login page after logout
  }
}

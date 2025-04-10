import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sample_app/controllers/auth_controller.dart';
import 'package:sample_app/controllers/product_controller.dart';
import 'package:sample_app/views/auth/login.dart';
import 'package:sample_app/views/home/homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Register AuthController before the app starts
  Get.put(AuthController());
  Get.put(ProductController());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: Root(),
    );
  }
}

// 🔄 Root widget that listens to Auth state
class Root extends GetWidget<AuthController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.firebaseUser.value == null) {
        return LoginPage(); // 🔐 Not logged in
      } else {
        return Homepage(); // ✅ Logged in
      }
    });
  }
}

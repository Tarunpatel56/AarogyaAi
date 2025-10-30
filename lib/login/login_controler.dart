import 'package:aarogya/home/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginControler extends GetxController {
  final formkey = GlobalKey<FormState>();
  final TextEditingController emailcontroller = TextEditingController();
  final TextEditingController passwordcontroller = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }

  onlogin() {
    //   if (emailcontroller.text.isEmpty || !emailcontroller.text.contains("@")) {
    //     Get.showSnackbar(
    //       GetSnackBar(title: "your email is wrong", message: "Enter your vaild email",duration: Duration(seconds: 3),),
    //     );
    //     return;
    //   }
    //  if (passwordcontroller.text.isEmpty || passwordcontroller.text.length<8) {
    //     Get.showSnackbar(
    //       GetSnackBar(title: "", message: "Enter your vaild password",duration: Duration(seconds: 3),),
    //     );
    //     return;
    //   }

    if (formkey.currentState!.validate()) {
    } else {
      Get.showSnackbar(
        GetSnackBar(
          duration: Duration(milliseconds: 100),
          title: "LOGIN FAIL",
          message: "plz try angin login",
          snackStyle: SnackStyle.FLOATING,
          animationDuration: Duration(milliseconds: 100),
        ),
      );
    }
  }

  Future<void> _login() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailcontroller.text.trim(),
        password: passwordcontroller.text.trim(),
      );

      Get.snackbar(
        "Welcome",
        "Welcome: ${userCredential.user?.email}",
        snackPosition: SnackPosition.BOTTOM,
      );

      // Navigate to Home Page after login

      Get.to(HomeScreen());
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'user-not-found') {
        message = "No user found with this email.";
      } else if (e.code == 'wrong-password') {
        message = "Incorrect password.";
      } else {
        message = "Error: ${e.message}";
        Get.snackbar(
          "LOGIN ERROR",
          message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }
}

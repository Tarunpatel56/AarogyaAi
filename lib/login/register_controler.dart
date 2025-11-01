import 'dart:convert';

import 'package:aarogya/home/home_page.dart';
import 'package:aarogya/login/login_screen.dart';
import 'package:aarogya/utils/snack_bar_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class RegisterControler extends GetxController {
  final box = GetStorage();
  final formkey = GlobalKey<FormState>();
  final TextEditingController emailcontroller = TextEditingController();
  final TextEditingController passwordcontroller = TextEditingController();
  final TextEditingController confromcontroller = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  onReg() {
    if (emailcontroller.text.isEmpty ||
        emailcontroller.text.contains("@gmail.com")) {
      SnackBarUtils.showSnack;
      return;
    }
    if (passwordcontroller.text.isEmpty || passwordcontroller.text.length < 8) {
      Get.showSnackbar(
        GetSnackBar(title: "not same password", message: "comfrom password"),
      );
      return;
    }
    if (confromcontroller.text.isEmpty || confromcontroller.text.length < 8) {
      Get.showSnackbar(
        GetSnackBar(
          title: "enter your vaild password",
          message: "comfrom password",
          duration: Duration(),
        ),
      );
      return;
    }
  }

  Future<void> createAccount() async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: emailcontroller.text.trim(),
        password: passwordcontroller.text.trim(),
      );

      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Text("Account Created: ${userCredential.user?.email}"),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'weak-password') {
        message = "Password is too weak.";
      } else if (e.code == 'email-already-in-use') {
        message = "Email is already in use.";
      } else if (e.code == 'invalid-email') {
        message = "Invalid email address.";
      } else {
        message = "Error: ${e.message}";
      }
      Get.off(LoginScreen());
      emailcontroller.clear();
      passwordcontroller.clear();
      confromcontroller.clear();

      ScaffoldMessenger.of(
        Get.context!,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  googleLogin() async {
    const List<String> scopes = <String>[
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ];
    final GoogleSignIn signIn = GoogleSignIn.instance;

    await signIn.initialize(
      serverClientId:
          "120899676261-cef1prvtrseid9seo6do20uivrla8ach.apps.googleusercontent.com",
    );
    final GoogleSignInAccount? user = await signIn.authenticate(
      scopeHint: scopes,
    );

    print("==========================");

    print(user?.displayName);
    print(user?.photoUrl);
    print(user?.email);

    if (user == null) return;
    await saveDetailsOnDB(user.id, {
      "socialId": user.id,
      "name": user.displayName,
      "email": user.email,
      "image": user.photoUrl,
    });
    Get.offAll(HomeScreen());

    // await SPref().saveUserData(UserModel.fromJson(
    //   {
    //     "socialId": user.id,
    //     "name": user.displayName,
    //     "email": user.email,
    //     "image": user.photoUrl,
    //   }
    // ));

    // _navigateToLogin(Get.context);
  }

  Future<void> saveDetailsOnDB(
    String socialId,
    Map<String, dynamic> userData,
  ) async {
    final CollectionReference userCollection = _firebaseFirestore.collection(
      "users",
    );

    final query = await userCollection
        .where("socialId", isEqualTo: socialId)
        .get();

    if (query.docs.isEmpty) {
      await userCollection.add(userData);
    } else {
      await userCollection.doc(query.docs.first.id).update(userData);
    }
  }

  void saveUser() {
    if (onReg()) return;

    final user = {
      'name': emailcontroller.text.trim(),
      'email': passwordcontroller.text.trim(),
      'password': confromcontroller.text.trim(),
      'createdAt': DateTime.now().toIso8601String(),
    };

    // save current logged in user as well (optional)
    box.write('current_user', jsonEncode(user));

    Get.snackbar(
      'Success',
      'Registration saved',
      snackPosition: SnackPosition.BOTTOM,
    );

    // clear form or navigate
    emailcontroller.clear();
    passwordcontroller.clear();
    confromcontroller.clear();

    // Navigate to profile page (example)
    Get.off(LoginScreen());
  }
}

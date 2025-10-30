import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:get/get.dart';

class RegisterControler extends GetxController{
  final formkey = GlobalKey<FormState>();
  final TextEditingController emailcontroller = TextEditingController();
  final TextEditingController passwordcontroller = TextEditingController();
    final TextEditingController confromcontroller = TextEditingController();
    final FirebaseAuth auth = FirebaseAuth.instance;



  //   Future<void> _createAccount() async {
  //   try {
  //     UserCredential userCredential = await auth.createUserWithEmailAndPassword(
  //       email: emailcontroller.text.trim(),
  //       password: passwordcontroller.text.trim(),
  //     );

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text("Account Created: ${userCredential.user?.email}"),
  //       ),
  //     );
  //   } on FirebaseAuthException catch (e) {
  //     String message = '';
  //     if (e.code == 'weak-password') {
  //       message = "Password is too weak.";
  //     } else if (e.code == 'email-already-in-use') {
  //       message = "Email is already in use.";
  //     } else if (e.code == 'invalid-email') {
  //       message = "Invalid email address.";
  //     } else {
  //       message = "Error: ${e.message}";
  //     }

  //     ScaffoldMessenger.of(
  //       context
  //     ).showSnackBar(SnackBar(content: Text(message)));
  //   }
  // }
  // googleLogin(context) async {
  //   const List<String> scopes = <String>[
  //     'email',
  //     'https://www.googleapis.com/auth/contacts.readonly',
  //   ];
  //   final GoogleSignIn signIn = GoogleSignIn.instance;

  //   await signIn.initialize(
  //     serverClientId:
  //         "391545280397-tmb5lqeah6edkvo64llhg2m7pbpcu3ub.apps.googleusercontent.com",
  //   );
  //   final GoogleSignInAccount? user = await signIn.authenticate(
  //     scopeHint: scopes,
  //   );

  //   print("==========================");

  //   print(user?.displayName);
  //   print(user?.photoUrl);
  //   print(user?.email);

  //   if (user == null) return;
  //   await saveDetailsOnDB(user.id, {
  //     "socialId": user.id,
  //     "name": user.displayName,
  //     "email": user.email,
  //     "image": user.photoUrl,
  //   });

  //   await SPref().saveUserData(UserModel.fromJson(
  //     {
  //       "socialId": user.id,
  //       "name": user.displayName,
  //       "email": user.email,
  //       "image": user.photoUrl,
  //     }
  //   ));

  //   _navigateToLogin(context);
  // }
}



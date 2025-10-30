import 'dart:convert';

import 'package:aarogya/login/forgot_screen.dart';
import 'package:aarogya/login/login_controler.dart';
import 'package:aarogya/login/register_page.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final LoginControler controller = Get.put(LoginControler());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.05),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: MediaQuery.sizeOf(context).height * 0.25,
                  width: MediaQuery.sizeOf(context).width * 0.5,
                  child: Image.asset("assets/logo3.png"),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.01),

            Text(
              "Welcome back",
              style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.02),
            Form(
              key: controller.formkey,
              child: Column(
                children: [
                  Card(
                    elevation: 5,
                    child: TextFormField(
                      // validator: (value) {
                      //   if (value!.contains("@gmail.com") == false)
                      //     return "enter your valid email";
                      // },
                      controller: controller.emailcontroller,

                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey.shade700,
                            width: 15,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),

                        hintText: "Enter your email",
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.sizeOf(context).height * 0.01),
                  Material(
                    elevation: 10, // 👈 controls how high it looks
                    shadowColor: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                    child: TextFormField(
                      validator: (value) {
                        if (value!.length < 8 == false) {
                          return "enter your vaild password";
                        }
                      },
                      controller: controller.passwordcontroller,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Password",
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.sizeOf(context).height * 0.03),
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.06,
                    width: MediaQuery.sizeOf(context).width * 0.8,

                    child: ElevatedButton(
                      onPressed: () {
                        controller.onlogin();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent.shade700,
                      ),
                      child: Text(
                        "Login",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.03),
            InkWell(
              onTap: () {
                Get.to(ForgotScreen());
              },
              child: RichText(
                text: TextSpan(
                  text: "Forget Password",
                  style: TextStyle(
                    color: Colors.blueAccent.shade700,
                    decoration: TextDecoration.underline,
                    fontSize: 18,
                  ),
                ),
              ),
            ),

            InkWell(
              onTap: () {
                Get.to(RegisterPage());
              },
              child: RichText(
                text: TextSpan(
                  text: "Create Account",
                  style: TextStyle(
                    color: Colors.blueAccent.shade700,
                    decoration: TextDecoration.underline,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.05),

            RichText(
              text: TextSpan(
                text: "Already have account?Login",
                style: TextStyle(
                  color: Colors.blueAccent.shade700,
                  decoration: TextDecoration.underline,
                  fontSize: 18,
                ),
              ),
            ),

            // SizedBox(height: MediaQuery.sizeOf(context).height*0.06,
            //    width: MediaQuery.sizeOf(context).width*0.8,
            //   child: OutlinedButton.icon(onPressed: (){}, label: Text("Continue with Google"),icon: SizedBox(width: MediaQuery.sizeOf(context).width*0.1,
            //   height: MediaQuery.sizeOf(context).width*0.1,
            //     child: Image.asset("assets/google.png")),iconAlignment: IconAlignment.start,),
            // )
          ],
        ),
      ),
    );
  }
}

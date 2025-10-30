import 'package:aarogya/bottom/bottom_bar.dart';
import 'package:aarogya/home/home_page.dart';
import 'package:aarogya/login/register_controler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});
  final RegisterControler controller = Get.put(RegisterControler());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
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
            Text(
              "Create Your Account",
              style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.02),
            Card(
              elevation: 8,
              child: TextFormField(
                controller: controller.emailcontroller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter your email",
                ),
              ),
            ),
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.01),
            Card(
              elevation: 8,
              child: TextFormField(
                controller: controller.passwordcontroller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter your Password",
                ),
              ),
            ),
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.01),
            Card(
              elevation: 8,
              child: TextFormField(
                controller: controller.confromcontroller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter your Conform Password",
                ),
              ),
            ),
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.03),
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.06,
              width: MediaQuery.sizeOf(context).width * 0.8,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent.shade700,
                ),
                child: Text(
                  "Sign up",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.03),

            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.06,
              width: MediaQuery.sizeOf(context).width * 0.8,
              child: OutlinedButton.icon(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.blueAccent.shade700, width: 3),
                ),
                label: Text(
                  "Continue with Google",
                  style: TextStyle(fontSize: 18),
                ),
                icon: SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.08,
                  width: MediaQuery.sizeOf(context).width * 0.08,
                  child: Image.asset("assets/google.png"),
                ),
                iconAlignment: IconAlignment.start,
              ),
            ),
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.02),

            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.06,
              width: MediaQuery.sizeOf(context).width * 0.8,
              child: OutlinedButton.icon(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.blueAccent.shade700, width: 3),
                ),
                label: Text(
                  "Continue with Apple",
                  style: TextStyle(fontSize: 18),
                ),
                icon: SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.08,
                  width: MediaQuery.sizeOf(context).width * 0.08,
                  child: Icon(Icons.apple, size: 35),
                ),
                iconAlignment: IconAlignment.start,
              ),
            ),
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.07),
            InkWell(
              onTap: () {
                Get.to(BottomBar());
              },
              child: RichText(
                text: TextSpan(
                  text: "Already have account?Login",
                  style: TextStyle(
                    color: Colors.blueAccent.shade700,
                    decoration: TextDecoration.underline,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

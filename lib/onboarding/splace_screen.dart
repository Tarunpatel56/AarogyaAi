import 'dart:async';

import 'package:aarogya/bottom/bottom_bar.dart';
import 'package:aarogya/home/home_page.dart';
import 'package:aarogya/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_storage/get_storage.dart';

class SplaceScreen extends StatefulWidget {
  const SplaceScreen({super.key});

  @override
  State<SplaceScreen> createState() => _SplaceScreenState();
}

class _SplaceScreenState extends State<SplaceScreen> {
  @override
  void initState() {
    timeDilation = 5.0;
    // TODO: implement initState
    super.initState();
    Timer(Duration(seconds: 3), () {
      _navigateTOFirst();
    });
  }

  _navigateTOFirst() async {
    GetStorage box = GetStorage();

    final bool isLogin = box.read("isLogin") ?? false;

    print(isLogin);

    if (isLogin) {
      Get.offAll(BottomBar());
    } else {
      Get.off(LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            SizedBox(height: Get.height * 0.3),
            SizedBox(
              height: Get.height * 0.4,
              width: Get.width * 0.5,
              child: Image.asset("assets/logo3.png"),
            ),
          ],
        ),
      ),
    );
  }
}

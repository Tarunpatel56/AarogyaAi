import 'package:aarogya/login/login_screen.dart';
import 'package:aarogya/utils/text_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:introduction_screen/introduction_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _introKey = GlobalKey<IntroductionScreenState>();
  String _status = 'Waiting...';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IntroductionScreen(
        pages: [
          PageViewModel(
            title: '',
            bodyWidget: SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.02,

              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("assets/on1.png"),
                    Text(
                      'Talk to AI Doctor',
                      style: TextStyle(fontSize: 30, color: Colors.black),
                    ),
                    Text(
                      'Anytime, Anywhere',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          PageViewModel(
            title: '',
            bodyWidget: SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.7,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Image.asset('assets/Salesconsulting.png'),
                  Text(
                    'Scan and Diagnose',
                    style: TextStyle(color: Colors.black, fontSize: 30),
                  ),
                  Text(
                    'Offline AI Analysis',
                    style: TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          PageViewModel(
            title: '',
            bodyWidget: SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.7,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/Shoppingbag.png'),
                  Text(
                    'Track Health',
                    style: TextStyle(fontSize: 30, color: Colors.black),
                  ),
                  Text(
                    'Prevent Outbreaks',
                    style: TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
        showSkipButton: true,
        skip: const Text("Skip"),
        next: const Text("Next"),
        done: const Text("Done", style: TextStyle(fontWeight: FontWeight.w700)),
        onDone: () {
          Get.off(LoginScreen());
        },
        onSkip: () {
          Get.off(LoginScreen());
        },
        dotsDecorator: DotsDecorator(
          size: const Size.square(10.0),
          activeSize: const Size(20.0, 10.0),
          activeColor: Theme.of(context).colorScheme.secondary,
          color: Colors.black26,
          spacing: const EdgeInsets.symmetric(horizontal: 3.0),
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
      ),
    );
  }
}

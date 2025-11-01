import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  VoidCallback onPressed;
  String title;
  AppButton({super.key, required this.onPressed, required this.title});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent.shade700,
      ),
      child: Text(title, style: TextStyle(fontSize: 18, color: Colors.white)),
    );
  }
}

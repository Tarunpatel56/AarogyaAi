import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AppTextStyles {
  static TextStyle headingTextStyle = TextStyle(fontSize: 24);
  static TextStyle subHeadingTextStyle = TextStyle(fontSize: 24);
  static TextStyle textStyle18 = TextStyle(fontSize: 24);

  static TextStyle colorHeadingTextStyle({Color? color}) =>
      TextStyle(fontSize: 24, color: color);

  InputDecoration appInputdec()=>  InputDecoration(
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey.shade700, width: 15),
    ),
    errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),

    hintText: "Enter your email",
  );
}

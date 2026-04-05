import 'package:flutter/material.dart';

//* Tiny legacy text wrapper used by older button compositions.
class CustomText extends Text {
  CustomText({super.key, required String data, Color? color})
    : super(data, style: buttonTextStyle(color: color));

  static TextStyle buttonTextStyle({Color? color}) {
    return TextStyle(fontWeight: FontWeight.bold, color: color ?? Colors.white);
  }
}

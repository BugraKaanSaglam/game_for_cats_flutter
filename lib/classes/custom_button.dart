import 'package:flutter/material.dart';

class CustomButton extends ElevatedButton {
  TextStyle buttonTextStyle() {
    return const TextStyle(fontWeight: FontWeight.bold, color: Colors.white);
  }

  CustomButton({super.key, required VoidCallback? onPressed, required Widget child, Color? backgroundColor, Size? fixedSize})
      : super(
          onPressed: onPressed,
          style: gameButtonStyle(fixedSize: fixedSize),
          child: child,
        );
  static ButtonStyle gameButtonStyle({Size? fixedSize}) {
    return ButtonStyle(
      fixedSize: WidgetStatePropertyAll<Size>(fixedSize ?? const Size(200, 40)),
      backgroundColor: const WidgetStatePropertyAll<Color>(Color.fromARGB(255, 255, 97, 62)),
      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 20, vertical: 5)),
    );
  }
}

//* Decorations
import 'package:flutter/material.dart';

InputDecoration formDecoration() {
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(20),
    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.35 * 255)),
  );
  return InputDecoration(
    labelStyle: formTextStyle(),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    floatingLabelStyle: const TextStyle(fontSize: 18, color: Colors.white),
    border: border,
    enabledBorder: border,
    focusedBorder: border.copyWith(
      borderSide: const BorderSide(color: Colors.cyanAccent),
    ),
    errorBorder: border.copyWith(
      borderSide: const BorderSide(color: Colors.redAccent),
    ),
    filled: true,
    fillColor: Colors.white.withValues(alpha: 0.08 * 255),
  );
}

BoxDecoration switchDecoration() {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(20),
    color: Colors.white.withValues(alpha: 0.1 * 255),
    border: Border.all(color: Colors.white.withValues(alpha: 0.35 * 255)),
  );
}

TextStyle formTextStyle() => const TextStyle(
  color: Colors.white,
  fontSize: 18,
  fontWeight: FontWeight.w500,
);

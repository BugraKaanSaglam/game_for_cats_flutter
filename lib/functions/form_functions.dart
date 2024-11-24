//* Decorations
import 'package:flutter/material.dart';

InputDecoration formDecoration() {
  return InputDecoration(
    labelStyle: formTextStyle(),
    contentPadding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
    floatingLabelStyle: const TextStyle(fontSize: 18),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Colors.blueGrey)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Colors.blue)),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Colors.red)),
    filled: true,
    fillColor: Colors.grey.shade200,
  );
}

BoxDecoration switchDecoration() {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(20),
    color: Colors.white,
    border: const Border.fromBorderSide(BorderSide(color: Colors.blueGrey)),
  );
}

TextStyle formTextStyle() => const TextStyle(color: Colors.black, fontSize: 18);

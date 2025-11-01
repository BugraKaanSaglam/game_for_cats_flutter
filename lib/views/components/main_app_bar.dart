import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

AppBar mainAppBar(String title, BuildContext context, {bool hasBackButton = true}) {
  final leading = hasBackButton ? IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/main_screen', (route) => false)) : null;

  return AppBar(
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.8)),
    centerTitle: true,
    leading: leading,
    elevation: 0,
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    systemOverlayStyle: SystemUiOverlayStyle.light,
    shadowColor: Colors.black.withValues(alpha: 0.3 * 255),
    flexibleSpace: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color.fromARGB(255, 226, 142, 16), Color.fromARGB(255, 242, 11, 19)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
    ),
  );
}

TextStyle labelTextStyle() => const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5);
TextStyle normalTextStyle() => const TextStyle(fontSize: 16, color: Colors.white70, height: 1.4);

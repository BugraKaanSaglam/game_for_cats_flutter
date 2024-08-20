import 'package:flutter/material.dart';

AppBar mainAppBar(String title, BuildContext context, {bool hasBackButton = true}) {
  Widget leading = BackButton(onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/main_screen', (route) => false));

  if (hasBackButton) {
    return AppBar(
      title: Text(title),
      centerTitle: true,
      leading: leading,
      elevation: 20,
      shadowColor: Colors.yellowAccent,
      foregroundColor: Colors.white,
    );
  } else {
    return AppBar(
      title: Text(title),
      centerTitle: true,
      elevation: 20,
      shadowColor: Colors.yellowAccent,
      foregroundColor: Colors.white,
    );
  }
}

TextStyle labelTextStyle() => const TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold);
TextStyle normalTextStyle() => const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w300);

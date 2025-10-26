import 'package:flutter/material.dart';

/// Central palette + small helpers that keep the non-game screens consistent.
class PawPalette {
  static const List<List<Color>> playfulBackgrounds = [
    [Color(0xFFFFF8E8), Color(0xFFFFD6E8), Color(0xFFFFA8E1)],
    [Color(0xFFE3FDFD), Color(0xFFCBF1F5), Color(0xFFA6E3E9)],
    [Color(0xFFFFF5D7), Color(0xFFFFE4C4), Color(0xFFFFC3A0)],
    [Color(0xFFE7F0FF), Color(0xFFD5C7FF), Color(0xFFF5C2E7)],
  ];

  static const Color bubbleGum = Color(0xFFFF70A6);
  static const Color grape = Color(0xFF9B5DE5);
  static const Color teal = Color(0xFF00BBF9);
  static const Color lemon = Color(0xFFFEE440);
  static const Color midnight = Color(0xFF2D1E2F);

  static LinearGradient buttonGradient = const LinearGradient(
    colors: [Color(0xFF9B5DE5), Color(0xFF00BBF9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static List<Color> pinkToOrange({double opacity = 1}) => [
    bubbleGum.withValues(alpha: opacity * 255),
    const Color(0xFFFF9770).withValues(alpha: opacity * 255),
  ];

  static List<Color> tealToLemon({double opacity = 1}) => [
    teal.withValues(alpha: opacity * 255),
    lemon.withValues(alpha: opacity * 255),
  ];
}

class PawTextStyles {
  static const TextStyle heading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w900,
    color: Colors.white,
    letterSpacing: 0.4,
  );

  static const TextStyle subheading = TextStyle(
    fontSize: 16,
    color: Colors.white70,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: PawPalette.midnight,
  );

  static const TextStyle cardSubtitle = TextStyle(
    fontSize: 14,
    color: Color(0xFF374151),
    height: 1.4,
  );
}

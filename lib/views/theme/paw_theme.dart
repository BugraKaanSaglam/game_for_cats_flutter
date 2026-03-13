import 'package:flutter/material.dart';

/// Central palette + small helpers that keep the non-game screens consistent.
class PawPalette {
  static const List<List<Color>> playfulBackgrounds = [
    [Color(0xFF140F2D), Color(0xFF372D74), Color(0xFFFF5D8F)],
    [Color(0xFF0D1B2A), Color(0xFF005F73), Color(0xFF00C6A7)],
    [Color(0xFF2A1A13), Color(0xFF6B2D5C), Color(0xFFFF9F1C)],
    [Color(0xFF10131F), Color(0xFF1C355E), Color(0xFF6C63FF)],
  ];

  static const Color bubbleGum = Color(0xFFFF5D8F);
  static const Color grape = Color(0xFF7B61FF);
  static const Color teal = Color(0xFF00C6A7);
  static const Color lemon = Color(0xFFFFD166);
  static const Color tangerine = Color(0xFFFF8C42);
  static const Color midnight = Color(0xFF120B2E);
  static const Color ink = Color(0xFF241B49);
  static const Color surface = Color(0xFFFFFBFF);
  static const Color mist = Color(0xFFF4F7FB);

  static const LinearGradient lightBackground = LinearGradient(
    colors: [Color(0xFFFFF6EC), Color(0xFFF7F5FF), Color(0xFFEFFDF9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient buttonGradient = LinearGradient(
    colors: [Color(0xFFFF5D8F), Color(0xFFFF8C42)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient shellGradient = LinearGradient(
    colors: [Color(0xFF1D133E), Color(0xFF38296B), Color(0xFFFF5D8F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient aquaGlow = LinearGradient(
    colors: [Color(0xFF00C6A7), Color(0xFF00A6FB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static List<Color> pinkToOrange({double opacity = 1}) => [
    bubbleGum.withValues(alpha: opacity),
    tangerine.withValues(alpha: opacity),
  ];

  static List<Color> tealToLemon({double opacity = 1}) => [
    teal.withValues(alpha: opacity),
    lemon.withValues(alpha: opacity),
  ];
}

class PawTextStyles {
  static const TextStyle heading = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w900,
    color: Colors.white,
    height: 1.05,
    letterSpacing: 0.2,
  );

  static const TextStyle subheading = TextStyle(
    fontSize: 16,
    color: Color(0xFFE9E7FF),
    height: 1.45,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: PawPalette.ink,
  );

  static const TextStyle cardSubtitle = TextStyle(
    fontSize: 14,
    color: Color(0xFF4B5563),
    height: 1.4,
  );
}

class PawTheme {
  static ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: PawPalette.bubbleGum,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: PawPalette.mist,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFFFFE6EF),
      indicatorColor: PawPalette.bubbleGum.withValues(alpha: 0.18),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: PawPalette.bubbleGum,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: PawPalette.ink,
        side: const BorderSide(color: Color(0x33241B49)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}

import 'package:flutter/material.dart';

class HuntColors {
  static const ink = Color(0xFF24313A);
  static const royalBlue = Color(0xFF4169E1);
  static const royalBlueDark = Color(0xFF2F4EA6);
  static const inkSoft = Color(0xFF52616B);
  static const paper = Color(0xFFFFFCF5);
  static const paperWarm = Color(0xFFF8F0E2);
  static const field = Color(0xFFE7F0DE);
  static const fieldLine = Color(0xFFCADBBF);
  static const line = Color(0xFFE4D8C8);
  static const lineStrong = Color(0xFFCBBBA7);
  static const moss = Color(0xFF527A55);
  static const mossDark = Color(0xFF36573C);
  static const sun = Color(0xFFF5C76A);
  static const sunLine = Color(0xFFE4AA46);
  static const terracotta = Color(0xFFC86B4A);
  static const coral = Color(0xFFE47E67);
  static const sky = Color(0xFF79A8B5);
  static const night = Color(0xFF182329);
  static const success = Color(0xFF4D875A);
  static const warning = Color(0xFFB2773F);
  static const failure = Color(0xFFB7594F);
  static const List<Color> journalBackground = [
    Color(0xFFF5EFE5),
    Color(0xFFEAF1E5),
  ];
}

class HuntSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

class HuntRadii {
  static const sm = 10.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const pill = 999.0;
}

class HuntMotion {
  static const tap = Duration(milliseconds: 120);
  static const standard = Duration(milliseconds: 280);
  static const entrance = Duration(milliseconds: 420);
  static const field = Duration(milliseconds: 650);
  static const curve = Curves.easeOutCubic;
}

class HuntTextStyles {
  static const display = TextStyle(
    fontSize: 42,
    height: 1.02,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.8,
    color: HuntColors.ink,
  );
  static const pageTitle = TextStyle(
    fontSize: 28,
    height: 1.08,
    fontWeight: FontWeight.w800,
    color: HuntColors.ink,
  );
  static const sectionTitle = TextStyle(
    fontSize: 19,
    height: 1.15,
    fontWeight: FontWeight.w800,
    color: HuntColors.ink,
  );
  static const metric = TextStyle(
    fontSize: 26,
    height: 1,
    fontWeight: FontWeight.w900,
    color: HuntColors.ink,
  );
  static const body = TextStyle(
    fontSize: 16,
    height: 1.5,
    color: HuntColors.ink,
  );
  static const supporting = TextStyle(
    fontSize: 14,
    height: 1.4,
    color: HuntColors.inkSoft,
  );
  static const action = TextStyle(
    fontSize: 15,
    height: 1.1,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.1,
  );
  static const caption = TextStyle(
    fontSize: 12,
    height: 1.2,
    fontWeight: FontWeight.w700,
    color: HuntColors.inkSoft,
  );
  static const eyebrow = TextStyle(
    fontSize: 11,
    height: 1.1,
    fontWeight: FontWeight.w900,
    letterSpacing: 1.2,
    color: HuntColors.moss,
  );
}

class PawTheme {
  static ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: HuntColors.moss,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: HuntColors.paperWarm,
    appBarTheme: const AppBarTheme(
      backgroundColor: HuntColors.ink,
      foregroundColor: HuntColors.paper,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: HuntColors.ink,
        foregroundColor: HuntColors.paper,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HuntRadii.md),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: HuntColors.ink,
        side: const BorderSide(color: HuntColors.lineStrong),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HuntRadii.md),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: HuntColors.paper,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(HuntRadii.md),
        borderSide: const BorderSide(color: HuntColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(HuntRadii.md),
        borderSide: const BorderSide(color: HuntColors.line),
      ),
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}

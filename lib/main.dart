import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:game_for_cats_flutter/enums/enum_functions.dart';
import 'package:game_for_cats_flutter/enums/game_enums.dart';
import 'package:game_for_cats_flutter/screens/credits_screen.dart';
import 'package:game_for_cats_flutter/screens/game_screen.dart';
import 'package:game_for_cats_flutter/screens/howtoplay_screen.dart';
import 'package:game_for_cats_flutter/screens/main_screen.dart';
import 'package:game_for_cats_flutter/screens/settings_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Flame.device.fullScreen();
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => MainAppState();
  static MainAppState? of(BuildContext context) => context.findAncestorStateOfType<MainAppState>();
}

//Language Controller
Language languageCode = Language.english;

class MainAppState extends State<MainApp> {
  void setLocale(int value) {
    setState(() {
      languageCode = getLanguageFromValue(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: gameTheme,
      debugShowCheckedModeBanner: false,
      home: const MainScreen(),
      locale: Locale.fromSubtags(languageCode: languageCode.shortName),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routes: {
        '/main_screen': (context) => const MainScreen(),
        '/settings_screen': (context) => const SettingsScreen(),
        '/credits_screen': (context) => const CreditsScreen(),
        '/howtoplay_screen': (context) => const HowToPlayScreen(),
        '/game_screen': (context) => const GameScreen(),
      },
    );
  }

  ThemeData gameTheme = ThemeData(
    primarySwatch: Colors.blueGrey,
    canvasColor: Colors.green,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: Colors.white, //General Text Color
      onPrimary: Colors.black, //X
      secondary: Colors.black, //X
      onSecondary: Colors.black, //X
      error: Colors.red, //Validation Errors (Not Needed)
      onError: Colors.white, //X
      surface: Colors.deepOrange.shade700, //App Color
      onSurface: Colors.black, //AppBar Text Color
    ),
  );
}

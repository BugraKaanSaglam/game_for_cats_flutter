import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'enums/enum_functions.dart';
import 'enums/game_enums.dart';
import 'screens/credits_screen.dart';
import 'screens/game_screen.dart';
import 'screens/howtoplay_screen.dart';
import 'screens/main_screen.dart';
import 'screens/settings_screen.dart';
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
Color barColor = const Color.fromRGBO(255, 112, 67, 1);

class MainAppState extends State<MainApp> {
  void setLocale(int value) {
    setState(() {
      languageCode = getLanguageFromValue(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.light,
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
    navigationBarTheme: NavigationBarThemeData(backgroundColor: barColor),
    appBarTheme: AppBarTheme(backgroundColor: barColor),
    canvasColor: Colors.grey.shade400,
    visualDensity: VisualDensity.comfortable,
    primaryColor: barColor,
    elevatedButtonTheme: ElevatedButtonThemeData(style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(barColor))),
  );
}

import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'models/database/opc_database_list.dart';
import 'models/enums/enum_functions.dart';
import 'models/enums/game_enums.dart';
import 'views/screens/credits_screen.dart';
import 'views/screens/game_screen.dart';
import 'views/screens/howtoplay_screen.dart';
import 'views/screens/main_screen.dart';
import 'views/screens/settings_screen.dart';
import 'views/screens/activity_screen.dart';
import 'package:game_for_cats_2025/l10n/app_localizations.dart';
import 'routing/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
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
Color appThemeColor = const Color.fromARGB(255, 183, 202, 219);

class MainAppState extends State<MainApp> {
  late final GoRouter _router = GoRouter(
    initialLocation: AppRoutes.main,
    routes: [
      GoRoute(path: AppRoutes.main, builder: (context, state) => const MainScreen()),
      GoRoute(path: AppRoutes.settings, builder: (context, state) => const SettingsScreen()),
      GoRoute(path: AppRoutes.credits, builder: (context, state) => const CreditsScreen()),
      GoRoute(path: AppRoutes.howToPlay, builder: (context, state) => const HowToPlayScreen()),
      GoRoute(
        path: AppRoutes.game,
        builder: (context, state) {
          final database = state.extra as OPCDataBase?;
          return GameScreen(database: database);
        },
      ),
      GoRoute(path: AppRoutes.activity, builder: (context, state) => const ActivityScreen()),
    ],
  );

  void setLocale(int value) {
    setState(() => languageCode = getLanguageFromValue(value));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      themeMode: ThemeMode.light,
      theme: gameTheme,
      debugShowCheckedModeBanner: false,
      locale: Locale.fromSubtags(languageCode: languageCode.shortName),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }

  ThemeData gameTheme = ThemeData(
    navigationBarTheme: NavigationBarThemeData(backgroundColor: appThemeColor),
    appBarTheme: AppBarTheme(backgroundColor: appThemeColor),
    canvasColor: Colors.grey.shade400,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    primaryColor: appThemeColor,
  );
}

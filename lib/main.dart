import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:game_for_cats_2025/l10n/app_localizations.dart';
import 'routing/app_routes.dart';
import 'package:game_for_cats_2025/models/app_settings.dart';
import 'package:game_for_cats_2025/state/app_state.dart';
import 'package:game_for_cats_2025/views/components/loading_screen_view.dart';
import 'package:game_for_cats_2025/views/screens/activity_screen.dart';
import 'package:game_for_cats_2025/views/screens/credits_screen.dart';
import 'package:game_for_cats_2025/views/screens/game_screen.dart';
import 'package:game_for_cats_2025/views/screens/howtoplay_screen.dart';
import 'package:game_for_cats_2025/views/screens/main_screen.dart';
import 'package:game_for_cats_2025/views/screens/onboarding_screen.dart';
import 'package:game_for_cats_2025/views/screens/settings_screen.dart';
import 'package:game_for_cats_2025/views/theme/paw_theme.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState()..initialize(),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppState>();
    _router = GoRouter(
      initialLocation: AppRoutes.loading,
      refreshListenable: appState,
      redirect: (context, state) {
        if (!appState.isReady) return AppRoutes.loading;

        final isOnboarding = state.matchedLocation == AppRoutes.onboarding;
        if (!appState.onboardingComplete && !isOnboarding) {
          return AppRoutes.onboarding;
        }
        if (appState.onboardingComplete && isOnboarding) {
          return AppRoutes.main;
        }
        if (state.matchedLocation == AppRoutes.loading) {
          return AppRoutes.main;
        }
        return null;
      },
      routes: [
        GoRoute(path: AppRoutes.loading, builder: (context, state) => const LoadingScreenView()),
        GoRoute(path: AppRoutes.onboarding, builder: (context, state) => const OnboardingScreen()),
        GoRoute(path: AppRoutes.main, builder: (context, state) => const MainScreen()),
        GoRoute(path: AppRoutes.settings, builder: (context, state) => const SettingsScreen()),
        GoRoute(path: AppRoutes.credits, builder: (context, state) => const CreditsScreen()),
        GoRoute(path: AppRoutes.howToPlay, builder: (context, state) => const HowToPlayScreen()),
        GoRoute(
          path: AppRoutes.game,
          builder: (context, state) {
            final settings = state.extra as AppSettings? ?? context.read<AppState>().settings;
            return GameScreen(settings: settings);
          },
        ),
        GoRoute(path: AppRoutes.activity, builder: (context, state) => const ActivityScreen()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    return MaterialApp.router(
      routerConfig: _router,
      themeMode: ThemeMode.light,
      theme: PawTheme.light,
      debugShowCheckedModeBanner: false,
      locale: appState.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}

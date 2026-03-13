import 'package:flutter/material.dart';
import 'package:game_for_cats_2025/l10n/app_localizations.dart';
import 'package:game_for_cats_2025/models/app_settings.dart';
import 'package:game_for_cats_2025/routing/app_routes.dart';
import 'package:game_for_cats_2025/services/connectivity_service.dart';
import 'package:game_for_cats_2025/state/app_state.dart';
import 'package:game_for_cats_2025/views/theme/paw_theme.dart';
import 'package:game_for_cats_2025/views/widgets/connectivity_banner.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

Widget buildTestApp({
  required Widget child,
  AppState? appState,
  ConnectivityController? connectivityController,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AppState>.value(value: appState ?? FakeAppState()),
      ChangeNotifierProvider<ConnectivityController>.value(
        value: connectivityController ?? ConnectivityController(),
      ),
    ],
    child: MaterialApp(
      theme: PawTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ConnectivityBanner(child: child),
    ),
  );
}

Widget buildRouterTestApp({
  required Widget home,
  AppState? appState,
  ConnectivityController? connectivityController,
}) {
  final router = GoRouter(
    routes: [
      GoRoute(path: AppRoutes.main, builder: (context, state) => home),
      GoRoute(
        path: AppRoutes.about,
        builder: (context, state) =>
            const Scaffold(body: Text('about-destination')),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) =>
            const Scaffold(body: Text('settings-destination')),
      ),
      GoRoute(
        path: AppRoutes.howToPlay,
        builder: (context, state) =>
            const Scaffold(body: Text('howto-destination')),
      ),
      GoRoute(
        path: AppRoutes.credits,
        builder: (context, state) =>
            const Scaffold(body: Text('credits-destination')),
      ),
      GoRoute(
        path: AppRoutes.activity,
        builder: (context, state) =>
            const Scaffold(body: Text('activity-destination')),
      ),
      GoRoute(
        path: AppRoutes.game,
        builder: (context, state) =>
            const Scaffold(body: Text('game-destination')),
      ),
    ],
  );

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AppState>.value(value: appState ?? FakeAppState()),
      ChangeNotifierProvider<ConnectivityController>.value(
        value: connectivityController ?? ConnectivityController(),
      ),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      theme: PawTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) =>
          ConnectivityBanner(child: child ?? const SizedBox.shrink()),
    ),
  );
}

class FakeAppState extends AppState {
  FakeAppState({
    this.ready = true,
    this.onboardingDone = true,
    this.currentSettings,
    this.error,
  });

  final bool ready;
  final bool onboardingDone;
  final AppSettings? currentSettings;
  final Object? error;

  @override
  AppSettings? get settings => currentSettings ?? AppSettings.defaults();

  @override
  bool get onboardingComplete => onboardingDone;

  @override
  bool get isReady => ready;

  @override
  Object? get initError => error;
}

class TestConnectivityController extends ConnectivityController {
  TestConnectivityController(ConnectionStateStatus initialStatus)
    : _status = initialStatus;

  ConnectionStateStatus _status;

  @override
  ConnectionStateStatus get status => _status;

  @override
  bool get isOffline => _status == ConnectionStateStatus.offline;

  void setStatus(ConnectionStateStatus value) {
    _status = value;
    notifyListeners();
  }
}

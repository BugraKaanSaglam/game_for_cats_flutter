import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:game_for_cats_2025/models/app_settings.dart';
import 'package:game_for_cats_2025/views/screens/main_screen.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('renders core menu actions', (tester) async {
    tester.view.physicalSize = const Size(1440, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      buildRouterTestApp(
        home: const MainScreen(),
        appState: FakeAppState(currentSettings: AppSettings.defaults()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('Start Hunt'), findsOneWidget);
    expect(find.text("Today's hunt setup"), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Hunt Journal'), findsOneWidget);
    expect(find.text('How It Works'), findsOneWidget);
    expect(find.text('About the Game'), findsOneWidget);
  });

  testWidgets('navigates to about route from menu', (tester) async {
    tester.view.physicalSize = const Size(1440, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      buildRouterTestApp(
        home: const MainScreen(),
        appState: FakeAppState(currentSettings: AppSettings.defaults()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 700));

    await tester.tap(find.text('About the Game'));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    expect(find.text('about-destination'), findsOneWidget);
  });

  testWidgets('renders without overflow on compact phone width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(750, 1334);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      buildRouterTestApp(
        home: const MainScreen(),
        appState: FakeAppState(currentSettings: AppSettings.defaults()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('Start Hunt'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

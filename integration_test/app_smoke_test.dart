import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:game_for_cats_2025/models/app_settings.dart';
import 'package:game_for_cats_2025/services/connectivity_service.dart';
import 'package:game_for_cats_2025/views/screens/main_screen.dart';
import 'package:integration_test/integration_test.dart';

import '../test/helpers/test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('main menu can navigate to about screen', (tester) async {
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
        connectivityController: TestConnectivityController(
          ConnectionStateStatus.online,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('About App'), findsOneWidget);

    await tester.tap(find.text('About App'));
    await tester.pumpAndSettle();

    expect(find.text('about-destination'), findsOneWidget);
  });
}

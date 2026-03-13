import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:game_for_cats_2025/services/app_info_service.dart';
import 'package:game_for_cats_2025/services/connectivity_service.dart';
import 'package:game_for_cats_2025/views/components/loading_screen_view.dart';
import 'package:game_for_cats_2025/views/screens/about_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../helpers/test_app.dart';

void main() {
  setUp(() {
    AppInfoService.instance.overrideLoader(() async {
      return PackageInfo(
        appName: 'Mice and Paws',
        packageName: 'com.example.game_for_cats',
        version: '3.5.0',
        buildNumber: '35',
        buildSignature: '',
      );
    });
  });

  tearDown(() {
    AppInfoService.instance.reset();
  });

  testWidgets('loading screen matches golden', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestApp(child: const LoadingScreenView()));
    await tester.pump(const Duration(milliseconds: 100));

    await expectLater(
      find.byType(LoadingScreenView),
      matchesGoldenFile('goldens/loading_screen.png'),
    );
  });

  testWidgets('about screen matches golden', (tester) async {
    tester.view.physicalSize = const Size(1440, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      buildTestApp(
        child: const AboutScreen(),
        connectivityController: TestConnectivityController(
          ConnectionStateStatus.online,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(AboutScreen),
      matchesGoldenFile('goldens/about_screen.png'),
    );
  });
}

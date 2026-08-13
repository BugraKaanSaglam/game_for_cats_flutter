import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mice_and_paws_cat_game/views/screens/onboarding_screen.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('onboarding stays usable on a compact phone', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      buildTestApp(child: const OnboardingScreen(), appState: FakeAppState()),
    );
    await tester.pump(const Duration(milliseconds: 120));

    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Next'));
    await tester.pump(const Duration(milliseconds: 350));

    expect(tester.takeException(), isNull);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_for_cats_2025/views/components/loading_screen_view.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('startup splash uses the full-screen splash asset', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestApp(child: const StartupSplashView()));

    expect(find.byType(Image), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });

  testWidgets('shows loading indicator and localized label', (tester) async {
    await tester.pumpWidget(buildTestApp(child: const LoadingScreenView()));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Loading...'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_for_cats_2025/services/app_info_service.dart';
import 'package:game_for_cats_2025/services/connectivity_service.dart';
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

  testWidgets('renders app info, connectivity and crash reporting cards', (
    tester,
  ) async {
    final connectivity = TestConnectivityController(
      ConnectionStateStatus.online,
    );

    await tester.pumpWidget(
      buildTestApp(
        child: const AboutScreen(),
        connectivityController: connectivity,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('App Info'), findsOneWidget);
    expect(find.text('Build Details'), findsOneWidget);
    expect(
      find.byWidgetPredicate(_richTextContains('3.5.0+35')),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(_richTextContains('com.example.game_for_cats')),
      findsOneWidget,
    );
    expect(find.text('Connectivity'), findsOneWidget);
    expect(find.text('Online'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('Crash Reporting'), findsOneWidget);
    expect(
      find.byWidgetPredicate(_richTextContains('Not configured')),
      findsOneWidget,
    );
    expect(find.text('Share App'), findsWidgets);
  });
}

WidgetPredicate _richTextContains(String value) {
  return (widget) =>
      widget is RichText && widget.text.toPlainText().contains(value);
}

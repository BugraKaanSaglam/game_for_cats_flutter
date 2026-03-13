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

  testWidgets('renders app info and connectivity cards', (tester) async {
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
    expect(find.text('Store Links'), findsOneWidget);
    expect(find.text('Google Play'), findsOneWidget);
    expect(find.text('App Store'), findsOneWidget);
    expect(find.text('Connectivity'), findsOneWidget);
    expect(find.text('Online'), findsOneWidget);
  });
}

WidgetPredicate _richTextContains(String value) {
  return (widget) =>
      widget is RichText && widget.text.toPlainText().contains(value);
}

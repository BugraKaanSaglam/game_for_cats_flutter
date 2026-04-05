import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_for_cats_2025/services/app_info_service.dart';
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

  testWidgets('renders about story and build details', (tester) async {
    await tester.pumpWidget(buildTestApp(child: const AboutScreen()));
    await tester.pumpAndSettle();

    expect(find.text('About the Game'), findsWidgets);
    expect(find.text('Why this game exists'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('What makes it distinct'),
      240,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('What makes it distinct'), findsOneWidget);
    expect(
      find.byWidgetPredicate(_richTextContains('3.5.0+35')),
      findsOneWidget,
    );
  });
}

WidgetPredicate _richTextContains(String value) {
  return (widget) =>
      widget is RichText && widget.text.toPlainText().contains(value);
}

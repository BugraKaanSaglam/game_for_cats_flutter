import 'package:flutter_test/flutter_test.dart';
import 'package:game_for_cats_2025/services/app_info_service.dart';
import 'package:game_for_cats_2025/views/screens/credits_screen.dart';
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

  testWidgets('renders creator info and app version card', (tester) async {
    await tester.pumpWidget(buildTestApp(child: const CreditsScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Creators'), findsOneWidget);
    expect(find.text('Buğra Kaan Sağlam'), findsOneWidget);
    expect(find.text('Share the game'), findsOneWidget);
    expect(find.textContaining('Version: 3.5.0+35'), findsOneWidget);
    expect(find.text('Share App'), findsWidgets);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mice_and_paws_cat_game/views/screens/settings_screen.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('accessibility controls are real persisted-setting controls', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestApp(child: const SettingsScreen()));
    await tester.pumpAndSettle();

    final scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.text('Accessibility'),
      500,
      scrollable: scrollable,
    );
    await tester.pumpAndSettle();
    expect(find.text('Accessibility'), findsOneWidget);
    final label = find.text('Reduced motion');
    final tile = find.ancestor(
      of: label,
      matching: find.byType(SwitchListTile),
    );

    expect(tile, findsOneWidget);
    expect(tester.widget<SwitchListTile>(tile).value, isFalse);

    final toggle = find.descendant(of: tile, matching: find.byType(Switch));
    await tester.scrollUntilVisible(toggle, 200, scrollable: scrollable);
    await tester.pumpAndSettle();
    await tester.tap(toggle);
    await tester.pump();

    expect(tester.widget<SwitchListTile>(tile).value, isTrue);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_for_cats_2025/services/connectivity_service.dart';
import 'package:game_for_cats_2025/views/widgets/connectivity_banner.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('shows offline banner only when controller is offline', (
    tester,
  ) async {
    final connectivity = TestConnectivityController(
      ConnectionStateStatus.online,
    );

    await tester.pumpWidget(
      buildTestApp(
        child: const Scaffold(body: SizedBox.shrink()),
        connectivityController: connectivity,
      ),
    );
    await tester.pumpAndSettle();

    expect(_currentOpacity(tester), 0);

    connectivity.setStatus(ConnectionStateStatus.offline);
    await tester.pumpAndSettle();

    expect(_currentOpacity(tester), 1);
    expect(find.byType(ConnectivityBanner), findsOneWidget);
  });
}

double _currentOpacity(WidgetTester tester) {
  final widget = tester.widget<AnimatedOpacity>(
    find.descendant(
      of: find.byType(ConnectivityBanner),
      matching: find.byType(AnimatedOpacity),
    ),
  );
  return widget.opacity;
}

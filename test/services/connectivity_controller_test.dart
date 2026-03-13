import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_for_cats_2025/services/connectivity_service.dart';

void main() {
  group('ConnectivityController', () {
    test(
      'initializes as online when at least one network is available',
      () async {
        final controller = ConnectivityController(
          service: FakeConnectivityService(
            initialResults: [ConnectivityResult.wifi],
          ),
        );

        await controller.initialize();

        expect(controller.status, ConnectionStateStatus.online);
        expect(controller.isOffline, isFalse);
        controller.dispose();
      },
    );

    test('initializes as offline when there is no network', () async {
      final controller = ConnectivityController(
        service: FakeConnectivityService(
          initialResults: [ConnectivityResult.none],
        ),
      );

      await controller.initialize();

      expect(controller.status, ConnectionStateStatus.offline);
      expect(controller.isOffline, isTrue);
      controller.dispose();
    });

    test('reacts to connectivity changes from stream', () async {
      final service = FakeConnectivityService(
        initialResults: [ConnectivityResult.wifi],
      );
      final controller = ConnectivityController(service: service);

      await controller.initialize();
      service.emit([ConnectivityResult.none]);
      await Future<void>.delayed(Duration.zero);

      expect(controller.status, ConnectionStateStatus.offline);
      service.emit([ConnectivityResult.mobile]);
      await Future<void>.delayed(Duration.zero);
      expect(controller.status, ConnectionStateStatus.online);

      controller.dispose();
      await service.close();
    });
  });
}

class FakeConnectivityService extends ConnectivityService {
  FakeConnectivityService({required List<ConnectivityResult> initialResults})
    : _initialResults = initialResults;

  final List<ConnectivityResult> _initialResults;
  final StreamController<List<ConnectivityResult>> _controller =
      StreamController<List<ConnectivityResult>>.broadcast();

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => _initialResults;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _controller.stream;

  void emit(List<ConnectivityResult> results) {
    _controller.add(results);
  }

  Future<void> close() async {
    await _controller.close();
  }
}

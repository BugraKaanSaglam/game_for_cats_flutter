import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

enum ConnectionStateStatus { online, offline, unknown }

class ConnectivityService {
  ConnectivityService({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  Future<List<ConnectivityResult>> checkConnectivity() {
    return _connectivity.checkConnectivity();
  }

  Stream<List<ConnectivityResult>> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged;
  }
}

class ConnectivityController extends ChangeNotifier {
  ConnectivityController({ConnectivityService? service})
    : _service = service ?? ConnectivityService();

  final ConnectivityService _service;

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  ConnectionStateStatus _status = ConnectionStateStatus.unknown;

  ConnectionStateStatus get status => _status;
  bool get isOffline => _status == ConnectionStateStatus.offline;

  Future<void> initialize() async {
    final results = await _service.checkConnectivity();
    _updateStatus(results);
    _subscription ??= _service.onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final nextStatus =
        results.any((result) => result != ConnectivityResult.none)
        ? ConnectionStateStatus.online
        : ConnectionStateStatus.offline;

    if (nextStatus == _status) return;
    _status = nextStatus;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

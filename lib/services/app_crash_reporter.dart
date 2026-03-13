import 'dart:async';

import 'package:sentry_flutter/sentry_flutter.dart';

class AppCrashReporter {
  AppCrashReporter._();

  static const String _dsn = String.fromEnvironment('SENTRY_DSN');

  static bool get isConfigured => _dsn.isNotEmpty;

  static String get statusLabel =>
      isConfigured ? 'configured' : 'not_configured';

  static Future<void> initialize(FutureOr<void> Function() appRunner) async {
    if (!isConfigured) {
      await appRunner();
      return;
    }

    await SentryFlutter.init((options) {
      options.dsn = _dsn;
      options.tracesSampleRate = 0.1;
      options.profilesSampleRate = 0.0;
      options.attachScreenshot = false;
      options.attachViewHierarchy = false;
      options.sendDefaultPii = false;
    }, appRunner: () async => await appRunner());
  }

  static Future<void> capture(
    Object error,
    StackTrace stackTrace, {
    String? reason,
  }) async {
    if (!isConfigured) return;
    await Sentry.captureException(
      error,
      stackTrace: stackTrace,
      withScope: (scope) {
        if (reason != null && reason.isNotEmpty) {
          scope.setTag('reason', reason);
        }
      },
    );
  }

  static Future<SentryId?> sendTestEvent() async {
    if (!isConfigured) return null;
    try {
      throw StateError('Manual test event from About screen');
    } catch (error, stackTrace) {
      return Sentry.captureException(error, stackTrace: stackTrace);
    }
  }
}

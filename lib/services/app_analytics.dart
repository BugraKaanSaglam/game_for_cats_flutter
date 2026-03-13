import 'package:game_for_cats_2025/services/app_crash_reporter.dart';
import 'package:game_for_cats_2025/services/app_logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

enum AnalyticsEvent {
  appLaunched,
  screenViewed,
  onboardingSkipped,
  onboardingNextTapped,
  onboardingCompleted,
  gameStarted,
  settingsSaved,
  appShared,
  resultShared,
}

class AppAnalytics {
  AppAnalytics._();

  static void track(
    AnalyticsEvent event, {
    Map<String, Object?> parameters = const {},
  }) {
    final payload = parameters.isEmpty ? '' : ' $parameters';
    AppLogger.info('analytics.${event.name}$payload');

    if (!AppCrashReporter.isConfigured) return;

    Sentry.addBreadcrumb(
      Breadcrumb(
        category: 'analytics',
        type: 'info',
        message: event.name,
        data: parameters.map(
          (key, value) => MapEntry(key, value?.toString() ?? 'null'),
        ),
      ),
    );
  }

  static void screenView(String screenName) {
    track(
      AnalyticsEvent.screenViewed,
      parameters: <String, Object?>{'screen': screenName},
    );
  }
}

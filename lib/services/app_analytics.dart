import 'package:game_for_cats_2025/services/app_logger.dart';

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
  }

  static void screenView(String screenName) {
    track(
      AnalyticsEvent.screenViewed,
      parameters: <String, Object?>{'screen': screenName},
    );
  }
}

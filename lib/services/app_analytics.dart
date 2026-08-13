import 'package:mice_and_paws_cat_game/services/app_logger.dart';

/// Typed local analytics facade that can later be backed by an SDK.
enum AnalyticsEvent {
  appLaunched,
  screenViewed,
  onboardingSkipped,
  onboardingNextTapped,
  onboardingCompleted,
  gameStarted,
  settingsSaved,
}

class AppAnalytics {
  AppAnalytics._();

  // ? Keeping this API stable means a real analytics SDK could replace the logger later without touching screens.
  static void track(
    AnalyticsEvent event, {
    Map<String, Object?> parameters = const {},
  }) {
    final payload = parameters.isEmpty ? '' : ' $parameters';
    AppLogger.info('analytics.${event.name}$payload');
  }

  static void screenView(String screenName) {
    // ! Screen views are normalized through one helper so naming stays consistent.
    track(
      AnalyticsEvent.screenViewed,
      parameters: <String, Object?>{'screen': screenName},
    );
  }
}

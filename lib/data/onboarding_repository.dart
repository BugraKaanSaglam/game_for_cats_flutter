import 'package:shared_preferences/shared_preferences.dart';

/// Persists the one-time onboarding completion flag.
class OnboardingRepository {
  static const String _key = 'onboarding_complete';

  Future<bool> isCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  Future<void> setCompleted(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
  }
}

import 'package:flutter/material.dart';
import 'package:game_for_cats_2025/data/app_settings_repository.dart';
import 'package:game_for_cats_2025/data/onboarding_repository.dart';
import 'package:game_for_cats_2025/models/app_settings.dart';
import 'package:game_for_cats_2025/models/enums/enum_functions.dart';
import 'package:game_for_cats_2025/services/app_analytics.dart';
import 'package:game_for_cats_2025/services/app_logger.dart';

//* AppState is the single app-wide source of truth for:
//* - persisted settings
//* - onboarding completion
//* - startup readiness / init errors
class AppState extends ChangeNotifier {
  AppState({
    AppSettingsRepository? settingsRepository,
    OnboardingRepository? onboardingRepository,
  }) : _settingsRepository = settingsRepository ?? AppSettingsRepository(),
       _onboardingRepository = onboardingRepository ?? OnboardingRepository();

  final AppSettingsRepository _settingsRepository;
  final OnboardingRepository _onboardingRepository;

  AppSettings? _settings;
  bool _onboardingComplete = false;
  bool _isReady = false;
  Object? _initError;

  AppSettings? get settings => _settings;
  bool get onboardingComplete => _onboardingComplete;
  bool get isReady => _isReady;
  Object? get initError => _initError;

  //? Locale is derived instead of stored separately so language settings cannot drift.
  Locale? get locale {
    final current = _settings;
    if (current == null) return null;
    return Locale.fromSubtags(languageCode: current.language.shortName);
  }

  Future<void> initialize() async {
    //* Reset startup flags each time initialize runs so loading / retry UIs stay honest.
    _isReady = false;
    _initError = null;
    notifyListeners();

    try {
      AppLogger.info('Initializing app state');
      //! Onboarding and settings come from two different persistence layers.
      _onboardingComplete = await _onboardingRepository.isCompleted();
      _settings = await _settingsRepository.fetchOrCreate();
      //? getTimeFromValue also updates the global round timer used by the Flame layer.
      getTimeFromValue(_settings?.time);
      AppLogger.info('App state initialized successfully');
    } catch (error) {
      _initError = error;
      AppLogger.error('App state initialization failed', error);
    } finally {
      _isReady = true;
      notifyListeners();
    }
  }

  Future<void> updateSettings(AppSettings settings) async {
    //* We optimistically update local state first so the UI feels immediate.
    _settings = settings;
    getTimeFromValue(settings.time);
    notifyListeners();
    try {
      await _settingsRepository.save(settings);
      AppLogger.info('Settings updated');
      AppAnalytics.track(
        AnalyticsEvent.settingsSaved,
        parameters: <String, Object?>{
          'languageCode': settings.languageCode,
          'time': settings.time,
          'difficulty': settings.difficulty,
          'muted': settings.muted,
          'lowPower': settings.lowPower,
        },
      );
    } catch (error, stackTrace) {
      AppLogger.error('Saving settings failed', error, stackTrace);
      rethrow;
    }
  }

  Future<void> completeOnboarding() async {
    //! This flag affects routing immediately, so listeners are notified before persistence finishes.
    _onboardingComplete = true;
    notifyListeners();
    await _onboardingRepository.setCompleted(true);
    AppLogger.info('Onboarding completed');
    AppAnalytics.track(AnalyticsEvent.onboardingCompleted);
  }
}

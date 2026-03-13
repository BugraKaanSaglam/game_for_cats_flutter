import 'package:flutter/material.dart';
import 'package:game_for_cats_2025/data/app_settings_repository.dart';
import 'package:game_for_cats_2025/data/onboarding_repository.dart';
import 'package:game_for_cats_2025/models/app_settings.dart';
import 'package:game_for_cats_2025/models/enums/enum_functions.dart';
import 'package:game_for_cats_2025/services/app_analytics.dart';
import 'package:game_for_cats_2025/services/app_logger.dart';

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

  Locale? get locale {
    final current = _settings;
    if (current == null) return null;
    return Locale.fromSubtags(languageCode: current.language.shortName);
  }

  Future<void> initialize() async {
    _isReady = false;
    _initError = null;
    notifyListeners();

    try {
      AppLogger.info('Initializing app state');
      _onboardingComplete = await _onboardingRepository.isCompleted();
      _settings = await _settingsRepository.fetchOrCreate();
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
    _onboardingComplete = true;
    notifyListeners();
    await _onboardingRepository.setCompleted(true);
    AppLogger.info('Onboarding completed');
    AppAnalytics.track(AnalyticsEvent.onboardingCompleted);
  }
}

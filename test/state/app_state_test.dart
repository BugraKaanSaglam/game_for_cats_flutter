import 'package:flutter_test/flutter_test.dart';
import 'package:game_for_cats_2025/data/app_settings_repository.dart';
import 'package:game_for_cats_2025/data/onboarding_repository.dart';
import 'package:game_for_cats_2025/models/app_settings.dart';
import 'package:game_for_cats_2025/models/enums/game_enums.dart';
import 'package:game_for_cats_2025/models/global/global_variables.dart';
import 'package:game_for_cats_2025/state/app_state.dart';

void main() {
  group('AppState', () {
    late FakeAppSettingsRepository settingsRepository;
    late FakeOnboardingRepository onboardingRepository;

    setUp(() {
      gameTimer = 100;
      settingsRepository = FakeAppSettingsRepository(
        current: AppSettings.defaults().copyWith(
          languageCode: Language.turkish.value,
          time: Time.twohundered.value,
        ),
      );
      onboardingRepository = FakeOnboardingRepository(initialValue: false);
    });

    test('initialize loads repositories and exposes locale', () async {
      final appState = AppState(
        settingsRepository: settingsRepository,
        onboardingRepository: onboardingRepository,
      );

      await appState.initialize();

      expect(appState.isReady, isTrue);
      expect(appState.initError, isNull);
      expect(appState.onboardingComplete, isFalse);
      expect(appState.settings, settingsRepository.current);
      expect(appState.locale?.languageCode, 'tr');
      expect(gameTimer, Time.twohundered.value);
    });

    test('updateSettings persists the new settings', () async {
      final appState = AppState(
        settingsRepository: settingsRepository,
        onboardingRepository: onboardingRepository,
      );
      await appState.initialize();

      final nextSettings = settingsRepository.current.copyWith(
        time: Time.sandbox.value,
        muted: true,
      );

      await appState.updateSettings(nextSettings);

      expect(appState.settings, nextSettings);
      expect(settingsRepository.savedSettings, nextSettings);
      expect(gameTimer, Time.sandbox.value);
    });

    test('completeOnboarding updates state and repository', () async {
      final appState = AppState(
        settingsRepository: settingsRepository,
        onboardingRepository: onboardingRepository,
      );
      await appState.initialize();

      await appState.completeOnboarding();

      expect(appState.onboardingComplete, isTrue);
      expect(onboardingRepository.savedValue, isTrue);
    });

    test('initialize exposes error when repository throws', () async {
      final appState = AppState(
        settingsRepository: ThrowingAppSettingsRepository(),
        onboardingRepository: onboardingRepository,
      );

      await appState.initialize();

      expect(appState.isReady, isTrue);
      expect(appState.settings, isNull);
      expect(appState.initError, isNotNull);
    });
  });
}

class FakeAppSettingsRepository extends AppSettingsRepository {
  FakeAppSettingsRepository({required this.current});

  AppSettings current;
  AppSettings? savedSettings;

  @override
  Future<AppSettings> fetchOrCreate() async => current;

  @override
  Future<void> save(AppSettings settings) async {
    savedSettings = settings;
    current = settings;
  }
}

class ThrowingAppSettingsRepository extends AppSettingsRepository {
  @override
  Future<AppSettings> fetchOrCreate() async {
    throw StateError('settings load failed');
  }
}

class FakeOnboardingRepository extends OnboardingRepository {
  FakeOnboardingRepository({required bool initialValue})
    : _value = initialValue;

  bool _value;
  bool? savedValue;

  @override
  Future<bool> isCompleted() async => _value;

  @override
  Future<void> setCompleted(bool value) async {
    savedValue = value;
    _value = value;
  }
}

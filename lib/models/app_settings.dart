import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:game_for_cats_2025/models/enums/enum_functions.dart';
import 'package:game_for_cats_2025/models/enums/game_enums.dart';

part 'app_settings.freezed.dart';

/// Immutable settings model persisted locally and exposed through AppState.
@freezed
abstract class AppSettings with _$AppSettings {
  const AppSettings._();

  const factory AppSettings({
    required int version,
    required int languageCode,
    required double musicVolume,
    required double characterVolume,
    required int time,
    required int difficulty,
    required String backgroundPath,
    required bool muted,
    required bool lowPower,
    @Default(false) bool reducedMotion,
    @Default(false) bool highContrast,
    @Default(false) bool largerTargets,
    @Default(false) bool haptics,
  }) = _AppSettings;

  // ! Defaults define the first-run experience and must stay aligned with the DB schema.
  factory AppSettings.defaults() => AppSettings(
    version: 0,
    languageCode: Language.english.value,
    musicVolume: 0.5,
    characterVolume: 1,
    time: Time.fifty.value,
    difficulty: Difficulty.easy.value,
    backgroundPath: '',
    muted: false,
    lowPower: false,
    reducedMotion: false,
    highContrast: false,
    largerTargets: false,
    haptics: false,
  );

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      version: map['Ver'] as int,
      languageCode: map['LanguageCode'] as int,
      musicVolume: (map['MusicVolume'] as num).toDouble(),
      characterVolume: (map['CharacterVolume'] as num).toDouble(),
      time: map['Time'] as int,
      difficulty: (map['Difficulty'] as int?) ?? Difficulty.easy.value,
      backgroundPath: (map['BackgroundPath'] as String?) ?? '',
      muted: (map['Mute'] ?? 0) == 1,
      lowPower: (map['LowPower'] ?? 0) == 1,
      reducedMotion: (map['ReducedMotion'] ?? 0) == 1,
      highContrast: (map['HighContrast'] ?? 0) == 1,
      largerTargets: (map['LargerTargets'] ?? 0) == 1,
      haptics: (map['Haptics'] ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() => {
    'Ver': version,
    'LanguageCode': languageCode,
    'MusicVolume': musicVolume,
    'CharacterVolume': characterVolume,
    'Time': time,
    'Difficulty': difficulty,
    'BackgroundPath': backgroundPath,
    'Mute': muted ? 1 : 0,
    'LowPower': lowPower ? 1 : 0,
    'ReducedMotion': reducedMotion ? 1 : 0,
    'HighContrast': highContrast ? 1 : 0,
    'LargerTargets': largerTargets ? 1 : 0,
    'Haptics': haptics ? 1 : 0,
  };

  // ? UI code can ask for the semantic enum instead of manually decoding the stored int.
  Language get language => getLanguageFromValue(languageCode);
}

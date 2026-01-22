import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:game_for_cats_2025/models/enums/enum_functions.dart';
import 'package:game_for_cats_2025/models/enums/game_enums.dart';
import 'package:game_for_cats_2025/models/global/global_variables.dart';

part 'app_settings.freezed.dart';

@freezed
class AppSettings with _$AppSettings {
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
  }) = _AppSettings;

  factory AppSettings.defaults() => AppSettings(
        version: databaseVersion,
        languageCode: Language.english.value,
        musicVolume: 0.5,
        characterVolume: 1,
        time: Time.fifty.value,
        difficulty: Difficulty.easy.value,
        backgroundPath: '',
        muted: false,
        lowPower: false,
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
      };

  Language get language => getLanguageFromValue(languageCode);
}

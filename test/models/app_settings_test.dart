import 'package:flutter_test/flutter_test.dart';
import 'package:game_for_cats_2025/models/app_settings.dart';
import 'package:game_for_cats_2025/models/enums/game_enums.dart';
import 'package:game_for_cats_2025/models/global/global_variables.dart';

void main() {
  group('AppSettings', () {
    test('defaults returns expected baseline values', () {
      final settings = AppSettings.defaults();

      expect(settings.version, databaseVersion);
      expect(settings.languageCode, Language.english.value);
      expect(settings.musicVolume, 0.5);
      expect(settings.characterVolume, 1);
      expect(settings.time, Time.fifty.value);
      expect(settings.difficulty, Difficulty.easy.value);
      expect(settings.backgroundPath, isEmpty);
      expect(settings.muted, isFalse);
      expect(settings.lowPower, isFalse);
      expect(settings.language, Language.english);
    });

    test('toMap and fromMap preserve persisted fields', () {
      const settings = AppSettings(
        version: 7,
        languageCode: 0,
        musicVolume: 0.2,
        characterVolume: 0.8,
        time: 200,
        difficulty: 2,
        backgroundPath: '/tmp/background.png',
        muted: true,
        lowPower: true,
      );

      final roundTrip = AppSettings.fromMap(settings.toMap());

      expect(roundTrip, settings);
      expect(roundTrip.language, Language.turkish);
    });
  });
}

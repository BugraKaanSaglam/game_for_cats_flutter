class OPCDataBase {
  OPCDataBase({
    required this.ver,
    required this.languageCode,
    required this.musicVolume,
    required this.characterVolume,
    required this.time,
    required this.difficulty,
    required this.backgroundPath,
    required this.muted,
    required this.lowPower,
  });

  late int ver;
  late int languageCode;
  late double musicVolume;
  late double characterVolume;
  late int time;
  late int difficulty;
  late String backgroundPath;
  late bool muted;
  late bool lowPower;

  Map<String, dynamic> toMap() => {
        'Ver': ver,
        'LanguageCode': languageCode,
        'MusicVolume': musicVolume,
        'CharacterVolume': characterVolume,
        'Time': time,
        'Difficulty': difficulty,
        'BackgroundPath': backgroundPath,
        'Mute': muted ? 1 : 0,
        'LowPower': lowPower ? 1 : 0,
      };

  OPCDataBase.fromMap(Map<String, dynamic> map) {
    ver = map['Ver'];
    languageCode = map['LanguageCode'];
    musicVolume = map['MusicVolume'];
    characterVolume = map['CharacterVolume'];
    time = map['Time'];
    difficulty = map['Difficulty'] ?? 0;
    backgroundPath = map['BackgroundPath'] ?? '';
    muted = (map['Mute'] ?? 0) == 1;
    lowPower = (map['LowPower'] ?? 0) == 1;
  }

  // Implement toString to make it easier to see information about each column when using the print statement.
  @override
  String toString() =>
      '{Ver: $ver ,LanguageCode: $languageCode, MusicVolume: $musicVolume, CharacterVolume: $characterVolume, Time: $time, Difficulty: $difficulty, BackgroundPath: $backgroundPath, Muted: $muted, LowPower: $lowPower}';
}

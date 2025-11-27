class OPCDataBase {
  OPCDataBase({
    required this.ver,
    required this.languageCode,
    required this.musicVolume,
    required this.characterVolume,
    required this.time,
    required this.difficulty,
  });

  late int ver;
  late int languageCode;
  late double musicVolume;
  late double characterVolume;
  late int time;
  late int difficulty;

  Map<String, dynamic> toMap() => {
        'Ver': ver,
        'LanguageCode': languageCode,
        'MusicVolume': musicVolume,
        'CharacterVolume': characterVolume,
        'Time': time,
        'Difficulty': difficulty,
      };

  OPCDataBase.fromMap(Map<String, dynamic> map) {
    ver = map['Ver'];
    languageCode = map['LanguageCode'];
    musicVolume = map['MusicVolume'];
    characterVolume = map['CharacterVolume'];
    time = map['Time'];
    difficulty = map['Difficulty'] ?? 0;
  }

  // Implement toString to make it easier to see information about each column when using the print statement.
  @override
  String toString() =>
      '{Ver: $ver ,LanguageCode: $languageCode, MusicVolume: $musicVolume, CharacterVolume: $characterVolume, Time: $time, Difficulty: $difficulty}';
}

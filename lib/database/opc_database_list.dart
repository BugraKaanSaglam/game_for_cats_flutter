class OPCDataBase {
  OPCDataBase({required this.ver, required this.languageCode, required this.musicVolume, required this.characterVolume, required this.time});
  late int ver;
  late int languageCode;
  late double musicVolume;
  late double characterVolume;
  late int time;

  Map<String, dynamic> toMap() => {'Ver': ver, 'LanguageCode': languageCode, 'MusicVolume': musicVolume, 'CharacterVolume': characterVolume, 'Time': time};

  OPCDataBase.fromMap(Map<String, dynamic> map) {
    ver = map['Ver'];
    languageCode = map['LanguageCode'];
    musicVolume = map['MusicVolume'];
    characterVolume = map['CharacterVolume'];
    time = map['Time'];
  }

  // Implement toString to make it easier to see information about each column when using the print statement.
  @override
  String toString() => '{Ver: $ver ,LanguageCode: $languageCode, MusicVolume: $musicVolume, CharacterVolume: $characterVolume, Time: $time}';
}

import 'game_enums.dart';

//* Mapper helpers between stored ints and semantic enums.
Language getLanguageFromValue(int? value) {
  switch (value) {
    case 0:
      return Language.turkish;
    case 1:
      return Language.english;
    default:
      return Language.english;
  }
}

Difficulty getDifficultyFromValue(int? value) {
  switch (value) {
    case 0:
      return Difficulty.easy;
    case 1:
      return Difficulty.medium;
    case 2:
      return Difficulty.hard;
    case 3:
      return Difficulty.sandbox;
    default:
      return Difficulty.easy;
  }
}

Time getTimeFromValue(int? value) {
  switch (value) {
    case 50:
      return Time.fifty;
    case 100:
      return Time.hundered;
    case 200:
      return Time.twohundered;
    case 100000:
      return Time.sandbox;
    default:
      return Time.fifty;
  }
}

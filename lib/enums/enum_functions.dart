import 'package:game_for_cats_flutter/enums/game_enums.dart';
import 'package:game_for_cats_flutter/global/global_variables.dart';

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
      gameTimer = 50;
      return Time.fifty;
    case 100:
      gameTimer = 100;
      return Time.hundered;
    case 200:
      gameTimer = 200;
      return Time.twohundered;
    case 100000:
      gameTimer = 100000;
      return Time.sandbox;
    default:
      gameTimer = value ?? 50;
      return Time.fifty;
  }
}

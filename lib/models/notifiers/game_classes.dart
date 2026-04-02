import 'package:flutter/foundation.dart';

class GameClicksCounter extends ChangeNotifier {
  int totalTaps = 0;
  int miceTaps = 0;
  int bugTaps = 0;
  int currentStreak = 0;
  int bestStreak = 0;

  void reset() {
    totalTaps = 0;
    bugTaps = 0;
    miceTaps = 0;
    currentStreak = 0;
    bestStreak = 0;
    notifyListeners();
  }

  void recordMiceTap() {
    miceTaps++;
    totalTaps++;
    _advanceStreak();
    notifyListeners();
  }

  void recordBugTap() {
    bugTaps++;
    totalTaps++;
    _advanceStreak();
    notifyListeners();
  }

  void recordMissTap() {
    totalTaps++;
    currentStreak = 0;
    notifyListeners();
  }

  void _advanceStreak() {
    currentStreak++;
    if (currentStreak > bestStreak) {
      bestStreak = currentStreak;
    }
  }
}

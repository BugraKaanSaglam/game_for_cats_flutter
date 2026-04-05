import 'package:flutter/foundation.dart';

//* Reactive counter shared by the Flame game and Flutter HUD widgets.
//! The game writes into this notifier; the HUD only listens.
class GameClicksCounter extends ChangeNotifier {
  int totalTaps = 0;
  int miceTaps = 0;
  int bugTaps = 0;
  int currentStreak = 0;
  int bestStreak = 0;

  void reset() {
    //* Restarting a round must fully zero the stats and the visible streak state.
    totalTaps = 0;
    bugTaps = 0;
    miceTaps = 0;
    currentStreak = 0;
    bestStreak = 0;
    notifyListeners();
  }

  void recordMiceTap() {
    //? Successful taps advance both the visible combo and the persisted round result.
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
    //! Misses still count as interaction volume, but they intentionally break the combo.
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

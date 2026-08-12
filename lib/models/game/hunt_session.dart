import 'package:flutter/foundation.dart';

enum HuntTarget { mice, bug }

enum HuntCompletionReason { timer, manual }

class HuntRoundClock {
  HuntRoundClock({required this.durationSeconds});

  final int durationSeconds;
  int elapsedSeconds = 0;
  bool isPaused = false;

  bool get isComplete => elapsedSeconds >= durationSeconds;

  bool tick() {
    if (isPaused || isComplete) return isComplete;
    elapsedSeconds++;
    if (elapsedSeconds > durationSeconds) elapsedSeconds = durationSeconds;
    return isComplete;
  }

  void pause() => isPaused = true;

  void resume() => isPaused = false;

  void reset() {
    elapsedSeconds = 0;
    isPaused = false;
  }
}

class HuntSessionState extends ChangeNotifier {
  int elapsedSeconds = 0;
  int totalTaps = 0;
  int miceTaps = 0;
  int bugTaps = 0;
  int wrongTaps = 0;
  int currentStreak = 0;
  int bestStreak = 0;
  HuntTarget? lastTarget;
  bool isPaused = false;

  int get successfulTaps => miceTaps + bugTaps;

  void reset() {
    elapsedSeconds = 0;
    totalTaps = 0;
    miceTaps = 0;
    bugTaps = 0;
    wrongTaps = 0;
    currentStreak = 0;
    bestStreak = 0;
    lastTarget = null;
    isPaused = false;
    notifyListeners();
  }

  void setElapsed(int seconds) {
    elapsedSeconds = seconds;
    notifyListeners();
  }

  void setPaused(bool value) {
    isPaused = value;
    notifyListeners();
  }

  void recordHit(HuntTarget target) {
    totalTaps++;
    if (target == HuntTarget.mice) {
      miceTaps++;
    } else {
      bugTaps++;
    }
    currentStreak++;
    if (currentStreak > bestStreak) bestStreak = currentStreak;
    lastTarget = target;
    notifyListeners();
  }

  void recordMiss() {
    totalTaps++;
    wrongTaps++;
    currentStreak = 0;
    lastTarget = null;
    notifyListeners();
  }

  HuntResult result({
    required int configuredDuration,
    required int difficulty,
    required HuntCompletionReason reason,
  }) {
    return HuntResult(
      startedAt: DateTime.now().subtract(Duration(seconds: elapsedSeconds)),
      durationSeconds: elapsedSeconds,
      configuredDuration: configuredDuration,
      difficulty: difficulty,
      totalTaps: totalTaps,
      miceTaps: miceTaps,
      bugTaps: bugTaps,
      wrongTaps: wrongTaps,
      bestStreak: bestStreak,
      completionReason: reason,
    );
  }
}

class HuntResult {
  HuntResult({
    required this.startedAt,
    required this.durationSeconds,
    required this.configuredDuration,
    required this.difficulty,
    required this.totalTaps,
    required this.miceTaps,
    required this.bugTaps,
    required this.wrongTaps,
    required this.bestStreak,
    required this.completionReason,
  });

  final DateTime startedAt;
  final int durationSeconds;
  final int configuredDuration;
  final int difficulty;
  final int totalTaps;
  final int miceTaps;
  final int bugTaps;
  final int wrongTaps;
  final int bestStreak;
  final HuntCompletionReason completionReason;

  int get successfulTaps => miceTaps + bugTaps;

  int get accuracy => totalTaps == 0
      ? 0
      : ((successfulTaps / totalTaps) * 100).round().clamp(0, 100);
}

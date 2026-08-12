import 'package:flutter_test/flutter_test.dart';
import 'package:game_for_cats_2025/models/database/session_log.dart';
import 'package:game_for_cats_2025/models/game/hunt_session.dart';

void main() {
  test('round-trips a complete Hunt Record', () {
    final timestamp = DateTime(2026, 8, 12, 14, 30);
    final log = SessionLog(
      id: 4,
      dateKey: '2026-08-12',
      timestamp: timestamp,
      durationSeconds: 50,
      configuredDuration: 50,
      difficulty: 2,
      totalTaps: 12,
      successfulTaps: 9,
      miceTaps: 6,
      bugTaps: 3,
      wrongTaps: 3,
      bestStreak: 5,
      completionReason: HuntCompletionReason.timer,
    );

    final roundTrip = SessionLog.fromMap(log.toMap());

    expect(roundTrip.id, 4);
    expect(roundTrip.timestamp, timestamp);
    expect(roundTrip.successfulTaps, 9);
    expect(roundTrip.accuracy, 75);
    expect(roundTrip.completionReason, HuntCompletionReason.timer);
  });

  test('reads legacy history rows with safe defaults', () {
    final log = SessionLog.fromMap({
      'Id': 1,
      'Date': '2026-08-11',
      'TotalTaps': 8,
      'WrongTaps': 3,
    });

    expect(log.totalTaps, 8);
    expect(log.successfulTaps, 5);
    expect(log.durationSeconds, 0);
    expect(log.configuredDuration, 50);
    expect(log.completionReason, HuntCompletionReason.timer);
  });
}

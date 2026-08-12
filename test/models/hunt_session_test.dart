import 'package:flutter_test/flutter_test.dart';
import 'package:game_for_cats_2025/models/game/hunt_session.dart';

void main() {
  group('HuntRoundClock', () {
    test('ticks, pauses, completes, and resets deterministically', () {
      final clock = HuntRoundClock(durationSeconds: 2);

      expect(clock.tick(), isFalse);
      expect(clock.elapsedSeconds, 1);
      clock.pause();
      expect(clock.tick(), isFalse);
      expect(clock.elapsedSeconds, 1);
      clock.resume();
      expect(clock.tick(), isTrue);
      expect(clock.isComplete, isTrue);
      expect(clock.tick(), isTrue);
      clock.reset();
      expect(clock.elapsedSeconds, 0);
      expect(clock.isPaused, isFalse);
      expect(clock.isComplete, isFalse);
    });
  });

  group('HuntSessionState', () {
    test('tracks hits, misses, and the best streak', () {
      final session = HuntSessionState();

      session.recordHit(HuntTarget.mice);
      session.recordHit(HuntTarget.bug);
      session.recordMiss();
      session.recordHit(HuntTarget.mice);

      expect(session.totalTaps, 4);
      expect(session.successfulTaps, 3);
      expect(session.miceTaps, 2);
      expect(session.bugTaps, 1);
      expect(session.wrongTaps, 1);
      expect(session.currentStreak, 1);
      expect(session.bestStreak, 2);
      expect(session.lastTarget, HuntTarget.mice);
    });

    test('result calculates accuracy and preserves completion metadata', () {
      final session = HuntSessionState()..setElapsed(12);
      session.recordHit(HuntTarget.mice);
      session.recordMiss();

      final result = session.result(
        configuredDuration: 50,
        difficulty: 1,
        reason: HuntCompletionReason.manual,
      );

      expect(result.durationSeconds, 12);
      expect(result.configuredDuration, 50);
      expect(result.difficulty, 1);
      expect(result.successfulTaps, 1);
      expect(result.accuracy, 50);
      expect(result.completionReason, HuntCompletionReason.manual);
    });

    test('reset clears the round state', () {
      final session = HuntSessionState()
        ..setElapsed(9)
        ..setPaused(true)
        ..recordHit(HuntTarget.bug);

      session.reset();

      expect(session.elapsedSeconds, 0);
      expect(session.totalTaps, 0);
      expect(session.successfulTaps, 0);
      expect(session.currentStreak, 0);
      expect(session.bestStreak, 0);
      expect(session.lastTarget, isNull);
      expect(session.isPaused, isFalse);
    });

    test('pause state is explicit and observable', () {
      final session = HuntSessionState();
      session.setPaused(true);
      expect(session.isPaused, isTrue);
      session.setPaused(false);
      expect(session.isPaused, isFalse);
    });
  });
}

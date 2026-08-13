import 'package:mice_and_paws_cat_game/models/game/hunt_session.dart';

/// One complete local hunt record stored for the journal.
class SessionLog {
  SessionLog({
    this.id,
    required this.dateKey,
    required this.timestamp,
    required this.durationSeconds,
    required this.configuredDuration,
    required this.difficulty,
    required this.totalTaps,
    required this.successfulTaps,
    required this.miceTaps,
    required this.bugTaps,
    required this.wrongTaps,
    required this.bestStreak,
    required this.completionReason,
  });

  final int? id;
  final String dateKey;
  final DateTime timestamp;
  final int durationSeconds;
  final int configuredDuration;
  final int difficulty;
  final int totalTaps;
  final int successfulTaps;
  final int miceTaps;
  final int bugTaps;
  final int wrongTaps;
  final int bestStreak;
  final HuntCompletionReason completionReason;

  int get accuracy => totalTaps == 0
      ? 0
      : ((successfulTaps / totalTaps) * 100).round().clamp(0, 100);

  Map<String, dynamic> toMap() => {
    'Id': id,
    'Date': dateKey,
    'Timestamp': timestamp.millisecondsSinceEpoch,
    'DurationSeconds': durationSeconds,
    'ConfiguredDuration': configuredDuration,
    'Difficulty': difficulty,
    'TotalTaps': totalTaps,
    'SuccessfulTaps': successfulTaps,
    'MiceTaps': miceTaps,
    'BugTaps': bugTaps,
    'WrongTaps': wrongTaps,
    'BestStreak': bestStreak,
    'CompletionReason': completionReason.name,
  };

  factory SessionLog.fromMap(Map<String, dynamic> map) {
    final total = (map['TotalTaps'] as num?)?.toInt() ?? 0;
    final wrong = (map['WrongTaps'] as num?)?.toInt() ?? 0;
    final timestampValue = (map['Timestamp'] as num?)?.toInt() ?? 0;
    final dateKey = map['Date'] as String? ?? '';
    return SessionLog(
      id: (map['Id'] as num?)?.toInt(),
      dateKey: dateKey,
      timestamp: timestampValue > 0
          ? DateTime.fromMillisecondsSinceEpoch(timestampValue)
          : DateTime.tryParse(dateKey) ?? DateTime.now(),
      durationSeconds: (map['DurationSeconds'] as num?)?.toInt() ?? 0,
      configuredDuration: (map['ConfiguredDuration'] as num?)?.toInt() ?? 50,
      difficulty: (map['Difficulty'] as num?)?.toInt() ?? 0,
      totalTaps: total,
      successfulTaps:
          (map['SuccessfulTaps'] as num?)?.toInt() ??
          (total - wrong).clamp(0, total),
      miceTaps: (map['MiceTaps'] as num?)?.toInt() ?? 0,
      bugTaps: (map['BugTaps'] as num?)?.toInt() ?? 0,
      wrongTaps: wrong,
      bestStreak: (map['BestStreak'] as num?)?.toInt() ?? 0,
      completionReason: HuntCompletionReason.values.firstWhere(
        (reason) => reason.name == map['CompletionReason'],
        orElse: () => HuntCompletionReason.timer,
      ),
    );
  }
}

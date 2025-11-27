class SessionLog {
  SessionLog({
    this.id,
    required this.dateKey,
    required this.totalTaps,
    required this.wrongTaps,
  });

  final int? id;
  final String dateKey; // yyyy-MM-dd
  final int totalTaps;
  final int wrongTaps;

  Map<String, dynamic> toMap() => {
        'Id': id,
        'Date': dateKey,
        'TotalTaps': totalTaps,
        'WrongTaps': wrongTaps,
      };

  factory SessionLog.fromMap(Map<String, dynamic> map) => SessionLog(
        id: map['Id'] as int?,
        dateKey: map['Date'] as String,
        totalTaps: map['TotalTaps'] as int,
        wrongTaps: map['WrongTaps'] as int,
      );
}

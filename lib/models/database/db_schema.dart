import 'package:sqflite/sqflite.dart';

Future<void> createAppSchema(Database db, int version) async {
  await db.execute(
    'CREATE TABLE OPCGameTable(Ver INTEGER not null PRIMARY KEY, LanguageCode INTEGER not null, MusicVolume DOUBLE not null, CharacterVolume DOUBLE not null, Time INTEGER not null, Difficulty INTEGER not null, BackgroundPath TEXT not null, Mute INTEGER not null, LowPower INTEGER not null, ReducedMotion INTEGER not null, HighContrast INTEGER not null, LargerTargets INTEGER not null, Haptics INTEGER not null)',
  );
  await db.execute(
    'CREATE TABLE SessionHistory(Id INTEGER PRIMARY KEY AUTOINCREMENT, Date TEXT not null, Timestamp INTEGER not null, DurationSeconds INTEGER not null, ConfiguredDuration INTEGER not null, Difficulty INTEGER not null, TotalTaps INTEGER not null, SuccessfulTaps INTEGER not null, MiceTaps INTEGER not null, BugTaps INTEGER not null, WrongTaps INTEGER not null, BestStreak INTEGER not null, CompletionReason TEXT not null)',
  );
}

Future<void> upgradeAppSchema(
  Database db,
  int oldVersion,
  int newVersion,
) async {
  // ! Migrations are additive so existing settings and history remain readable.
  if (oldVersion < 2) {
    await db.execute(
      'ALTER TABLE OPCGameTable ADD COLUMN Difficulty INTEGER not null DEFAULT 0',
    );
  }
  if (oldVersion < 3) {
    await db.execute(
      'CREATE TABLE IF NOT EXISTS SessionHistory(Id INTEGER PRIMARY KEY AUTOINCREMENT, Date TEXT not null, TotalTaps INTEGER not null, WrongTaps INTEGER not null)',
    );
  }
  if (oldVersion < 4) {
    await db.execute(
      "ALTER TABLE OPCGameTable ADD COLUMN BackgroundPath TEXT not null DEFAULT ''",
    );
  }
  if (oldVersion < 5) {
    await db.execute(
      'ALTER TABLE OPCGameTable ADD COLUMN Mute INTEGER not null DEFAULT 0',
    );
    await db.execute(
      'ALTER TABLE OPCGameTable ADD COLUMN LowPower INTEGER not null DEFAULT 0',
    );
  }
  if (oldVersion < 6) {
    await db.execute(
      'ALTER TABLE SessionHistory ADD COLUMN Timestamp INTEGER not null DEFAULT 0',
    );
    await db.execute(
      'ALTER TABLE SessionHistory ADD COLUMN DurationSeconds INTEGER not null DEFAULT 0',
    );
    await db.execute(
      'ALTER TABLE SessionHistory ADD COLUMN ConfiguredDuration INTEGER not null DEFAULT 50',
    );
    await db.execute(
      'ALTER TABLE SessionHistory ADD COLUMN Difficulty INTEGER not null DEFAULT 0',
    );
    await db.execute(
      'ALTER TABLE SessionHistory ADD COLUMN SuccessfulTaps INTEGER not null DEFAULT 0',
    );
    await db.execute(
      'UPDATE SessionHistory SET SuccessfulTaps = MAX(TotalTaps - WrongTaps, 0) WHERE SuccessfulTaps = 0 AND TotalTaps > WrongTaps',
    );
    await db.execute(
      'ALTER TABLE SessionHistory ADD COLUMN MiceTaps INTEGER not null DEFAULT 0',
    );
    await db.execute(
      'ALTER TABLE SessionHistory ADD COLUMN BugTaps INTEGER not null DEFAULT 0',
    );
    await db.execute(
      'ALTER TABLE SessionHistory ADD COLUMN BestStreak INTEGER not null DEFAULT 0',
    );
    await db.execute(
      "ALTER TABLE SessionHistory ADD COLUMN CompletionReason TEXT not null DEFAULT 'timer'",
    );
  }
  if (oldVersion < 7) {
    await db.execute(
      'ALTER TABLE OPCGameTable ADD COLUMN ReducedMotion INTEGER not null DEFAULT 0',
    );
    await db.execute(
      'ALTER TABLE OPCGameTable ADD COLUMN HighContrast INTEGER not null DEFAULT 0',
    );
    await db.execute(
      'ALTER TABLE OPCGameTable ADD COLUMN LargerTargets INTEGER not null DEFAULT 0',
    );
    await db.execute(
      'ALTER TABLE OPCGameTable ADD COLUMN Haptics INTEGER not null DEFAULT 0',
    );
  }
}

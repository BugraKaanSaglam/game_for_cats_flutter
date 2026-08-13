import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mice_and_paws_cat_game/models/database/db_schema.dart';
import 'package:mice_and_paws_cat_game/models/database/session_log.dart';
import 'package:mice_and_paws_cat_game/models/game/hunt_session.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  test('creates the current settings and history schema', () async {
    final directory = await Directory.systemTemp.createTemp('mice-paws-db-');
    final path = '${directory.path}/current.db';

    try {
      final db = await databaseFactoryFfi.openDatabase(
        path,
        options: OpenDatabaseOptions(version: 7, onCreate: createAppSchema),
      );
      final settings = await db.rawQuery('PRAGMA table_info(OPCGameTable)');
      final history = await db.rawQuery('PRAGMA table_info(SessionHistory)');

      expect(settings, hasLength(13));
      expect(history, hasLength(13));
      await db.close();
    } finally {
      await databaseFactoryFfi.deleteDatabase(path);
      await directory.delete(recursive: true);
    }
  });

  test('upgrades a legacy database without losing history', () async {
    final directory = await Directory.systemTemp.createTemp('mice-paws-db-');
    final path = '${directory.path}/legacy.db';

    try {
      final legacy = await databaseFactoryFfi.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 3,
          onCreate: (db, version) async {
            await db.execute(
              'CREATE TABLE OPCGameTable(Ver INTEGER not null PRIMARY KEY, LanguageCode INTEGER not null, MusicVolume DOUBLE not null, CharacterVolume DOUBLE not null, Time INTEGER not null, Difficulty INTEGER not null)',
            );
            await db.execute(
              'CREATE TABLE SessionHistory(Id INTEGER PRIMARY KEY AUTOINCREMENT, Date TEXT not null, TotalTaps INTEGER not null, WrongTaps INTEGER not null)',
            );
            await db.insert('OPCGameTable', {
              'Ver': 0,
              'LanguageCode': 1,
              'MusicVolume': 0.5,
              'CharacterVolume': 1.0,
              'Time': 50,
              'Difficulty': 0,
            });
            await db.insert('SessionHistory', {
              'Date': '2026-08-12',
              'TotalTaps': 8,
              'WrongTaps': 3,
            });
          },
        ),
      );
      await legacy.close();

      final upgraded = await databaseFactoryFfi.openDatabase(
        path,
        options: OpenDatabaseOptions(version: 7, onUpgrade: upgradeAppSchema),
      );
      final settingsColumns = await upgraded.rawQuery(
        'PRAGMA table_info(OPCGameTable)',
      );
      final history = await upgraded.query('SessionHistory');
      final legacyLog = SessionLog.fromMap(history.single);

      expect(
        settingsColumns.map((column) => column['name']),
        containsAll(<String>[
          'BackgroundPath',
          'Mute',
          'LowPower',
          'ReducedMotion',
          'HighContrast',
          'LargerTargets',
          'Haptics',
        ]),
      );
      expect(legacyLog.successfulTaps, 5);
      expect(legacyLog.accuracy, 63);
      expect(legacyLog.completionReason, HuntCompletionReason.timer);

      final freshLog = SessionLog(
        dateKey: '2026-08-12',
        timestamp: DateTime(2026, 8, 12),
        durationSeconds: 50,
        configuredDuration: 50,
        difficulty: 1,
        totalTaps: 4,
        successfulTaps: 3,
        miceTaps: 2,
        bugTaps: 1,
        wrongTaps: 1,
        bestStreak: 3,
        completionReason: HuntCompletionReason.timer,
      );
      await upgraded.insert('SessionHistory', freshLog.toMap());
      expect((await upgraded.query('SessionHistory')).length, 2);
      await upgraded.close();
    } finally {
      await databaseFactoryFfi.deleteDatabase(path);
      await directory.delete(recursive: true);
    }
  });
}

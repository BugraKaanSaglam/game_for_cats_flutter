// ignore_for_file: await_only_futures, depend_on_referenced_packages

import 'dart:developer';

import 'package:game_for_cats_2025/models/app_settings.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io' as io;
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:game_for_cats_2025/models/database/session_log.dart';

class DBHelper {
  DBHelper();

  static Database? _db;
  Future<Database?> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDatabase();
    return _db;
  }

  Future<Database> initDatabase() async {
    try {
      String fileName = 'miceandpawsdatabase0.db';
      io.Directory documentDirectory = await getApplicationDocumentsDirectory();
      String path = join(documentDirectory.path, fileName);
      var db = await openDatabase(
        path,
        version: 5,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onOpen: (db) {},
      );
      return db;
    } catch (e) {
      log("Database initialization error: $e");
      throw Exception("Database initialization failed: $e");
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE OPCGameTable(Ver INTEGER not null PRIMARY KEY, LanguageCode INTEGER not null, MusicVolume DOUBLE not null, CharacterVolume DOUBLE not null, Time INTEGER not null, Difficulty INTEGER not null, BackgroundPath TEXT not null, Mute INTEGER not null, LowPower INTEGER not null)',
    );
    await db.execute(
      'CREATE TABLE SessionHistory(Id INTEGER PRIMARY KEY AUTOINCREMENT, Date TEXT not null, TotalTaps INTEGER not null, WrongTaps INTEGER not null)',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
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
        'ALTER TABLE OPCGameTable ADD COLUMN BackgroundPath TEXT not null DEFAULT ""',
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
  }

  Future<void> add(AppSettings column) async {
    try {
      var dbClient = await db;
      await dbClient!.insert('OPCGameTable', column.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      log("Database initialization error: $e");
    }
  }

  Future<AppSettings?> getList(int ver) async {
    var dbClient = await db;
    List<Map<String, dynamic>> maps = await dbClient!.query(
      'OPCGameTable',
      columns: ['Ver', 'LanguageCode', 'MusicVolume', 'CharacterVolume', 'Time', 'Difficulty', 'BackgroundPath', 'Mute', 'LowPower'],
      where: 'Ver = ?',
      whereArgs: [ver],
    );
    if (maps.isNotEmpty) {
      AppSettings retResult = AppSettings.fromMap(maps.first);
      return retResult;
    } else {
      return null;
    }
  }

  Future<int> update(AppSettings column) async {
    var dbClient = await db;
    return await dbClient!.update('OPCGameTable', column.toMap(), where: 'Ver = ?', whereArgs: [column.version]);
  }

  Future close() async {
    var dbClient = await db;
    dbClient!.close();
  }

  Future<int> delete(AppSettings column) async {
    var dbClient = await db;
    return await dbClient!.delete('OPCGameTable', where: 'Ver = ?', whereArgs: [column.version]);
  }

  Future<void> addSessionLog(SessionLog sessionLog) async {
    try {
      var dbClient = await db;
      await dbClient!.insert(
        'SessionHistory',
        sessionLog.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      log("Session insert error: $e");
    }
  }

  Future<List<SessionLog>> fetchSessionLogs({int limit = 30}) async {
    var dbClient = await db;
    final maps = await dbClient!.query(
      'SessionHistory',
      orderBy: 'Id DESC',
      limit: limit,
    );
    return maps.map(SessionLog.fromMap).toList();
  }
}

// ignore_for_file: await_only_futures, depend_on_referenced_packages

import 'dart:developer';

import 'opc_database_list.dart';
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
        version: 3,
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
      'CREATE TABLE OPCGameTable(Ver INTEGER not null PRIMARY KEY, LanguageCode INTEGER not null, MusicVolume DOUBLE not null, CharacterVolume DOUBLE not null, Time INTEGER not null, Difficulty INTEGER not null)',
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
  }

  Future<void> add(OPCDataBase column) async {
    try {
      var dbClient = await db;
      await dbClient!.insert('OPCGameTable', column.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      log("Database initialization error: $e");
    }
  }

  Future<OPCDataBase?> getList(int ver) async {
    var dbClient = await db;
    List<Map<String, dynamic>> maps = await dbClient!.query(
      'OPCGameTable',
      columns: ['Ver', 'LanguageCode', 'MusicVolume', 'CharacterVolume', 'Time', 'Difficulty'],
      where: 'Ver = ?',
      whereArgs: [ver],
    );
    if (maps.isNotEmpty) {
      OPCDataBase retResult = OPCDataBase.fromMap(maps.first);
      return retResult;
    } else {
      return null;
    }
  }

  Future<int> update(OPCDataBase column) async {
    var dbClient = await db;
    return await dbClient!.update('OPCGameTable', column.toMap(), where: 'Ver = ?', whereArgs: [column.ver]);
  }

  Future close() async {
    var dbClient = await db;
    dbClient!.close();
  }

  Future<int> delete(OPCDataBase column) async {
    var dbClient = await db;
    return await dbClient!.delete('OPCGameTable', where: 'Ver = ?', whereArgs: [column.ver]);
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

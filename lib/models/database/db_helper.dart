// ignore_for_file: await_only_futures, depend_on_referenced_packages

import 'dart:developer';
import 'package:game_for_cats_2025/models/app_settings.dart';
import 'package:game_for_cats_2025/models/database/session_log.dart';
import 'package:game_for_cats_2025/models/database/db_schema.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

//* Low-level local database adapter.
//! This file owns schema creation / migration, while repositories own business meaning.
class DBHelper {
  DBHelper();

  static Database? _db;
  Future<Database?> get db async {
    //? The app only needs one live database connection per process.
    if (_db != null) {
      return _db;
    }
    _db = await initDatabase();
    return _db;
  }

  Future<Database> initDatabase() async {
    try {
      const fileName = 'miceandpawsdatabase0.db';
      final documentDirectory = await getApplicationDocumentsDirectory();
      final path = join(documentDirectory.path, fileName);
      final db = await openDatabase(
        path,
        version: 7,
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
    await createAppSchema(db, version);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await upgradeAppSchema(db, oldVersion, newVersion);
  }

  Future<void> add(AppSettings column) async {
    try {
      final dbClient = await db;
      await dbClient!.insert(
        'OPCGameTable',
        column.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      log("Database initialization error: $e");
    }
  }

  Future<AppSettings?> getList(int ver) async {
    final dbClient = await db;
    final maps = await dbClient!.query(
      'OPCGameTable',
      columns: [
        'Ver',
        'LanguageCode',
        'MusicVolume',
        'CharacterVolume',
        'Time',
        'Difficulty',
        'BackgroundPath',
        'Mute',
        'LowPower',
        'ReducedMotion',
        'HighContrast',
        'LargerTargets',
        'Haptics',
      ],
      where: 'Ver = ?',
      whereArgs: [ver],
    );
    if (maps.isNotEmpty) {
      final retResult = AppSettings.fromMap(maps.first);
      return retResult;
    } else {
      return null;
    }
  }

  Future<int> update(AppSettings column) async {
    final dbClient = await db;
    return await dbClient!.update(
      'OPCGameTable',
      column.toMap(),
      where: 'Ver = ?',
      whereArgs: [column.version],
    );
  }

  Future close() async {
    final dbClient = await db;
    dbClient!.close();
  }

  Future<int> delete(AppSettings column) async {
    final dbClient = await db;
    return await dbClient!.delete(
      'OPCGameTable',
      where: 'Ver = ?',
      whereArgs: [column.version],
    );
  }

  Future<void> addSessionLog(SessionLog sessionLog) async {
    try {
      final dbClient = await db;
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
    final dbClient = await db;
    final maps = await dbClient!.query(
      'SessionHistory',
      orderBy: 'Id DESC',
      limit: limit,
    );
    return maps.map(SessionLog.fromMap).toList();
  }
}

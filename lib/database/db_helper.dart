// ignore_for_file: await_only_futures, depend_on_referenced_packages

import 'dart:developer';

import 'opc_database_list.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io' as io;
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

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

  initDatabase() async {
    try {
      String fileName = 'miceandpawsdatabase0.db';
      io.Directory documentDirectory = await getApplicationDocumentsDirectory();
      String path = join(documentDirectory.path, fileName);
      var db = await openDatabase(path, version: 1, onCreate: _onCreate, onOpen: (db) {});
      return db;
    } catch (e) {
      log("Database initialization error: $e");
    }
  }

  _onCreate(Database db, int version) async {
    await db.execute(
        'CREATE TABLE OPCGameTable(Ver INTEGER not null PRIMARY KEY, LanguageCode INTEGER not null, MusicVolume DOUBLE not null, CharacterVolume DOUBLE not null, Time INTEGER not null)');
  }

  add(OPCDataBase column) async {
    try {
      var dbClient = await db;
      await dbClient!.insert('OPCGameTable', column.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      log("Database initialization error: $e");
    }
  }

  Future<OPCDataBase?> getList(int ver) async {
    var dbClient = await db;
    List<Map<String, dynamic>> maps =
        await dbClient!.query('OPCGameTable', columns: ['Ver', 'LanguageCode', 'MusicVolume', 'CharacterVolume', 'Time'], where: 'Ver = ?', whereArgs: [ver]);
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
}

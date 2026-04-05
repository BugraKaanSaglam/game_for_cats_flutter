import 'package:game_for_cats_2025/models/app_settings.dart';
import 'package:game_for_cats_2025/models/database/db_helper.dart';
import 'package:game_for_cats_2025/models/global/global_variables.dart';

//* Thin repository around the settings table.
//? The UI never talks to sqflite directly; it always goes through AppState -> repository -> DBHelper.
class AppSettingsRepository {
  AppSettingsRepository({DBHelper? dbHelper})
    : _dbHelper = dbHelper ?? DBHelper();

  final DBHelper _dbHelper;

  Future<AppSettings> fetchOrCreate() async {
    //! This app expects exactly one settings row keyed by the current schema version.
    final existing = await _dbHelper.getList(databaseVersion);
    if (existing != null) return existing;

    final defaults = AppSettings.defaults();
    await _dbHelper.add(defaults);
    return defaults;
  }

  Future<void> save(AppSettings settings) async {
    //? Replace semantics are handled in DBHelper, so callers only think in terms of current settings.
    await _dbHelper.update(settings);
  }
}

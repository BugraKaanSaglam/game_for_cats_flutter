import 'package:game_for_cats_2025/models/app_settings.dart';
import 'package:game_for_cats_2025/models/database/db_helper.dart';
import 'package:game_for_cats_2025/models/global/global_variables.dart';

class AppSettingsRepository {
  AppSettingsRepository({DBHelper? dbHelper}) : _dbHelper = dbHelper ?? DBHelper();

  final DBHelper _dbHelper;

  Future<AppSettings> fetchOrCreate() async {
    final existing = await _dbHelper.getList(databaseVersion);
    if (existing != null) return existing;

    final defaults = AppSettings.defaults();
    await _dbHelper.add(defaults);
    return defaults;
  }

  Future<void> save(AppSettings settings) async {
    await _dbHelper.update(settings);
  }
}

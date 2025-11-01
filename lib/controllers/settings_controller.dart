import 'package:game_for_cats_2025/models/database/db_helper.dart';
import 'package:game_for_cats_2025/models/database/opc_database_list.dart';
import 'package:game_for_cats_2025/models/enums/enum_functions.dart';
import 'package:game_for_cats_2025/models/global/global_variables.dart';

/// Encapsulates the data flow for the settings screen.
class SettingsController {
  SettingsController({DBHelper? dbHelper}) : _dbHelper = dbHelper ?? DBHelper();

  final DBHelper _dbHelper;

  Future<OPCDataBase?> loadConfiguration() => _dbHelper.getList(databaseVersion);

  Future<void> saveConfiguration(OPCDataBase configuration) async {
    await _dbHelper.update(configuration);
    getTimeFromValue(configuration.time);
  }

  int localeValue(OPCDataBase configuration) => configuration.languageCode;
}

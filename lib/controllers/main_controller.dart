import 'package:flutter/material.dart';
import 'package:game_for_cats_2025/models/database/db_helper.dart';
import 'package:game_for_cats_2025/models/database/opc_database_list.dart';
import 'package:game_for_cats_2025/models/enums/enum_functions.dart';
import 'package:game_for_cats_2025/models/enums/game_enums.dart';
import 'package:game_for_cats_2025/models/global/argument_sender.dart';
import 'package:game_for_cats_2025/models/global/global_variables.dart';

/// Handles the non-visual workflow of the main menu screen.
class MainController {
  MainController({DBHelper? dbHelper}) : _dbHelper = dbHelper ?? DBHelper();

  final DBHelper _dbHelper;

  Future<OPCDataBase?> fetchConfiguration() => _dbHelper.getList(databaseVersion);

  Future<OPCDataBase> ensureConfiguration(OPCDataBase? configuration) async {
    if (configuration != null) {
      return configuration;
    }

    final defaultConfig = OPCDataBase(
      ver: databaseVersion,
      languageCode: Language.english.value,
      musicVolume: 0.5,
      characterVolume: 1,
      time: Time.fifty.value,
      difficulty: Difficulty.easy.value,
      backgroundPath: '',
    );

    await _dbHelper.add(defaultConfig);
    return defaultConfig;
  }

  Time applyGameTime(OPCDataBase configuration) => getTimeFromValue(configuration.time);

  Language applyLanguage(OPCDataBase configuration) => getLanguageFromValue(configuration.languageCode);

  void navigateTo(BuildContext context, String routeName, String title, {OPCDataBase? configuration}) {
    final argumentSender = ArgumentSender(title: title, dataBase: configuration);
    Navigator.pushNamedAndRemoveUntil(context, routeName, (route) => false, arguments: argumentSender);
  }
}

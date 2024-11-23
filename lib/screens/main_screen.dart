import 'dart:io';
import 'package:flutter/material.dart';
import 'package:game_for_cats_flutter/database/db_error.dart';
import 'package:game_for_cats_flutter/database/db_helper.dart';
import 'package:game_for_cats_flutter/database/opc_database_list.dart';
import 'package:game_for_cats_flutter/enums/enum_functions.dart';
import 'package:game_for_cats_flutter/enums/game_enums.dart';
import 'package:game_for_cats_flutter/global/argumentsender_class.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../global/global_functions.dart';
import '../global/global_variables.dart';
import '../main.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  OPCDataBase? _db;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mainAppBar(AppLocalizations.of(context)!.game_name, context, hasBackButton: false),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(child: Image.asset('assets/images/mainscreenbg.png', fit: BoxFit.fill)),
          // Main content
          mainBody(context),
        ],
      ),
    );
  }

  Widget mainBody(BuildContext context) {
    return FutureBuilder<OPCDataBase?>(
        future: DBHelper().getList(databaseVersion),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(child: CircularProgressIndicator());
            case ConnectionState.done:
              if (snapshot.data == null) {
                OPCDataBase initDataBase = OPCDataBase(ver: databaseVersion, languageCode: Language.english.value, musicVolume: 0.5, characterVolume: 1, time: Time.fifty.value);
                DBHelper().add(initDataBase);
                _db = initDataBase;
              } else {
                _db = snapshot.data;
              }
              if (snapshot.hasError && _db == null) {
                return dbError(context);
              }
              //Check Game Time
              checkGameTime(_db?.time);
              //Set Language
              languageCode = getLanguageFromValue(_db?.languageCode);
              Future.delayed(const Duration(), () {
                MainApp.of(context)!.setLocale(languageCode.value);
              });
              return Column(children: [
                const Spacer(flex: 80),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    mainMenuButtons(context, AppLocalizations.of(context)!.start_button, '/game_screen', const Icon(Icons.arrow_right_alt_sharp), dataBase: _db),
                    mainMenuButtons(context, AppLocalizations.of(context)!.settings_button, '/settings_screen', const Icon(Icons.settings)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    mainMenuButtons(context, AppLocalizations.of(context)!.howtoplay_button, '/howtoplay_screen', const Icon(Icons.menu_book)),
                    mainMenuButtons(context, AppLocalizations.of(context)!.credits_button, '/credits_screen', const Icon(Icons.pest_control_rodent_sharp)),
                  ],
                ),
                const Spacer(flex: 15),
                exitButton(AppLocalizations.of(context)!.exit_button, context),
                const Spacer(flex: 1),
              ]);

            default:
              return dbError(context);
          }
        });
  }

  checkGameTime(int? time) {
    getTimeFromValue(time); //This also set gameTimer!
  }

//* Buttons
  ElevatedButton mainMenuButtons(BuildContext context, String buttonString, String adressString, Icon buttonIcon, {OPCDataBase? dataBase}) {
    ArgumentSender? argumentSender;
    argumentSender = ArgumentSender(title: buttonString, dataBase: dataBase);

    return ElevatedButton(
      style: const ButtonStyle(
        fixedSize: WidgetStatePropertyAll<Size>(Size(170, 40)),
        padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 20, vertical: 5)),
      ),
      onPressed: () => Navigator.pushNamedAndRemoveUntil(context, adressString, (route) => false, arguments: argumentSender),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(buttonString, style: const TextStyle(fontWeight: FontWeight.bold)), buttonIcon]),
    );
  }

  ElevatedButton exitButton(String title, BuildContext context) {
    return ElevatedButton(
      onPressed: () => exit(0),
      style: const ButtonStyle(
        fixedSize: WidgetStatePropertyAll<Size>(Size(270, 40)),
        padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
      ),
      child: Row(children: [Text(title), const Icon(Icons.exit_to_app_outlined)]),
    );
  }
}

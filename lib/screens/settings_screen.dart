// ignore_for_file: must_be_immutable
import 'package:flutter/material.dart';
import 'package:game_for_cats_flutter/database/db_helper.dart';
import 'package:game_for_cats_flutter/enums/game_enums.dart';
import 'package:game_for_cats_flutter/main.dart';
import '../database/db_error.dart';
import '../database/opc_database_list.dart';
import '../functions/settings_form_functions.dart';
import '../global/global_functions.dart';
import '../global/global_variables.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  OPCDataBase? _db;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: mainAppBar(AppLocalizations.of(context)!.settings_button, context), body: mainBody(context));
  }

  Widget mainBody(BuildContext context) {
    return FutureBuilder<OPCDataBase?>(
        future: DBHelper().getList(databaseVersion),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(child: CircularProgressIndicator());
            case ConnectionState.done:
              if (snapshot.hasError) {
                return dbError(context);
              }
              _db = snapshot.data;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [languageDropDownFormField(), timeDropDownFormField(), musicField(), miceSoundField(), saveButton()],
                ),
              );
            default:
              return dbError(context);
          }
        });
  }

//*FormFields
  Column languageDropDownFormField() {
    List<DropdownMenuItem> items = [
      DropdownMenuItem(value: Language.turkish.value, child: Text(Language.turkish.name)),
      DropdownMenuItem(value: Language.english.value, child: Text(Language.english.name)),
    ];
    return Column(
      children: [
        Text(AppLocalizations.of(context)!.select_language),
        DropdownButtonFormField(
          dropdownColor: Colors.white,
          value: _db?.languageCode ?? 0,
          decoration: formDecoration(),
          items: items,
          onChanged: (value) => _db?.languageCode = value,
        ),
      ],
    );
  }

//! This is not Added TBA
/*
  Column difficultyDropDownFormField() {
    List<DropdownMenuItem> items = [
      DropdownMenuItem(value: Difficulty.easy.value, child: Text(Difficulty.easy.name)),
      DropdownMenuItem(value: Difficulty.medium.value, child: Text(Difficulty.medium.name)),
      DropdownMenuItem(value: Difficulty.hard.value, child: Text(Difficulty.hard.name)),
    ];
    return Column(
      children: [
        Text(AppLocalizations.of(context)!.select_difficulty),
        DropdownButtonFormField(
          dropdownColor: Colors.white,
          value: _db?.difficulty ?? 0,
          decoration: formDecoration(),
          items: items,
          onChanged: (value) => _db?.difficulty = value,
        ),
      ],
    );
  }
*/

  Column timeDropDownFormField() {
    List<DropdownMenuItem> items = [
      DropdownMenuItem(value: Time.fifty.value, child: Text(Time.fifty.name)),
      DropdownMenuItem(value: Time.hundered.value, child: Text(Time.hundered.name)),
      DropdownMenuItem(value: Time.twohundered.value, child: Text(Time.twohundered.name)),
      DropdownMenuItem(value: Time.sandbox.value, child: Text(Time.sandbox.name)),
    ];
    return Column(
      children: [
        Text(AppLocalizations.of(context)!.select_time),
        DropdownButtonFormField(
          dropdownColor: Colors.white,
          value: _db?.time ?? Time.fifty.value,
          decoration: formDecoration(),
          items: items,
          onChanged: (value) => _db?.time = value,
        ),
      ],
    );
  }

  StatefulBuilder musicField() {
    return StatefulBuilder(
      builder: (context, musicState) {
        return Column(
          children: [
            Text(AppLocalizations.of(context)!.select_musicvolume),
            Slider(
              min: 0,
              max: 1,
              value: _db!.musicVolume.toDouble(),
              onChanged: (newValue) {
                musicState(() => _db!.musicVolume = newValue);
              },
            ),
          ],
        );
      },
    );
  }

  StatefulBuilder miceSoundField() {
    return StatefulBuilder(
      builder: (context, miceSoundState) {
        return Column(
          children: [
            Text(AppLocalizations.of(context)!.select_charactervolume),
            Slider(
              min: 0,
              max: 1,
              value: _db!.characterVolume.toDouble(),
              onChanged: (newValue) {
                miceSoundState(() => _db!.characterVolume = newValue);
              },
            ),
          ],
        );
      },
    );
  }

  ElevatedButton saveButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.save_complete_snackbar),
              elevation: 10,
              duration: const Duration(seconds: 2),
            ),
          );
          DBHelper().update(_db!);
          MainApp.of(context)!.setLocale(_db!.languageCode);
        });
      },
      child: Text(AppLocalizations.of(context)!.save_button),
    );
  }
}

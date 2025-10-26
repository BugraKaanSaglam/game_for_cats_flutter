// ignore_for_file: must_be_immutable
import 'package:flutter/material.dart';
import 'package:game_for_cats_2025/classes/custom_button.dart';
import 'package:game_for_cats_2025/database/db_error.dart';
import 'package:game_for_cats_2025/database/db_helper.dart';
import 'package:game_for_cats_2025/database/opc_database_list.dart';
import 'package:game_for_cats_2025/enums/game_enums.dart';
import 'package:game_for_cats_2025/global/global_functions.dart';
import 'package:game_for_cats_2025/global/global_variables.dart';
import 'package:game_for_cats_2025/l10n/app_localizations.dart';
import 'package:game_for_cats_2025/main.dart';
import 'package:game_for_cats_2025/utils/paw_theme.dart';
import 'package:game_for_cats_2025/widgets/animated_gradient_background.dart';
import 'package:game_for_cats_2025/widgets/playful_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  OPCDataBase? _db;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mainAppBar(
        AppLocalizations.of(context)!.settings_button,
        context,
      ),
      body: AnimatedGradientBackground(child: _buildBody()),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: _db == null
            ? const SizedBox.shrink()
            : _buildSaveButton(context),
      ),
    );
  }

  Widget _buildBody() {
    return FutureBuilder<OPCDataBase?>(
      future: DBHelper().getList(databaseVersion),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }
        if (snapshot.hasError) {
          return dbError(context);
        }
        _db = snapshot.data;
        if (_db == null) return dbError(context);

        final l10n = AppLocalizations.of(context)!;
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            children: [
              _buildHeader(context),
              PlayfulCard(
                emoji: '🌍',
                title: l10n.select_language,
                subtitle: l10n.settings_language_hint,
                gradient: PawPalette.pinkToOrange(),
                child: _buildLanguageDropdown(context),
              ),
              PlayfulCard(
                emoji: '⏱️',
                title: l10n.select_time,
                subtitle: l10n.settings_time_hint,
                gradient: PawPalette.tealToLemon(),
                child: _buildTimeDropdown(context),
              ),
              PlayfulCard(
                emoji: '🎵',
                title: l10n.select_musicvolume,
                subtitle: l10n.settings_music_hint,
                child: _buildSlider(
                  value: _db?.musicVolume ?? 0.5,
                  onChanged: (value) =>
                      setState(() => _db?.musicVolume = value),
                  activeColor: PawPalette.grape,
                ),
              ),
              PlayfulCard(
                emoji: '🐁',
                title: l10n.select_charactervolume,
                subtitle: l10n.settings_character_hint,
                child: _buildSlider(
                  value: _db?.characterVolume ?? 1.0,
                  onChanged: (value) =>
                      setState(() => _db?.characterVolume = value),
                  activeColor: PawPalette.teal,
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.settings_button,
          style: PawTextStyles.heading,
        ),
        const SizedBox(height: 6),
        Text(
          AppLocalizations.of(context)!.settings_header_subtitle,
          style: PawTextStyles.subheading,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildLanguageDropdown(BuildContext context) {
    final items = [
      DropdownMenuItem(
        value: Language.turkish.value,
        child: Text(Language.turkish.name),
      ),
      DropdownMenuItem(
        value: Language.english.value,
        child: Text(Language.english.name),
      ),
    ];

    return _PillDropdown(
      value: _db?.languageCode ?? Language.english.value,
      items: items,
      onChanged: (value) =>
          setState(() => _db?.languageCode = value ?? Language.english.value),
    );
  }

  Widget _buildTimeDropdown(BuildContext context) {
    final items = [
      DropdownMenuItem(value: Time.fifty.value, child: Text(Time.fifty.name)),
      DropdownMenuItem(
        value: Time.hundered.value,
        child: Text(Time.hundered.name),
      ),
      DropdownMenuItem(
        value: Time.twohundered.value,
        child: Text(Time.twohundered.name),
      ),
      DropdownMenuItem(
        value: Time.sandbox.value,
        child: Text(Time.sandbox.name),
      ),
    ];

    return _PillDropdown(
      value: _db?.time ?? Time.fifty.value,
      items: items,
      onChanged: (value) =>
          setState(() => _db?.time = value ?? Time.fifty.value),
    );
  }

  Widget _buildSlider({
    required double value,
    required ValueChanged<double> onChanged,
    required Color activeColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: activeColor,
            inactiveTrackColor: activeColor.withValues(alpha: 0.3 * 255),
            thumbColor: Colors.white,
            overlayColor: activeColor.withValues(alpha: 0.15 * 255),
          ),
          child: Slider(min: 0, max: 1, value: value, onChanged: onChanged),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${(value * 100).round()}%',
            style: PawTextStyles.cardSubtitle,
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.85, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      builder: (context, value, child) =>
          Transform.scale(scale: value, child: child),
      child: CustomButton(
        onPressed: () async {
          final messenger = ScaffoldMessenger.of(context);
          final successText = AppLocalizations.of(
            context,
          )!.save_complete_snackbar;
          final mainState = MainApp.of(context);

          await DBHelper().update(_db!);
          mainState?.setLocale(_db!.languageCode);
          messenger.showSnackBar(
            SnackBar(
              content: Text(successText),
              elevation: 10,
              duration: const Duration(seconds: 2),
            ),
          );
        },
        child: Text(AppLocalizations.of(context)!.save_button),
      ),
    );
  }
}

class _PillDropdown extends StatelessWidget {
  const _PillDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final int value;
  final List<DropdownMenuItem<int>> items;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white,
        border: Border.all(
          color: PawPalette.midnight.withValues(alpha: 0.08 * 255),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.expand_more),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ignore_for_file: must_be_immutable, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:game_for_cats_2025/controllers/settings_controller.dart';
import 'package:game_for_cats_2025/models/database/db_error.dart';
import 'package:game_for_cats_2025/models/database/opc_database_list.dart';
import 'package:game_for_cats_2025/models/enums/game_enums.dart';
import 'package:game_for_cats_2025/main.dart';
import 'package:game_for_cats_2025/l10n/app_localizations.dart';
import 'package:game_for_cats_2025/views/components/main_app_bar.dart';
import 'package:game_for_cats_2025/views/theme/paw_theme.dart';
import 'package:game_for_cats_2025/views/widgets/playful_card.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final SettingsController _controller;
  OPCDataBase? _db;
  late final Future<OPCDataBase?> _dbFuture;

  @override
  void initState() {
    super.initState();
    _controller = SettingsController();
    _dbFuture = _controller.loadConfiguration();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mainAppBar(AppLocalizations.of(context)!.settings_button, context),
      body: Container(
        decoration: const BoxDecoration(gradient: PawPalette.lightBackground),
        child: _buildBody(),
      ),
      bottomNavigationBar: SafeArea(minimum: const EdgeInsets.fromLTRB(24, 0, 24, 16), child: _db == null ? const SizedBox.shrink() : _buildSaveButton(context)),
    );
  }

  Widget _buildBody() {
    return FutureBuilder<OPCDataBase?>(
      future: _dbFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }
        if (snapshot.hasError) return dbError(context);

        _db ??= snapshot.data;
        if (_db == null) return dbError(context);

        final l10n = AppLocalizations.of(context)!;
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            children: [
              _buildHeader(context),
              PlayfulCard(emoji: '🌍', title: l10n.select_language, subtitle: l10n.settings_language_hint, gradient: PawPalette.pinkToOrange(), child: _buildLanguageDropdown(context)),
              PlayfulCard(emoji: '⏱️', title: l10n.select_time, subtitle: l10n.settings_time_hint, gradient: PawPalette.tealToLemon(), child: _buildTimeDropdown(context)),
              PlayfulCard(emoji: '🎯', title: l10n.select_difficulty, subtitle: l10n.settings_difficulty_hint, child: _buildDifficultyDropdown(context)),
              PlayfulCard(
                emoji: '🔇',
                title: l10n.mute_title,
                subtitle: l10n.mute_subtitle,
                gradient: PawPalette.tealToLemon(),
                child: SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _db?.muted ?? false,
                  onChanged: (v) => setState(() => _db?.muted = v),
                  title: Text(l10n.mute_toggle_label, style: PawTextStyles.cardTitle),
                ),
              ),
              PlayfulCard(
                emoji: '⚡',
                title: l10n.lowpower_title,
                subtitle: l10n.lowpower_subtitle,
                gradient: PawPalette.pinkToOrange(),
                child: SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _db?.lowPower ?? false,
                  onChanged: (v) => setState(() => _db?.lowPower = v),
                  title: Text(l10n.lowpower_toggle_label, style: PawTextStyles.cardTitle),
                ),
              ),
              PlayfulCard(
                emoji: '🖼️',
                title: l10n.background_title,
                subtitle: l10n.background_subtitle,
                gradient: PawPalette.pinkToOrange(),
                child: _buildBackgroundPicker(context),
              ),
              PlayfulCard(
                emoji: '🎵',
                title: l10n.select_musicvolume,
                subtitle: l10n.settings_music_hint,
                child: _buildSlider(value: _db?.musicVolume ?? 0.5, onChanged: (v) => setState(() => _db?.musicVolume = v), activeColor: PawPalette.grape),
              ),
              PlayfulCard(
                emoji: '🐁',
                title: l10n.select_charactervolume,
                subtitle: l10n.settings_character_hint,
                child: _buildSlider(value: _db?.characterVolume ?? 1.0, onChanged: (v) => setState(() => _db?.characterVolume = v), activeColor: PawPalette.teal),
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
        Text(AppLocalizations.of(context)!.settings_button, style: PawTextStyles.heading),
        const SizedBox(height: 6),
        Text(AppLocalizations.of(context)!.settings_header_subtitle, style: PawTextStyles.subheading),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildLanguageDropdown(BuildContext context) {
    final items = [DropdownMenuItem(value: Language.turkish.value, child: Text(Language.turkish.name)), DropdownMenuItem(value: Language.english.value, child: Text(Language.english.name))];

    return _PillDropdown(value: _db?.languageCode ?? Language.english.value, items: items, onChanged: (v) => setState(() => _db?.languageCode = v ?? Language.english.value));
  }

  Widget _buildTimeDropdown(BuildContext context) {
    final items = [DropdownMenuItem(value: Time.fifty.value, child: Text(Time.fifty.name)), DropdownMenuItem(value: Time.hundered.value, child: Text(Time.hundered.name)), DropdownMenuItem(value: Time.twohundered.value, child: Text(Time.twohundered.name)), DropdownMenuItem(value: Time.sandbox.value, child: Text(Time.sandbox.name))];

    return _PillDropdown(value: _db?.time ?? Time.fifty.value, items: items, onChanged: (v) => setState(() => _db?.time = v ?? Time.fifty.value));
  }

  Widget _buildDifficultyDropdown(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = [
      DropdownMenuItem(value: Difficulty.easy.value, child: Text(l10n.difficulty_easy)),
      DropdownMenuItem(value: Difficulty.medium.value, child: Text(l10n.difficulty_medium)),
      DropdownMenuItem(value: Difficulty.hard.value, child: Text(l10n.difficulty_hard)),
      DropdownMenuItem(value: Difficulty.sandbox.value, child: Text(l10n.difficulty_sandbox)),
    ];

    return _PillDropdown(
      value: _db?.difficulty ?? Difficulty.easy.value,
      items: items,
      onChanged: (v) => setState(() => _db?.difficulty = v ?? Difficulty.easy.value),
    );
  }

  Widget _buildBackgroundPicker(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final path = _db?.backgroundPath ?? '';
    final hasCustom = path.isNotEmpty;
    final image = hasCustom ? FileImage(File(path)) : const AssetImage('assets/images/background.webp') as ImageProvider;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: PawPalette.midnight.withValues(alpha: 0.08 * 255)),
              ),
              child: Image(image: image, fit: BoxFit.cover),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: PawPalette.grape,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: _pickBackground,
                icon: const Icon(Icons.photo_library_rounded),
                label: Text(l10n.background_change_button),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: PawPalette.midnight,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              ),
              onPressed: hasCustom ? _resetBackground : null,
              child: Text(l10n.background_reset_button),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(l10n.background_hint, style: PawTextStyles.cardSubtitle),
      ],
    );
  }

  Future<void> _pickBackground() async {
    final picker = ImagePicker();
    final result = await picker.pickImage(source: ImageSource.gallery, maxWidth: 2048, maxHeight: 2048);
    if (result == null) return;
    final savedPath = await _persistPickedImage(result);
    setState(() => _db?.backgroundPath = savedPath);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.background_selected_snackbar), duration: const Duration(seconds: 2)));
  }

  void _resetBackground() {
    setState(() => _db?.backgroundPath = '');
  }

  Future<String> _persistPickedImage(XFile picked) async {
    final appDir = await getApplicationDocumentsDirectory();
    final extension = picked.name.split('.').last;
    final targetPath = '${appDir.path}/bg_${DateTime.now().millisecondsSinceEpoch}.$extension';

    // Clean previous custom file to avoid storage bloat.
    final oldPath = _db?.backgroundPath ?? '';
    if (oldPath.isNotEmpty) {
      final oldFile = File(oldPath);
      if (await oldFile.exists()) {
        await oldFile.delete().catchError((_) => oldFile);
      }
    }

    await File(picked.path).copy(targetPath);
    return targetPath;
  }

  Widget _buildSlider({required double value, required ValueChanged<double> onChanged, required Color activeColor}) {
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
          child: Text('${(value * 100).round()}%', style: PawTextStyles.cardSubtitle),
        ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.9, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutBack,
      builder: (context, value, child) => Transform.scale(scale: value, child: child),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final messenger = ScaffoldMessenger.of(context);

            await _controller.saveConfiguration(_db!);
            MainApp.of(context)?.setLocale(_controller.localeValue(_db!));

            messenger.showSnackBar(SnackBar(content: Text(l10n.save_complete_snackbar), elevation: 10, duration: const Duration(seconds: 2)));
          },
          borderRadius: BorderRadius.circular(28),
          child: Ink(
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: PawPalette.pinkToOrange()),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15 * 255),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.save_rounded, color: Colors.white),
                  const SizedBox(width: 10),
                  Text(
                    l10n.save_button,
                    style: PawTextStyles.subheading.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PillDropdown extends StatelessWidget {
  const _PillDropdown({required this.value, required this.items, required this.onChanged});

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
        border: Border.all(color: PawPalette.midnight.withValues(alpha: 0.08 * 255)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(value: value, isExpanded: true, icon: const Icon(Icons.expand_more), items: items, onChanged: onChanged),
      ),
    );
  }
}

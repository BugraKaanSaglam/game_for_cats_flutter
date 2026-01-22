// ignore_for_file: must_be_immutable, use_build_context_synchronously
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:game_for_cats_2025/models/database/db_error.dart';
import 'package:game_for_cats_2025/models/app_settings.dart';
import 'package:game_for_cats_2025/models/enums/game_enums.dart';
import 'package:game_for_cats_2025/l10n/app_localizations.dart';
import 'package:game_for_cats_2025/views/components/main_app_bar.dart';
import 'package:game_for_cats_2025/views/theme/paw_theme.dart';
import 'package:game_for_cats_2025/views/widgets/playful_card.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:game_for_cats_2025/state/app_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const int _backgroundMaxDimension = 1280;
  AppSettings? _draftSettings;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settings = context.read<AppState>().settings;
    if (_draftSettings == null && settings != null) {
      _draftSettings = settings;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    if (!appState.isReady) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: PawPalette.bubbleGum)),
      );
    }

    return Scaffold(
      appBar: MainAppBar(title: AppLocalizations.of(context)!.settings_button),
      body: Container(
        decoration: const BoxDecoration(gradient: PawPalette.lightBackground),
        child: _buildBody(),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: _draftSettings == null ? const SizedBox.shrink() : _buildSaveButton(context),
      ),
    );
  }

  Widget _buildBody() {
    final appState = context.watch<AppState>();
    if (appState.initError != null) {
      return Center(child: dbError(context));
    }

    final settings = _draftSettings;
    if (settings == null) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

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
              value: settings.muted,
              onChanged: (v) => _updateSettings((current) => current.copyWith(muted: v)),
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
              value: settings.lowPower,
              onChanged: (v) => _updateSettings((current) => current.copyWith(lowPower: v)),
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
            child: _buildSlider(
              value: settings.musicVolume,
              onChanged: (v) => _updateSettings((current) => current.copyWith(musicVolume: v)),
              activeColor: PawPalette.grape,
            ),
          ),
          PlayfulCard(
            emoji: '🐁',
            title: l10n.select_charactervolume,
            subtitle: l10n.settings_character_hint,
            child: _buildSlider(
              value: settings.characterVolume,
              onChanged: (v) => _updateSettings((current) => current.copyWith(characterVolume: v)),
              activeColor: PawPalette.teal,
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  void _updateSettings(AppSettings Function(AppSettings current) update) {
    final current = _draftSettings;
    if (current == null) return;
    setState(() => _draftSettings = update(current));
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

    final settings = _draftSettings;
    if (settings == null) return const SizedBox.shrink();
    return _PillDropdown(
      value: settings.languageCode,
      items: items,
      onChanged: (v) => _updateSettings((current) => current.copyWith(languageCode: v ?? Language.english.value)),
    );
  }

  Widget _buildTimeDropdown(BuildContext context) {
    final items = [DropdownMenuItem(value: Time.fifty.value, child: Text(Time.fifty.name)), DropdownMenuItem(value: Time.hundered.value, child: Text(Time.hundered.name)), DropdownMenuItem(value: Time.twohundered.value, child: Text(Time.twohundered.name)), DropdownMenuItem(value: Time.sandbox.value, child: Text(Time.sandbox.name))];

    final settings = _draftSettings;
    if (settings == null) return const SizedBox.shrink();
    return _PillDropdown(
      value: settings.time,
      items: items,
      onChanged: (v) => _updateSettings((current) => current.copyWith(time: v ?? Time.fifty.value)),
    );
  }

  Widget _buildDifficultyDropdown(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = [
      DropdownMenuItem(value: Difficulty.easy.value, child: Text(l10n.difficulty_easy)),
      DropdownMenuItem(value: Difficulty.medium.value, child: Text(l10n.difficulty_medium)),
      DropdownMenuItem(value: Difficulty.hard.value, child: Text(l10n.difficulty_hard)),
      DropdownMenuItem(value: Difficulty.sandbox.value, child: Text(l10n.difficulty_sandbox)),
    ];

    final settings = _draftSettings;
    if (settings == null) return const SizedBox.shrink();
    return _PillDropdown(
      value: settings.difficulty,
      items: items,
      onChanged: (v) => _updateSettings((current) => current.copyWith(difficulty: v ?? Difficulty.easy.value)),
    );
  }

  Widget _buildBackgroundPicker(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final path = _draftSettings?.backgroundPath ?? '';
    final file = path.isNotEmpty ? File(path) : null;
    final hasCustom = file != null && file.existsSync();
    final ImageProvider image = hasCustom ? FileImage(file!) : const AssetImage('assets/images/background.webp');

    if (!hasCustom && path.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _updateSettings((current) => current.copyWith(backgroundPath: ''));
      });
    }

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
    final result = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: _backgroundMaxDimension.toDouble(),
      maxHeight: _backgroundMaxDimension.toDouble(),
    );
    if (result == null) return;
    final savedPath = await _persistPickedImage(result);
    _updateSettings((current) => current.copyWith(backgroundPath: savedPath));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.background_selected_snackbar), duration: const Duration(seconds: 2)));
  }

  void _resetBackground() {
    _updateSettings((current) => current.copyWith(backgroundPath: ''));
  }

  Future<String> _persistPickedImage(XFile picked) async {
    final appDir = await getApplicationDocumentsDirectory();
    final baseName = 'bg_${DateTime.now().millisecondsSinceEpoch}';
    final pngPath = '${appDir.path}/$baseName.png';
    final fallbackExtension = picked.name.split('.').last;
    final fallbackPath = '${appDir.path}/$baseName.$fallbackExtension';

    // Clean previous custom file to avoid storage bloat.
    final oldPath = _draftSettings?.backgroundPath ?? '';
    if (oldPath.isNotEmpty) {
      final oldFile = File(oldPath);
      if (await oldFile.exists()) {
        await oldFile.delete().catchError((_) => oldFile);
      }
    }

    final resizedBytes = await _resizeAndEncodeBackground(picked.path);
    if (resizedBytes != null) {
      await File(pngPath).writeAsBytes(resizedBytes, flush: true);
      return pngPath;
    }

    await File(picked.path).copy(fallbackPath);
    return fallbackPath;
  }

  Future<Uint8List?> _resizeAndEncodeBackground(String sourcePath) async {
    ui.ImmutableBuffer? buffer;
    ui.ImageDescriptor? descriptor;
    ui.Codec? codec;
    ui.Image? image;

    try {
      final bytes = await File(sourcePath).readAsBytes();
      buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
      descriptor = await ui.ImageDescriptor.encoded(buffer);

      final width = descriptor.width;
      final height = descriptor.height;
      final scale = math.min(
        1.0,
        math.min(
          _backgroundMaxDimension / width,
          _backgroundMaxDimension / height,
        ),
      );
      final targetWidth = math.max(1, (width * scale).round());
      final targetHeight = math.max(1, (height * scale).round());

      codec = await descriptor.instantiateCodec(
        targetWidth: targetWidth,
        targetHeight: targetHeight,
      );
      final frame = await codec.getNextFrame();
      image = frame.image;
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;
      return byteData.buffer.asUint8List();
    } catch (_) {
      return null;
    } finally {
      image?.dispose();
      codec?.dispose();
      descriptor?.dispose();
      buffer?.dispose();
    }
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
            final settings = _draftSettings;
            if (settings == null) return;

            await context.read<AppState>().updateSettings(settings);

            if (!mounted) return;
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

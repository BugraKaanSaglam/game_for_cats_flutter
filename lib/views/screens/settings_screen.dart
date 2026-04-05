// ignore_for_file: must_be_immutable, use_build_context_synchronously
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:game_for_cats_2025/models/database/db_error.dart';
import 'package:game_for_cats_2025/models/app_settings.dart';
import 'package:game_for_cats_2025/models/enums/enum_functions.dart';
import 'package:game_for_cats_2025/models/enums/game_enums.dart';
import 'package:game_for_cats_2025/l10n/app_localizations.dart';
import 'package:game_for_cats_2025/services/app_analytics.dart';
import 'package:game_for_cats_2025/views/components/main_app_bar.dart';
import 'package:game_for_cats_2025/views/theme/paw_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:game_for_cats_2025/state/app_state.dart';

//* Settings screen:
//* one place where the player configures the next round and optional local customization.
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
    AppAnalytics.screenView('settings');
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
        body: Center(
          child: CircularProgressIndicator(color: PawPalette.bubbleGum),
        ),
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
        child: _draftSettings == null
            ? const SizedBox.shrink()
            : _buildSaveButton(context),
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
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    final l10n = AppLocalizations.of(context)!;
    //! The screen is split into themed panels so it reads like a control deck, not a list of stock settings cells.
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        children: [
          _buildHeader(context, settings),
          _SettingsPanel(
            title: l10n.home_setup_title,
            subtitle: l10n.settings_header_subtitle,
            accent: const [Color(0xFFFF8C42), Color(0xFFFF5D8F)],
            child: Column(
              children: [
                _SettingsFieldTile(
                  icon: Icons.language_rounded,
                  title: l10n.select_language,
                  subtitle: l10n.settings_language_hint,
                  child: _buildLanguageDropdown(context),
                ),
                _SettingsFieldTile(
                  icon: Icons.timer_outlined,
                  title: l10n.select_time,
                  subtitle: l10n.settings_time_hint,
                  child: _buildTimeDropdown(context),
                ),
                _SettingsFieldTile(
                  icon: Icons.track_changes_rounded,
                  title: l10n.select_difficulty,
                  subtitle: l10n.settings_difficulty_hint,
                  child: _buildDifficultyDropdown(context),
                ),
              ],
            ),
          ),
          _SettingsPanel(
            title: l10n.mute_title,
            subtitle: l10n.settings_music_hint,
            accent: const [Color(0xFF00C6A7), Color(0xFF4FACFE)],
            child: Column(
              children: [
                _SettingsToggleTile(
                  icon: Icons.volume_off_rounded,
                  title: l10n.mute_title,
                  subtitle: l10n.mute_subtitle,
                  value: settings.muted,
                  onChanged: (v) =>
                      _updateSettings((current) => current.copyWith(muted: v)),
                  label: l10n.mute_toggle_label,
                ),
                _SettingsToggleTile(
                  icon: Icons.bolt_rounded,
                  title: l10n.lowpower_title,
                  subtitle: l10n.lowpower_subtitle,
                  value: settings.lowPower,
                  onChanged: (v) => _updateSettings(
                    (current) => current.copyWith(lowPower: v),
                  ),
                  label: l10n.lowpower_toggle_label,
                ),
                _SettingsFieldTile(
                  icon: Icons.music_note_rounded,
                  title: l10n.select_musicvolume,
                  subtitle: l10n.settings_music_hint,
                  child: _buildSlider(
                    value: settings.musicVolume,
                    onChanged: (v) => _updateSettings(
                      (current) => current.copyWith(musicVolume: v),
                    ),
                    activeColor: PawPalette.grape,
                  ),
                ),
                _SettingsFieldTile(
                  icon: Icons.pest_control_rodent_rounded,
                  title: l10n.select_charactervolume,
                  subtitle: l10n.settings_character_hint,
                  child: _buildSlider(
                    value: settings.characterVolume,
                    onChanged: (v) => _updateSettings(
                      (current) => current.copyWith(characterVolume: v),
                    ),
                    activeColor: PawPalette.teal,
                  ),
                ),
              ],
            ),
          ),
          _SettingsPanel(
            title: l10n.background_title,
            subtitle: l10n.background_subtitle,
            accent: const [Color(0xFF7B61FF), Color(0xFFFF5D8F)],
            child: _buildBackgroundPicker(context),
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

  Widget _buildHeader(BuildContext context, AppSettings settings) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: const LinearGradient(
          colors: [Color(0xFF20133C), Color(0xFF0E4D68), Color(0xFFFF8C42)],
        ),
        boxShadow: [
          BoxShadow(
            color: PawPalette.midnight.withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.14),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.settings_button,
                      style: PawTextStyles.heading.copyWith(fontSize: 28),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.settings_header_subtitle,
                      style: PawTextStyles.subheading,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HeaderBadge(
                icon: Icons.timer_outlined,
                label: _timeBadgeLabel(l10n, settings.time),
              ),
              _HeaderBadge(
                icon: Icons.track_changes_rounded,
                label: _difficultyBadgeLabel(l10n, settings.difficulty),
              ),
              _HeaderBadge(
                icon: settings.muted
                    ? Icons.volume_off_rounded
                    : Icons.volume_up_rounded,
                label: settings.muted ? l10n.home_muted : l10n.home_sound_on,
              ),
            ],
          ),
        ],
      ),
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

    final settings = _draftSettings;
    if (settings == null) return const SizedBox.shrink();
    return _PillDropdown(
      value: settings.languageCode,
      items: items,
      onChanged: (v) => _updateSettings(
        (current) =>
            current.copyWith(languageCode: v ?? Language.english.value),
      ),
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

    final settings = _draftSettings;
    if (settings == null) return const SizedBox.shrink();
    return _PillDropdown(
      value: settings.time,
      items: items,
      onChanged: (v) => _updateSettings(
        (current) => current.copyWith(time: v ?? Time.fifty.value),
      ),
    );
  }

  Widget _buildDifficultyDropdown(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = [
      DropdownMenuItem(
        value: Difficulty.easy.value,
        child: Text(l10n.difficulty_easy),
      ),
      DropdownMenuItem(
        value: Difficulty.medium.value,
        child: Text(l10n.difficulty_medium),
      ),
      DropdownMenuItem(
        value: Difficulty.hard.value,
        child: Text(l10n.difficulty_hard),
      ),
      DropdownMenuItem(
        value: Difficulty.sandbox.value,
        child: Text(l10n.difficulty_sandbox),
      ),
    ];

    final settings = _draftSettings;
    if (settings == null) return const SizedBox.shrink();
    return _PillDropdown(
      value: settings.difficulty,
      items: items,
      onChanged: (v) => _updateSettings(
        (current) => current.copyWith(difficulty: v ?? Difficulty.easy.value),
      ),
    );
  }

  Widget _buildBackgroundPicker(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final path = _draftSettings?.backgroundPath ?? '';
    final file = path.isNotEmpty ? File(path) : null;
    final hasCustom = file != null && file.existsSync();
    final ImageProvider image = hasCustom
        ? FileImage(file)
        : const AssetImage('assets/images/background.webp');

    if (!hasCustom && path.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _updateSettings((current) => current.copyWith(backgroundPath: ''));
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //* Live preview of the chosen play mat so the user sees the effect before saving.
        AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: PawPalette.midnight.withValues(alpha: 0.08),
                ),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 14,
                ),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.background_selected_snackbar,
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _resetBackground() {
    _updateSettings((current) => current.copyWith(backgroundPath: ''));
  }

  Future<String> _persistPickedImage(XFile picked) async {
    //! Old custom files are deleted when replaced to avoid silent storage growth.
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
    //? Resizing here keeps custom backgrounds cheap enough for gameplay rendering later.
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
            inactiveTrackColor: activeColor.withValues(alpha: 0.3),
            thumbColor: Colors.white,
            overlayColor: activeColor.withValues(alpha: 0.15),
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
    final l10n = AppLocalizations.of(context)!;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.9, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutBack,
      builder: (context, value, child) =>
          Transform.scale(scale: value, child: child),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final messenger = ScaffoldMessenger.of(context);
            final settings = _draftSettings;
            if (settings == null) return;

            await context.read<AppState>().updateSettings(settings);

            if (!mounted) return;
            messenger.showSnackBar(
              SnackBar(
                content: Text(l10n.save_complete_snackbar),
                elevation: 10,
                duration: const Duration(seconds: 2),
              ),
            );
          },
          borderRadius: BorderRadius.circular(28),
          child: Ink(
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: PawPalette.pinkToOrange()),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
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
                    style: PawTextStyles.subheading.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _difficultyBadgeLabel(AppLocalizations l10n, int value) {
    return switch (getDifficultyFromValue(value)) {
      Difficulty.easy => l10n.difficulty_easy,
      Difficulty.medium => l10n.difficulty_medium,
      Difficulty.hard => l10n.difficulty_hard,
      Difficulty.sandbox => l10n.difficulty_sandbox,
    };
  }

  String _timeBadgeLabel(AppLocalizations l10n, int value) {
    final current = getTimeFromValue(value);
    if (current == Time.sandbox) {
      return l10n.difficulty_sandbox;
    }
    return '${current.value}s';
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
        border: Border.all(color: PawPalette.midnight.withValues(alpha: 0.08)),
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

class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel({
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.child,
  });

  final String title;
  final String subtitle;
  final List<Color> accent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    //* Panel wrapper used to visually group related settings instead of exposing a flat form.
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [
            accent.first.withValues(alpha: 0.2),
            accent.last.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: accent.first.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: accent),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(title, style: PawTextStyles.cardTitle)),
            ],
          ),
          const SizedBox(height: 6),
          Text(subtitle, style: PawTextStyles.cardSubtitle),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _SettingsFieldTile extends StatelessWidget {
  const _SettingsFieldTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white.withValues(alpha: 0.9),
          border: Border.all(
            color: PawPalette.midnight.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: PawPalette.midnight.withValues(alpha: 0.08),
                  ),
                  child: Icon(icon, color: PawPalette.ink, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: PawTextStyles.cardTitle),
                      const SizedBox(height: 4),
                      Text(subtitle, style: PawTextStyles.cardSubtitle),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _SettingsToggleTile extends StatelessWidget {
  const _SettingsToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.label,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white.withValues(alpha: 0.9),
          border: Border.all(
            color: PawPalette.midnight.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: PawPalette.midnight.withValues(alpha: 0.08),
                  ),
                  child: Icon(icon, color: PawPalette.ink, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: PawTextStyles.cardTitle),
                      const SizedBox(height: 4),
                      Text(subtitle, style: PawTextStyles.cardSubtitle),
                    ],
                  ),
                ),
              ],
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: value,
              onChanged: onChanged,
              title: Text(label, style: PawTextStyles.cardTitle),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderBadge extends StatelessWidget {
  const _HeaderBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withValues(alpha: 0.12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

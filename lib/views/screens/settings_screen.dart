import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_for_cats_2025/l10n/app_localizations.dart';
import 'package:game_for_cats_2025/models/app_settings.dart';
import 'package:game_for_cats_2025/models/enums/game_enums.dart';
import 'package:game_for_cats_2025/services/app_analytics.dart';
import 'package:game_for_cats_2025/state/app_state.dart';
import 'package:game_for_cats_2025/views/components/hunt_ui.dart';
import 'package:game_for_cats_2025/views/theme/paw_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

/// Persisted hunt, accessibility, language, audio, and playfield settings.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _maxBackgroundDimension = 1280;
  AppSettings? _draft;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    AppAnalytics.screenView('settings');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _draft ??= context.read<AppState>().settings;
  }

  void _update(AppSettings Function(AppSettings current) update) {
    final current = _draft;
    if (current == null) return;
    if (current.haptics) HapticFeedback.selectionClick();
    setState(() => _draft = update(current));
  }

  Future<void> _save() async {
    final draft = _draft;
    if (draft == null || _saving) return;
    setState(() => _saving = true);
    try {
      await context.read<AppState>().updateSettings(draft);
      if (mounted) {
        showHuntSnackBar(
          context,
          message: AppLocalizations.of(context)!.save_complete_snackbar,
          icon: Icons.save_rounded,
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final draft = _draft;
    if (draft == null) {
      return HuntCorePage(showAppBar: false, child: const HuntLoadingState());
    }
    return HuntCorePage(
      title: l10n.settings_button,
      child: HuntCoreViewport(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  HuntSpacing.lg,
                  HuntSpacing.lg,
                  HuntSpacing.lg,
                  HuntSpacing.md,
                ),
                children: [
                  HuntCoreHeader(
                    eyebrow: l10n.settings_button,
                    title: l10n.hunt_setup_title,
                    subtitle: l10n.hunt_setup_subtitle,
                    tone: HuntSurfaceTone.accent,
                  ),
                  const SizedBox(height: HuntSpacing.lg),
                  _HuntSection(
                    title: l10n.start_button,
                    subtitle: l10n.settings_header_subtitle,
                    tone: HuntSurfaceTone.field,
                    children: [
                      _DropdownField(
                        icon: Icons.language_rounded,
                        title: l10n.select_language,
                        subtitle: l10n.language_hint,
                        value: draft.languageCode,
                        items: [
                          DropdownMenuItem(
                            value: Language.turkish.value,
                            child: Text(Language.turkish.name),
                          ),
                          DropdownMenuItem(
                            value: Language.english.value,
                            child: Text(Language.english.name),
                          ),
                        ],
                        onChanged: (value) => _update(
                          (current) => current.copyWith(
                            languageCode: value ?? Language.english.value,
                          ),
                        ),
                      ),
                      _DropdownField(
                        icon: Icons.timer_outlined,
                        title: l10n.select_time,
                        subtitle: l10n.settings_time_hint,
                        value: draft.time,
                        items: [
                          DropdownMenuItem(
                            value: Time.fifty.value,
                            child: Text(Time.fifty.name),
                          ),
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
                            child: Text(l10n.difficulty_sandbox),
                          ),
                        ],
                        onChanged: (value) => _update(
                          (current) =>
                              current.copyWith(time: value ?? Time.fifty.value),
                        ),
                      ),
                      _DropdownField(
                        icon: Icons.speed_rounded,
                        title: l10n.select_difficulty,
                        subtitle: l10n.settings_difficulty_hint,
                        value: draft.difficulty,
                        items: [
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
                        ],
                        onChanged: (value) => _update(
                          (current) => current.copyWith(
                            difficulty: value ?? Difficulty.easy.value,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: HuntSpacing.md),
                  _HuntSection(
                    title: l10n.playfield_title,
                    subtitle: l10n.playfield_subtitle,
                    tone: HuntSurfaceTone.accent,
                    children: [
                      _PlayfieldPicker(draft: draft, onUpdate: _update),
                    ],
                  ),
                  const SizedBox(height: HuntSpacing.md),
                  _HuntSection(
                    title: l10n.hunt_record_details,
                    subtitle: l10n.settings_music_hint,
                    tone: HuntSurfaceTone.field,
                    children: [
                      _ToggleField(
                        icon: Icons.volume_off_outlined,
                        title: l10n.mute_title,
                        subtitle: l10n.mute_subtitle,
                        value: draft.muted,
                        onChanged: (value) => _update(
                          (current) => current.copyWith(muted: value),
                        ),
                      ),
                      _VolumeField(
                        title: l10n.select_musicvolume,
                        value: draft.musicVolume,
                        color: HuntColors.sky,
                        onChanged: (value) => _update(
                          (current) => current.copyWith(musicVolume: value),
                        ),
                      ),
                      _VolumeField(
                        title: l10n.select_charactervolume,
                        value: draft.characterVolume,
                        color: HuntColors.coral,
                        onChanged: (value) => _update(
                          (current) => current.copyWith(characterVolume: value),
                        ),
                      ),
                      _ToggleField(
                        icon: Icons.bolt_outlined,
                        title: l10n.lowpower_title,
                        subtitle: l10n.lowpower_subtitle,
                        value: draft.lowPower,
                        onChanged: (value) => _update(
                          (current) => current.copyWith(lowPower: value),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: HuntSpacing.md),
                  _HuntSection(
                    title: l10n.accessibility_title,
                    subtitle: l10n.accessibility_subtitle,
                    tone: HuntSurfaceTone.accent,
                    children: [
                      _ToggleField(
                        icon: Icons.motion_photos_off_outlined,
                        title: l10n.reduced_motion_title,
                        subtitle: l10n.reduced_motion_subtitle,
                        value: draft.reducedMotion,
                        onChanged: (value) => _update(
                          (current) => current.copyWith(reducedMotion: value),
                        ),
                      ),
                      _ToggleField(
                        icon: Icons.contrast_outlined,
                        title: l10n.high_contrast_title,
                        subtitle: l10n.high_contrast_subtitle,
                        value: draft.highContrast,
                        onChanged: (value) => _update(
                          (current) => current.copyWith(highContrast: value),
                        ),
                      ),
                      _ToggleField(
                        icon: Icons.open_in_full_rounded,
                        title: l10n.larger_targets_title,
                        subtitle: l10n.larger_targets_subtitle,
                        value: draft.largerTargets,
                        onChanged: (value) => _update(
                          (current) => current.copyWith(largerTargets: value),
                        ),
                      ),
                      _ToggleField(
                        icon: Icons.touch_app_outlined,
                        title: l10n.haptics_title,
                        subtitle: l10n.haptics_subtitle,
                        value: draft.haptics,
                        onChanged: (value) => _update(
                          (current) => current.copyWith(haptics: value),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            DecoratedBox(
              decoration: const BoxDecoration(color: Colors.transparent),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    HuntSpacing.lg,
                    HuntSpacing.sm,
                    HuntSpacing.lg,
                    HuntSpacing.md,
                  ),
                  child: HuntActionButton(
                    label: _saving ? l10n.loading : l10n.save_button,
                    icon: Icons.check_rounded,
                    onPressed: _saving ? null : _save,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HuntSection extends StatelessWidget {
  const _HuntSection({
    required this.title,
    required this.subtitle,
    required this.children,
    this.tone = HuntSurfaceTone.paper,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final HuntSurfaceTone tone;

  @override
  Widget build(BuildContext context) {
    return HuntSurface(
      tone: tone,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: HuntTextStyles.sectionTitle),
          const SizedBox(height: HuntSpacing.xs),
          Text(subtitle, style: HuntTextStyles.supporting),
          const SizedBox(height: HuntSpacing.md),
          ...children,
        ],
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final int value;
  final List<DropdownMenuItem<int>> items;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: HuntSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: HuntColors.moss),
          const SizedBox(width: HuntSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: HuntTextStyles.sectionTitle.copyWith(fontSize: 16),
                ),
                Text(subtitle, style: HuntTextStyles.caption),
                const SizedBox(height: HuntSpacing.sm),
                DropdownButtonFormField<int>(
                  initialValue: value,
                  items: items,
                  onChanged: onChanged,
                  decoration: const InputDecoration(isDense: true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleField extends StatelessWidget {
  const _ToggleField({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      label: title,
      child: Material(
        type: MaterialType.transparency,
        child: SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          secondary: Icon(icon, color: HuntColors.moss),
          title: Text(
            title,
            style: HuntTextStyles.sectionTitle.copyWith(fontSize: 16),
          ),
          subtitle: Text(subtitle, style: HuntTextStyles.caption),
          value: value,
          onChanged: onChanged,
          activeThumbColor: HuntColors.moss,
        ),
      ),
    );
  }
}

class _VolumeField extends StatelessWidget {
  const _VolumeField({
    required this.title,
    required this.value,
    required this.color,
    required this.onChanged,
  });

  final String title;
  final double value;
  final Color color;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: HuntTextStyles.supporting)),
        SizedBox(
          width: 190,
          child: SliderTheme(
            data: SliderTheme.of(
              context,
            ).copyWith(activeTrackColor: color, thumbColor: color),
            child: Slider(value: value, min: 0, max: 1, onChanged: onChanged),
          ),
        ),
        SizedBox(
          width: 42,
          child: Text(
            '${(value * 100).round()}%',
            style: HuntTextStyles.caption,
          ),
        ),
      ],
    );
  }
}

class _PlayfieldPicker extends StatelessWidget {
  const _PlayfieldPicker({required this.draft, required this.onUpdate});

  final AppSettings draft;
  final void Function(AppSettings Function(AppSettings current)) onUpdate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final path = draft.backgroundPath;
    final file = path.isEmpty ? null : File(path);
    final hasCustom = file?.existsSync() ?? false;
    final image = hasCustom
        ? FileImage(file!) as ImageProvider
        : const AssetImage('assets/images/background.png');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(HuntRadii.md),
            child: Image(image: image, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: HuntSpacing.md),
        Row(
          children: [
            Expanded(
              child: HuntActionButton(
                label: l10n.background_change_button,
                icon: Icons.photo_library_outlined,
                onPressed: () => _pick(context),
              ),
            ),
            const SizedBox(width: HuntSpacing.sm),
            HuntActionButton(
              label: l10n.background_reset_button,
              secondary: true,
              expand: false,
              onPressed: hasCustom
                  ? () => onUpdate(
                      (current) => current.copyWith(backgroundPath: ''),
                    )
                  : null,
            ),
          ],
        ),
        const SizedBox(height: HuntSpacing.sm),
        Text(l10n.background_hint, style: HuntTextStyles.caption),
      ],
    );
  }

  Future<void> _pick(BuildContext context) async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: _SettingsScreenState._maxBackgroundDimension.toDouble(),
      maxHeight: _SettingsScreenState._maxBackgroundDimension.toDouble(),
    );
    if (picked == null) return;
    final savedPath = await _persist(picked);
    onUpdate((current) => current.copyWith(backgroundPath: savedPath));
    if (context.mounted) {
      showHuntSnackBar(
        context,
        message: AppLocalizations.of(context)!.background_selected_snackbar,
        icon: Icons.photo_library_rounded,
      );
    }
  }

  Future<String> _persist(XFile picked) async {
    final directory = await getApplicationDocumentsDirectory();
    final base = 'playfield_${DateTime.now().millisecondsSinceEpoch}';
    final path = '${directory.path}/$base.png';
    final oldPath = draft.backgroundPath;
    if (oldPath.isNotEmpty) {
      final oldFile = File(oldPath);
      if (await oldFile.exists()) await oldFile.delete();
    }
    final bytes = await _resize(picked.path);
    if (bytes != null) {
      await File(path).writeAsBytes(bytes, flush: true);
      return path;
    }
    return (await File(
      picked.path,
    ).copy('${directory.path}/$base.${picked.name.split('.').last}')).path;
  }

  Future<Uint8List?> _resize(String sourcePath) async {
    ui.ImmutableBuffer? buffer;
    ui.ImageDescriptor? descriptor;
    ui.Codec? codec;
    ui.Image? image;
    try {
      buffer = await ui.ImmutableBuffer.fromUint8List(
        await File(sourcePath).readAsBytes(),
      );
      descriptor = await ui.ImageDescriptor.encoded(buffer);
      final scale = math.min(
        1.0,
        math.min(
          _SettingsScreenState._maxBackgroundDimension / descriptor.width,
          _SettingsScreenState._maxBackgroundDimension / descriptor.height,
        ),
      );
      codec = await descriptor.instantiateCodec(
        targetWidth: math.max(1, (descriptor.width * scale).round()),
        targetHeight: math.max(1, (descriptor.height * scale).round()),
      );
      image = (await codec.getNextFrame()).image;
      return (await image.toByteData(
        format: ui.ImageByteFormat.png,
      ))?.buffer.asUint8List();
    } catch (_) {
      return null;
    } finally {
      image?.dispose();
      codec?.dispose();
      descriptor?.dispose();
      buffer?.dispose();
    }
  }
}

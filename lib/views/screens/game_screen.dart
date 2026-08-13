import 'dart:async';
import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_for_cats_2025/controllers/game_functions.dart';
import 'package:game_for_cats_2025/controllers/utils.dart';
import 'package:game_for_cats_2025/l10n/app_localizations.dart';
import 'package:game_for_cats_2025/models/app_settings.dart';
import 'package:game_for_cats_2025/models/database/db_helper.dart';
import 'package:game_for_cats_2025/models/database/session_log.dart';
import 'package:game_for_cats_2025/models/entities/bug.dart';
import 'package:game_for_cats_2025/models/entities/mice.dart';
import 'package:game_for_cats_2025/models/enums/enum_functions.dart';
import 'package:game_for_cats_2025/models/enums/game_enums.dart';
import 'package:game_for_cats_2025/models/game/hunt_session.dart';
import 'package:game_for_cats_2025/routing/app_routes.dart';
import 'package:game_for_cats_2025/services/app_analytics.dart';
import 'package:game_for_cats_2025/views/components/hunt_ui.dart';
import 'package:game_for_cats_2025/views/components/loading_screen_view.dart';
import 'package:game_for_cats_2025/views/theme/paw_theme.dart';
import 'package:go_router/go_router.dart';

/// Runtime tuning values derived from the selected difficulty.
class DifficultyProfile {
  const DifficultyProfile({
    required this.spawnIntervalSeconds,
    required this.maxActiveCreatures,
    required this.baseSpeed,
    required this.speedRamp,
  });

  final int spawnIntervalSeconds;
  final int maxActiveCreatures;
  final double baseSpeed;
  final double speedRamp;
}

/// Full-screen Flame playfield with Flutter HUD and result presentation.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key, this.settings});

  final AppSettings? settings;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final AppSettings _settings;
  late final HuntSessionState _session;
  late final Game _game;
  HuntResult? _result;
  bool _fieldReady = true;
  bool _starting = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    AppAnalytics.screenView('game');
    _settings = widget.settings ?? AppSettings.defaults();
    _session = HuntSessionState();
    _game = Game(
      settings: _settings,
      session: _session,
      onFinished: _showResult,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _beginHunt());
  }

  @override
  void dispose() {
    _game.pauseEngine();
    unawaited(FlameAudio.bgm.stop());
    _session.dispose();
    super.dispose();
  }

  Future<void> _beginHunt() async {
    if (_starting || !mounted) return;
    _starting = true;
    try {
      await _game.waitUntilReady();
    } catch (_) {
      _starting = false;
      return;
    }
    await Future<void>.delayed(
      _settings.reducedMotion
          ? Duration.zero
          : const Duration(milliseconds: 720),
    );
    if (!mounted) return;
    setState(() => _fieldReady = false);
    try {
      await _game.begin();
    } finally {
      _starting = false;
    }
  }

  void _showResult(HuntResult result) {
    if (!mounted) return;
    setState(() => _result = result);
    unawaited(_saveResult(result));
  }

  Future<void> _saveResult(HuntResult result) async {
    if (_saving) return;
    _saving = true;
    final timestamp = result.startedAt;
    final dateKey =
        '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}';
    await DBHelper().addSessionLog(
      SessionLog(
        dateKey: dateKey,
        timestamp: timestamp,
        durationSeconds: result.durationSeconds,
        configuredDuration: result.configuredDuration,
        difficulty: result.difficulty,
        totalTaps: result.totalTaps,
        successfulTaps: result.successfulTaps,
        miceTaps: result.miceTaps,
        bugTaps: result.bugTaps,
        wrongTaps: result.wrongTaps,
        bestStreak: result.bestStreak,
        completionReason: result.completionReason,
      ),
    );
  }

  Future<void> _restart() async {
    setState(() {
      _result = null;
      _fieldReady = true;
    });
    await _game.restart();
    if (mounted) _beginHunt();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HuntColors.night,
      body: Stack(
        fit: StackFit.expand,
        children: [
          GameWidget(
            game: _game,
            loadingBuilder: (_) => loadingScreen(context),
          ),
          if (_result == null) _LiveHud(session: _session, game: _game),
          if (_fieldReady && _result == null)
            _ReadyOverlay(settings: _settings),
          if (_result != null)
            HuntRecordView(
              result: _result!,
              settings: _settings,
              onAgain: _restart,
              onHome: () => context.go(AppRoutes.main),
            ),
        ],
      ),
    );
  }
}

class _ReadyOverlay extends StatelessWidget {
  const _ReadyOverlay({required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Positioned.fill(
      child: IgnorePointer(
        child: ColoredBox(
          color: HuntColors.night.withValues(alpha: 0.32),
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(HuntSpacing.xl),
              padding: const EdgeInsets.all(HuntSpacing.xl),
              decoration: BoxDecoration(
                color: HuntColors.paper.withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(HuntRadii.lg),
                border: Border.all(color: HuntColors.lineStrong),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.track_changes,
                    color: HuntColors.moss,
                    size: 42,
                  ),
                  const SizedBox(height: HuntSpacing.md),
                  Text(l10n.hunt_ready, style: HuntTextStyles.pageTitle),
                  const SizedBox(height: HuntSpacing.sm),
                  Text(
                    l10n.hunt_ready_subtitle,
                    textAlign: TextAlign.center,
                    style: HuntTextStyles.supporting,
                  ),
                  const SizedBox(height: HuntSpacing.md),
                  HuntTag(
                    label: getTimeFromValue(settings.time) == Time.sandbox
                        ? l10n.difficulty_sandbox
                        : '${getTimeFromValue(settings.time).value}s',
                    icon: Icons.timer_outlined,
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

class _LiveHud extends StatelessWidget {
  const _LiveHud({required this.session, required this.game});

  final HuntSessionState session;
  final Game game;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: session,
          builder: (context, _) {
            final remaining = math.max(
              game.duration - session.elapsedSeconds,
              0,
            );
            final progress = game.duration <= 0
                ? 0.0
                : (remaining / game.duration).clamp(0.0, 1.0);
            final streakTone = session.currentStreak >= 8
                ? HuntColors.sun
                : session.currentStreak >= 4
                ? HuntColors.coral
                : HuntColors.paper;
            return Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Row(
                children: [
                  _FieldButton(
                    icon: Icons.pause_rounded,
                    label: l10n.pause_hunt_title,
                    onTap: () => _showPause(context),
                  ),
                  const SizedBox(width: HuntSpacing.sm),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: HuntSpacing.md,
                        vertical: HuntSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: HuntColors.night.withValues(alpha: 0.86),
                        borderRadius: BorderRadius.circular(HuntRadii.md),
                        border: Border.all(
                          color: HuntColors.paper.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                HuntRadii.pill,
                              ),
                              child: LinearProgressIndicator(
                                minHeight: 7,
                                value: progress,
                                backgroundColor: HuntColors.paper.withValues(
                                  alpha: 0.16,
                                ),
                                color: HuntColors.sun,
                              ),
                            ),
                          ),
                          const SizedBox(width: HuntSpacing.sm),
                          Text(
                            '$remaining',
                            style: HuntTextStyles.metric.copyWith(
                              color: HuntColors.paper,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: HuntSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: streakTone.withValues(alpha: 0.96),
                      borderRadius: BorderRadius.circular(HuntRadii.md),
                    ),
                    child: Column(
                      children: [
                        Text(
                          l10n.current_streak_label,
                          style: HuntTextStyles.caption.copyWith(
                            color: HuntColors.ink,
                          ),
                        ),
                        Text(
                          '${session.currentStreak}',
                          style: HuntTextStyles.metric.copyWith(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showPause(BuildContext context) {
    game.pauseHunt();
    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: HuntColors.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(HuntRadii.lg)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            HuntSpacing.lg,
            HuntSpacing.lg,
            HuntSpacing.lg,
            HuntSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 44, height: 4, color: HuntColors.lineStrong),
              const SizedBox(height: HuntSpacing.lg),
              const Icon(Icons.pause_rounded, color: HuntColors.moss, size: 36),
              const SizedBox(height: HuntSpacing.sm),
              Text(
                AppLocalizations.of(context)!.pause_hunt_title,
                style: HuntTextStyles.sectionTitle,
              ),
              const SizedBox(height: HuntSpacing.xs),
              Text(
                AppLocalizations.of(context)!.pause_hunt_subtitle,
                style: HuntTextStyles.supporting,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: HuntSpacing.lg),
              HuntActionButton(
                label: AppLocalizations.of(context)!.resume_hunt_button,
                icon: Icons.play_arrow_rounded,
                onPressed: () {
                  Navigator.pop(context);
                  game.resumeHunt();
                },
              ),
              const SizedBox(height: HuntSpacing.sm),
              HuntActionButton(
                label: AppLocalizations.of(context)!.end_round_button,
                icon: Icons.stop_circle_outlined,
                secondary: true,
                onPressed: () {
                  Navigator.pop(context);
                  game.finishManually();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldButton extends StatelessWidget {
  const _FieldButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: HuntColors.night.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(HuntRadii.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(HuntRadii.md),
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(icon, color: HuntColors.paper),
          ),
        ),
      ),
    );
  }
}

class Game extends FlameGame with MultiTouchTapDetector, HasCollisionDetection {
  Game({
    required this.settings,
    required this.session,
    required this.onFinished,
  });

  final AppSettings settings;
  final HuntSessionState session;
  final ValueChanged<HuntResult> onFinished;
  final math.Random _random = math.Random();
  final double topInset = 88;
  late GameAssets _assets;
  late Timer _interval;
  late DifficultyProfile _difficultyProfile;
  late final HuntRoundClock _clock = HuntRoundClock(durationSeconds: duration);
  bool _started = false;
  bool _finished = false;

  int get duration => getTimeFromValue(settings.time).value;
  bool get _isMuted => settings.muted;

  int get _maxActiveCreatures => settings.lowPower
      ? math.max((_difficultyProfile.maxActiveCreatures / 2).round(), 4)
      : _difficultyProfile.maxActiveCreatures;

  DifficultyProfile _resolveDifficultyProfile() {
    return switch (getDifficultyFromValue(settings.difficulty)) {
      Difficulty.easy => const DifficultyProfile(
        spawnIntervalSeconds: 5,
        maxActiveCreatures: 8,
        baseSpeed: 55,
        speedRamp: 0.2,
      ),
      Difficulty.medium => const DifficultyProfile(
        spawnIntervalSeconds: 4,
        maxActiveCreatures: 12,
        baseSpeed: 70,
        speedRamp: 0.35,
      ),
      Difficulty.hard => const DifficultyProfile(
        spawnIntervalSeconds: 3,
        maxActiveCreatures: 18,
        baseSpeed: 85,
        speedRamp: 0.5,
      ),
      Difficulty.sandbox => const DifficultyProfile(
        spawnIntervalSeconds: 4,
        maxActiveCreatures: 24,
        baseSpeed: 70,
        speedRamp: 0.1,
      ),
    };
  }

  @override
  Future<void> onLoad() async {
    _difficultyProfile = _resolveDifficultyProfile();
    _assets = await loadGameImagesAndAssets(
      backgroundPath: settings.backgroundPath,
    );
    await loadGameAudio();
    add(ScreenHitbox());
    _interval = Timer(1, onTick: _onSecond, repeat: true);
    _interval.stop();
    await super.onLoad();
  }

  Future<void> waitUntilReady() async {
    await loaded;
    await ready();
  }

  Future<void> begin() async {
    if (_started || _finished) return;
    _started = true;
    _interval.start();
    resumeEngine();
    try {
      await FlameAudio.bgm.play(
        'bird_background_sound.mp3',
        volume: _isMuted ? 0 : settings.musicVolume,
      );
    } catch (_) {
      // Gameplay remains available when the platform cannot play audio.
    }
  }

  void pauseHunt() {
    session.setPaused(true);
    _clock.pause();
    _interval.pause();
    pauseEngine();
  }

  void resumeHunt() {
    session.setPaused(false);
    _clock.resume();
    _interval.resume();
    resumeEngine();
  }

  void finishManually() => _finish(HuntCompletionReason.manual);

  Future<void> restart() async {
    pauseEngine();
    await FlameAudio.bgm.stop();
    _clearCreatures();
    _clearEffects();
    session.reset();
    _clock.reset();
    _finished = false;
    _started = false;
    _interval.stop();
  }

  void _onSecond() {
    if (!_started || _finished || session.isPaused) return;
    final complete = _clock.tick();
    session.setElapsed(_clock.elapsedSeconds);
    if (complete) {
      _finish(HuntCompletionReason.timer);
      return;
    }
    if (_clock.elapsedSeconds %
            math.max(_difficultyProfile.spawnIntervalSeconds, 1) ==
        0) {
      _spawnTarget(_clock.elapsedSeconds);
    }
  }

  @override
  void update(double dt) {
    // Flame's Timer is not a component; it must be advanced by the game loop.
    // Without this call the round starts visually, but the HUD remains frozen
    // at its configured duration and no targets are spawned.
    _interval.update(dt);
    super.update(dt);
  }

  void _spawnTarget(int elapsedSeconds) {
    final active = children
        .whereType<PositionComponent>()
        .where((component) => component is Mice || component is Bug)
        .length;
    if (active >= _maxActiveCreatures) return;
    final position = Vector2(
      _random.nextDouble() * size.x,
      topInset + _random.nextDouble() * math.max(size.y - topInset, 1),
    );
    final velocity = Utils.generateRandomVelocity(size, 10, 100);
    final speed = _currentSpeed(elapsedSeconds);
    if (_random.nextBool()) {
      add(
        Mice(
          position,
          velocity,
          speed,
          _assets.mice,
          topInset: topInset,
          sizeScale: settings.largerTargets ? 1.25 : 1,
          highContrast: settings.highContrast,
        ),
      );
    } else {
      add(
        Bug(
          position,
          velocity,
          speed * 1.2,
          _assets.bug,
          topInset: topInset,
          sizeScale: settings.largerTargets ? 1.25 : 1,
          highContrast: settings.highContrast,
        ),
      );
    }
  }

  double _currentSpeed(int elapsedSeconds) {
    final progress = (elapsedSeconds / math.max(duration, 1)).clamp(0.0, 1.0);
    return _difficultyProfile.baseSpeed *
        (1 + (_difficultyProfile.speedRamp * progress));
  }

  void _finish(HuntCompletionReason reason) {
    if (_finished) return;
    _finished = true;
    _interval.stop();
    pauseEngine();
    unawaited(FlameAudio.bgm.stop());
    _clearCreatures();
    final result = session.result(
      configuredDuration: duration,
      difficulty: settings.difficulty,
      reason: reason,
    );
    onFinished(result);
  }

  void _clearCreatures() {
    for (final child in children.toList()) {
      if (child is Mice || child is Bug) child.removeFromParent();
    }
  }

  void _clearEffects() {
    for (final child in children.toList()) {
      if (child is HuntFeedback) child.removeFromParent();
    }
  }

  @override
  void onTapDown(int pointerId, TapDownInfo info) {
    if (!_started || _finished || session.isPaused) return;
    final point = info.eventPosition.widget;
    Component? hit;
    for (final component in children.toList().reversed) {
      if ((component is Mice || component is Bug) &&
          component.containsPoint(point)) {
        hit = component;
        break;
      }
    }
    if (hit is Mice) {
      session.recordHit(HuntTarget.mice);
      _feedback(hit.position, HuntFeedbackKind.mice, session.currentStreak);
      _haptic();
      _playTap('mice_tap.mp3', settings.characterVolume);
      hit.removeFromParent();
    } else if (hit is Bug) {
      session.recordHit(HuntTarget.bug);
      _feedback(hit.position, HuntFeedbackKind.bug, session.currentStreak);
      _haptic();
      _playTap('bug_tap.wav', settings.characterVolume);
      hit.removeFromParent();
    } else {
      session.recordMiss();
      _feedback(point, HuntFeedbackKind.miss, 0);
      _haptic();
    }
  }

  void _haptic() {
    if (settings.haptics) unawaited(HapticFeedback.selectionClick());
  }

  void _playTap(String file, double volume) {
    unawaited(FlameAudio.play(file, volume: _isMuted ? 0 : volume));
  }

  void _feedback(Vector2 position, HuntFeedbackKind kind, int streak) {
    add(
      HuntFeedback(
        position: position,
        kind: kind,
        streak: streak,
        reducedMotion: settings.reducedMotion,
        highContrast: settings.highContrast,
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    final source = Rect.fromLTWH(
      0,
      0,
      _assets.background.width.toDouble(),
      _assets.background.height.toDouble(),
    );
    canvas.drawImageRect(
      _assets.background,
      source,
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint(),
    );
    if (settings.highContrast) {
      canvas.drawRect(
        Rect.fromLTWH(0, topInset, size.x, size.y - topInset),
        Paint()..color = HuntColors.ink.withValues(alpha: 0.22),
      );
    }
    super.render(canvas);
  }
}

enum HuntFeedbackKind { mice, bug, miss }

class HuntFeedback extends PositionComponent {
  HuntFeedback({
    required Vector2 position,
    required this.kind,
    required this.streak,
    required this.reducedMotion,
    required this.highContrast,
  }) : super(position: position, anchor: Anchor.center, size: Vector2.all(72));

  final HuntFeedbackKind kind;
  final int streak;
  final bool reducedMotion;
  final bool highContrast;
  double age = 0;

  Color get color => switch (kind) {
    HuntFeedbackKind.mice => HuntColors.moss,
    HuntFeedbackKind.bug => HuntColors.coral,
    HuntFeedbackKind.miss => HuntColors.paper,
  };

  @override
  void update(double dt) {
    age += dt;
    if (age > (reducedMotion ? 0.12 : 0.42)) removeFromParent();
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    final duration = reducedMotion ? 0.12 : 0.42;
    final progress = reducedMotion ? 0.35 : (age / duration).clamp(0.0, 1.0);
    final opacity = (1 - progress).clamp(0.0, 1.0);
    final paint = Paint()
      ..color = (highContrast ? HuntColors.paper : color).withValues(
        alpha: opacity,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = highContrast
          ? 6
          : kind == HuntFeedbackKind.miss
          ? 2
          : 4;
    final radius = 10 + (progress * (kind == HuntFeedbackKind.miss ? 20 : 34));
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), radius, paint);
    if (kind != HuntFeedbackKind.miss) {
      final rayPaint = Paint()
        ..color = (highContrast ? HuntColors.paper : color).withValues(
          alpha: opacity,
        )
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      for (var i = 0; i < 6; i++) {
        final angle = (math.pi * 2 / 6) * i;
        final start = Offset(
          size.x / 2 + math.cos(angle) * (radius + 4),
          size.y / 2 + math.sin(angle) * (radius + 4),
        );
        final end = Offset(
          size.x / 2 + math.cos(angle) * (radius + 12),
          size.y / 2 + math.sin(angle) * (radius + 12),
        );
        canvas.drawLine(start, end, rayPaint);
      }
    }
  }
}

class HuntRecordView extends StatelessWidget {
  const HuntRecordView({
    super.key,
    required this.result,
    required this.settings,
    required this.onAgain,
    required this.onHome,
  });

  final HuntResult result;
  final AppSettings settings;
  final VoidCallback onAgain;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final recordTitle = result.accuracy >= 80
        ? l10n.hunt_record_proud
        : l10n.hunt_record_complete;
    final duration = result.configuredDuration >= 100000
        ? l10n.difficulty_sandbox
        : '${result.configuredDuration}s';
    return HuntPageBackground(
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(HuntSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  HuntCoreHeader(
                    eyebrow: l10n.hunt_record_eyebrow,
                    title: recordTitle,
                    subtitle: l10n.hunt_record_subtitle,
                    tone: HuntSurfaceTone.accent,
                  ),
                  const SizedBox(height: HuntSpacing.lg),
                  HuntSurface(
                    tone: HuntSurfaceTone.field,
                    child: Column(
                      children: [
                        Text(
                          '${result.accuracy}%',
                          style: HuntTextStyles.display.copyWith(
                            color: HuntColors.moss,
                          ),
                        ),
                        const SizedBox(height: HuntSpacing.xs),
                        Text(
                          l10n.hunt_record_accuracy,
                          style: HuntTextStyles.supporting,
                        ),
                        const SizedBox(height: HuntSpacing.md),
                        Row(
                          children: [
                            HuntMetric(
                              label: l10n.hunt_record_hits,
                              value: '${result.successfulTaps}',
                              accent: HuntColors.moss,
                            ),
                            const SizedBox(width: HuntSpacing.sm),
                            HuntMetric(
                              label: l10n.hunt_record_misses,
                              value: '${result.wrongTaps}',
                              accent: HuntColors.terracotta,
                            ),
                            const SizedBox(width: HuntSpacing.sm),
                            HuntMetric(
                              label: l10n.best_streak_label,
                              value: '${result.bestStreak}',
                              accent: HuntColors.coral,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: HuntSpacing.md),
                  HuntSurface(
                    tone: HuntSurfaceTone.accent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.hunt_record_details,
                          style: HuntTextStyles.sectionTitle,
                        ),
                        const SizedBox(height: HuntSpacing.md),
                        Wrap(
                          spacing: HuntSpacing.sm,
                          runSpacing: HuntSpacing.sm,
                          children: [
                            HuntTag(
                              label: duration,
                              icon: Icons.timer_outlined,
                            ),
                            HuntTag(
                              label: _difficultyLabel(
                                l10n,
                                settings.difficulty,
                              ),
                              icon: Icons.track_changes_outlined,
                            ),
                            HuntTag(
                              label: '${l10n.micetap_count} ${result.miceTaps}',
                              tone: HuntTagTone.success,
                            ),
                            HuntTag(
                              label: '${l10n.bugtap_count} ${result.bugTaps}',
                              tone: HuntTagTone.accent,
                            ),
                          ],
                        ),
                        const SizedBox(height: HuntSpacing.md),
                        Text(
                          result.completionReason == HuntCompletionReason.manual
                              ? l10n.hunt_record_manual_end
                              : l10n.hunt_record_timer_end,
                          style: HuntTextStyles.supporting,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: HuntSpacing.lg),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final buttons = [
                        HuntActionButton(
                          label: l10n.hunt_again,
                          icon: Icons.replay_rounded,
                          onPressed: onAgain,
                        ),
                        HuntActionButton(
                          label: l10n.return_mainmenu_button,
                          icon: Icons.home_rounded,
                          secondary: true,
                          onPressed: onHome,
                        ),
                      ];

                      if (constraints.maxWidth < 520) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            buttons[0],
                            const SizedBox(height: HuntSpacing.sm),
                            buttons[1],
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(child: buttons[0]),
                          const SizedBox(width: HuntSpacing.sm),
                          Expanded(child: buttons[1]),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _difficultyLabel(AppLocalizations l10n, int value) =>
      switch (getDifficultyFromValue(value)) {
        Difficulty.easy => l10n.difficulty_easy,
        Difficulty.medium => l10n.difficulty_medium,
        Difficulty.hard => l10n.difficulty_hard,
        Difficulty.sandbox => l10n.difficulty_sandbox,
      };
}

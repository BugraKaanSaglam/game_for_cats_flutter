// ignore_for_file: must_be_immutable, use_build_context_synchronously, deprecated_member_use
import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:game_for_cats_2025/models/notifiers/game_classes.dart';
import 'package:game_for_cats_2025/models/app_settings.dart';
import 'package:game_for_cats_2025/views/components/loading_screen_view.dart';
import 'package:game_for_cats_2025/models/global/global_variables.dart';
import 'package:game_for_cats_2025/models/entities/bug.dart';
import 'package:game_for_cats_2025/models/entities/mice.dart';
import 'package:game_for_cats_2025/models/global/global_images.dart';
import 'package:game_for_cats_2025/controllers/utils.dart';
import 'package:game_for_cats_2025/l10n/app_localizations.dart';
import 'package:game_for_cats_2025/views/theme/paw_theme.dart';
import 'package:game_for_cats_2025/controllers/game_functions.dart';
import 'package:game_for_cats_2025/models/enums/enum_functions.dart';
import 'package:game_for_cats_2025/models/enums/game_enums.dart';
import 'package:game_for_cats_2025/models/database/db_helper.dart';
import 'package:game_for_cats_2025/models/database/session_log.dart';
import 'package:game_for_cats_2025/routing/app_routes.dart';
import 'package:game_for_cats_2025/services/app_analytics.dart';

//* Gameplay bridge file:
//* - hosts the Flame game instance
//* - renders Flutter HUD / dialogs around it
//* - translates taps + timers into a round summary
bool isBackButtonClicked = false;
int elapsedTicks = 0; // Seconds
ValueNotifier<int> elapsedTicksNotifier = ValueNotifier<int>(0);
bool isBackButtonDialogOpen = false;
GameClicksCounter clicksCounter = GameClicksCounter();
bool isOverlayBlocking = false;
bool isGameOverTriggered = false;
GameResult? lastGameResult;
bool hasSessionLogged = false;

//! This reset method must clear every global round flag because Flame and Flutter overlays share these globals.
void resetRoundState({bool clearResult = true}) {
  clicksCounter.reset();
  elapsedTicks = 0;
  elapsedTicksNotifier.value = 0;
  isOverlayBlocking = false;
  isGameOverTriggered = false;
  isBackButtonDialogOpen = false;
  isBackButtonClicked = false;
  hasSessionLogged = false;
  if (clearResult) {
    lastGameResult = null;
  }
}

class GameResult {
  GameResult({
    required this.totalTaps,
    required this.miceTaps,
    required this.bugTaps,
    required this.wrongTaps,
    required this.bestStreak,
  });

  final int totalTaps;
  final int miceTaps;
  final int bugTaps;
  final int wrongTaps;
  final int bestStreak;

  factory GameResult.fromCounter(GameClicksCounter counter) {
    //? wrong taps are derived so the notifier only needs to track the raw categories.
    final wrong = counter.totalTaps - (counter.bugTaps + counter.miceTaps);
    return GameResult(
      totalTaps: counter.totalTaps,
      miceTaps: counter.miceTaps,
      bugTaps: counter.bugTaps,
      wrongTaps: max(wrong, 0),
      bestStreak: counter.bestStreak,
    );
  }
}

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

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, this.settings});

  final AppSettings? settings;
  @override
  State<GameScreen> createState() => _GameScreenState();
}

//* End-of-round dialog:
//* this is one of the key "signature" surfaces reviewers see in screenshots.
Dialog endGameDialog(BuildContext context, {required Game game}) {
  isOverlayBlocking = true;
  game.pauseEngine();
  final stats = lastGameResult ?? GameResult.fromCounter(clicksCounter);
  final wrongTaps = stats.wrongTaps;
  final successfulTaps = stats.miceTaps + stats.bugTaps;
  final accuracy = stats.totalTaps == 0
      ? 0
      : ((successfulTaps / stats.totalTaps) * 100).round();
  final l10n = AppLocalizations.of(context)!;
  final mood = _resolveCatMood(
    l10n,
    accuracy: accuracy,
    bestStreak: stats.bestStreak,
    totalTaps: stats.totalTaps,
  );
  final grade = _resolveHuntGrade(
    accuracy: accuracy,
    bestStreak: stats.bestStreak,
    totalTaps: stats.totalTaps,
  );
  final dialogWidth = min(MediaQuery.of(context).size.width * 0.92, 440.0);
  return Dialog(
    insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
    backgroundColor: Colors.transparent,
    child: SizedBox(
      width: dialogWidth,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(
            colors: [Color(0xFF160F34), Color(0xFF372D74), Color(0xFFFF5D8F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: PawPalette.midnight.withValues(alpha: 0.42),
              blurRadius: 30,
              offset: const Offset(0, 20),
            ),
          ],
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ResultHeroBurst(
              title: l10n.game_over,
              accuracy: accuracy,
              grade: grade,
              mood: mood,
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _ResultSummaryChip(
                    label: l10n.activity_total_label,
                    value: '${stats.totalTaps}',
                    accent: PawPalette.lemon,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ResultSummaryChip(
                    label: l10n.activity_accuracy_label,
                    value: '$accuracy%',
                    accent: PawPalette.teal,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ResultSummaryChip(
                    label: l10n.best_streak_label,
                    value: '${stats.bestStreak}',
                    accent: PawPalette.bubbleGum,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _StatResultTile(
              icon: Icons.pest_control,
              label: l10n.bugtap_count,
              value: stats.bugTaps,
              color: PawPalette.bubbleGum,
            ),
            _StatResultTile(
              icon: Icons.pets,
              label: l10n.micetap_count,
              value: stats.miceTaps,
              color: PawPalette.teal,
            ),
            _StatResultTile(
              icon: Icons.cancel_outlined,
              label: l10n.wrongtap_count,
              value: wrongTaps,
              color: const Color(0xFFFFB347),
            ),
            const SizedBox(height: 28),
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: _DialogActionButton(
                    color: PawPalette.bubbleGum,
                    icon: Icons.refresh,
                    label: l10n.tryagain_button,
                    onPressed: () async {
                      Navigator.pop(context);
                      await game.restart();
                    },
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: _DialogActionButton(
                    color: Colors.white,
                    foregroundColor: PawPalette.midnight,
                    icon: Icons.home,
                    label: l10n.return_mainmenu_button,
                    onPressed: () async => await closeGame(
                      game,
                      context,
                      routePath: AppRoutes.main,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

//* Shared exit path used by both pause flow and normal game-over flow.
Future<void> closeGame(
  Game game,
  BuildContext context, {
  String? routePath,
  Object? extra,
}) async {
  lastGameResult ??= GameResult.fromCounter(clicksCounter);
  await game._persistSessionResult();
  await FlameAudio.bgm.stop();
  game.pauseEngine();
  isOverlayBlocking = false;
  isGameOverTriggered = false;
  isBackButtonDialogOpen = false;

  if (routePath != null && context.mounted) {
    if (extra == null) {
      context.go(routePath);
      return;
    }
    context.go(routePath, extra: extra);
  }
  isBackButtonClicked = false;
}

//* Pause / leave-round dialog.
Dialog backButtonDialog(Game game, BuildContext context) {
  isBackButtonDialogOpen = true;
  isOverlayBlocking = true;
  game.pauseEngine();
  final l10n = AppLocalizations.of(context)!;
  final dialogWidth = min(MediaQuery.of(context).size.width * 0.92, 420.0);
  return Dialog(
    insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
    backgroundColor: Colors.transparent,
    child: SizedBox(
      width: dialogWidth,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            colors: [Color(0xFF2A2D3E), Color(0xFF1E1F29)],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.pause_circle_outline_rounded,
              color: Colors.white,
              size: 46,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.pause_hunt_title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.pause_hunt_subtitle,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PawPalette.teal,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      isBackButtonDialogOpen = false;
                      isOverlayBlocking = false;
                      game.resumeEngine();
                      Navigator.pop(context);
                    },
                    child: Text(
                      l10n.resume_hunt_button,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () async {
                      isBackButtonDialogOpen = false;
                      isOverlayBlocking = false;
                      Navigator.pop(context);
                      await closeGame(game, context);
                      showDialog(
                        context: context,
                        builder: (context) =>
                            endGameDialog(context, game: game),
                      );
                    },
                    child: Text(
                      l10n.end_round_button,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

//* Auto-close helper used when the player briefly opens the pause dialog and does nothing.
void closeDialogAutomatically(Game game, BuildContext context) {
  if (!isBackButtonDialogOpen) return;
  if (context.mounted == true) {
    Navigator.pop(context);
  }
  isBackButtonDialogOpen = false;
  isOverlayBlocking = false;
  game.resumeEngine();
}

class _GameScreenState extends State<GameScreen> {
  late final Game _gameInstance;
  late final AppSettings? _gameSettings;

  @override
  void initState() {
    super.initState();
    resetRoundState();
    AppAnalytics.screenView('game');
    _gameSettings = widget.settings;
    _gameInstance = Game(_gameSettings, context);
  }

  @override
  void dispose() {
    _gameInstance.pauseEngine();
    unawaited(FlameAudio.bgm.stop());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          //* Flame owns the actual moving targets; Flutter only frames the experience around it.
          Positioned.fill(
            child: GameWidget(
              game: _gameInstance,
              loadingBuilder: (p0) => loadingScreen(context),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                child: _buildTopHud(context),
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 20,
            child: _buildStatsBar(context),
          ),
          if (isOverlayBlocking)
            Positioned.fill(
              child: IgnorePointer(
                ignoring: true,
                child: Container(color: Colors.black54),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopHud(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    //! This replaced the stock AppBar so gameplay feels like a bespoke toy, not a standard app page.
    return Row(
      children: [
        _HudRoundButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () => showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              isBackButtonClicked = true;
              Future.delayed(
                const Duration(seconds: 2),
                () => closeDialogAutomatically(_gameInstance, context),
              );
              return backButtonDialog(_gameInstance, context);
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ValueListenableBuilder<int>(
            valueListenable: elapsedTicksNotifier,
            builder: (context, elapsed, _) {
              final remainingTime = max(gameTimer - elapsed, 0);
              final progress = 1 - ((elapsed / gameTimer).clamp(0.0, 1.0));
              return _TimerNestCard(
                label: l10n.countdown.trim(),
                remainingTime: remainingTime,
                progress: progress.isFinite ? progress : 0,
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        AnimatedBuilder(
          animation: clicksCounter,
          builder: (context, _) => _TopComboDock(
            current: clicksCounter.currentStreak,
            best: clicksCounter.bestStreak,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsBar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = _gameSettings;
    //* Bottom deck:
    //* quick round config + live counters + progress, all visible without opening a menu.
    return AnimatedBuilder(
      animation: clicksCounter,
      builder: (context, _) {
        final wrongTaps = max(
          clicksCounter.totalTaps -
              (clicksCounter.bugTaps + clicksCounter.miceTaps),
          0,
        );
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              colors: [Color(0xE0120B2E), Color(0xE01F3F63), Color(0xD900C6A7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: PawPalette.midnight.withValues(alpha: 0.26),
                blurRadius: 20,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (settings != null) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MiniHudTag(
                      icon: Icons.track_changes_rounded,
                      label: switch (getDifficultyFromValue(
                        settings.difficulty,
                      )) {
                        Difficulty.easy => l10n.difficulty_easy,
                        Difficulty.medium => l10n.difficulty_medium,
                        Difficulty.hard => l10n.difficulty_hard,
                        Difficulty.sandbox => l10n.difficulty_sandbox,
                      },
                    ),
                    _MiniHudTag(
                      icon: Icons.timer_outlined,
                      label: getTimeFromValue(settings.time) == Time.sandbox
                          ? l10n.difficulty_sandbox
                          : '${getTimeFromValue(settings.time).value}s',
                    ),
                    _MiniHudTag(
                      icon: settings.muted
                          ? Icons.volume_off_rounded
                          : Icons.volume_up_rounded,
                      label: settings.muted
                          ? l10n.home_muted
                          : l10n.home_sound_on,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              ValueListenableBuilder<int>(
                valueListenable: elapsedTicksNotifier,
                builder: (context, elapsed, _) {
                  final progress = (elapsed / gameTimer).clamp(0.0, 1.0);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _StreakPill(
                              label: l10n.current_streak_label,
                              value: clicksCounter.currentStreak,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _StreakPill(
                              label: l10n.best_streak_label,
                              value: clicksCounter.bestStreak,
                              accent: PawPalette.teal,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: progress.isFinite ? progress : 0,
                        backgroundColor: Colors.white24,
                        color: PawPalette.lemon,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      const SizedBox(height: 12),
                    ],
                  );
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: _StatChip(
                      icon: Icons.pets,
                      label: l10n.micetap_count,
                      value: clicksCounter.miceTaps,
                      color: PawPalette.teal,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatChip(
                      icon: Icons.bug_report,
                      label: l10n.bugtap_count,
                      value: clicksCounter.bugTaps,
                      color: PawPalette.bubbleGum,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatChip(
                      icon: Icons.touch_app,
                      label: l10n.wrongtap_count,
                      value: wrongTaps,
                      color: PawPalette.lemon,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class Game extends FlameGame
    with TapDetector, HasGameRef, HasCollisionDetection {
  Game(this.gameSettings, this.context);

  BuildContext context;
  AppSettings? gameSettings;
  final Random _random = Random();
  bool get _isMuted => gameSettings?.muted ?? false;

  late Timer interval; // Time Variable
  late DifficultyProfile _difficultyProfile;

  @override
  bool get debugMode => false;

  DifficultyProfile _resolveDifficultyProfile() {
    //? Difficulty controls both density and motion speed so rounds feel materially different.
    final difficulty = getDifficultyFromValue(gameSettings?.difficulty);
    final baseProfile = switch (difficulty) {
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

    if (gameSettings?.lowPower ?? false) {
      //! Low power intentionally reduces both active count and speed so older devices stay smooth.
      return DifficultyProfile(
        spawnIntervalSeconds: baseProfile.spawnIntervalSeconds + 1,
        maxActiveCreatures: max(
          4,
          (baseProfile.maxActiveCreatures * 0.6).round(),
        ),
        baseSpeed: baseProfile.baseSpeed * 0.7,
        speedRamp: baseProfile.speedRamp * 0.5,
      );
    }

    return baseProfile;
  }

  Future<void> _startBackgroundAudio() async {
    await FlameAudio.bgm.play(
      'bird_background_sound.mp3',
      volume: _isMuted ? 0 : (gameSettings?.musicVolume ?? 1),
    );
  }

  @override
  Future<void> onLoad() async {
    _difficultyProfile = _resolveDifficultyProfile();
    try {
      await loadGameAudio();
      await loadGameImagesAndAssets(
        backgroundPath: gameSettings?.backgroundPath,
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("${AppLocalizations.of(context)!.error} \n $e"),
          content: Text(e.toString()),
        ),
      );
    }
    //* Add world bounds before creatures spawn so collision callbacks can work from the first tick.
    add(ScreenHitbox());
    await _startBackgroundAudio();

    interval = Timer(
      1.0,
      onTick: () async {
        //! Spawn cadence is timer-driven, not frame-driven, so gameplay stays stable across device performance.
        if (isOverlayBlocking || isGameOverTriggered) return;
        if (_shouldSpawnThisTick(elapsedTicks)) {
          final activeCreatures = children
              .where((component) => component is Mice || component is Bug)
              .length;
          if (activeCreatures < _difficultyProfile.maxActiveCreatures) {
            final startingSpeed = _currentSpeed(elapsedTicks);
            final startPosition = Vector2(
              0,
              gameScreenTopBarHeight +
                  _random.nextDouble() * (size.y - gameScreenTopBarHeight),
            );
            final startRndVelocity = Utils.generateRandomVelocity(
              size,
              10,
              100,
            );
            if (_random.nextBool()) {
              add(Mice(startPosition, startRndVelocity, startingSpeed));
            } else {
              add(Bug(startPosition, startRndVelocity, startingSpeed));
            }
          }
        }
        elapsedTicks++;
        elapsedTicksNotifier.value = elapsedTicks;
        if (elapsedTicks >= gameTimer) {
          await _handleGameOver();
        }
      },
      repeat: true,
    );
    return super.onLoad();
  }

  Future<void> restart() async {
    //? Restart preserves the same settings but rebuilds the runtime round state from scratch.
    pauseEngine();
    await FlameAudio.bgm.stop();
    _clearCreatures();
    resetRoundState();
    _difficultyProfile = _resolveDifficultyProfile();
    interval.start();
    await _startBackgroundAudio();
    resumeEngine();
  }

  void _clearCreatures() {
    final toRemove = children
        .where((component) => component is Mice || component is Bug)
        .toList();
    for (final component in toRemove) {
      component.removeFromParent();
    }
  }

  Future<void> _handleGameOver() async {
    if (isGameOverTriggered) return;
    isGameOverTriggered = true;
    isOverlayBlocking = true;
    lastGameResult = GameResult.fromCounter(clicksCounter);
    await _persistSessionResult();
    pauseEngine();
    await FlameAudio.bgm.stop();
    showDialog(
      context: context,
      builder: (context) => endGameDialog(context, game: this),
    );
  }

  bool _shouldSpawnThisTick(int elapsedSeconds) {
    final intervalSeconds = max(_difficultyProfile.spawnIntervalSeconds, 1);
    return elapsedSeconds % intervalSeconds == 0;
  }

  double _currentSpeed(int elapsedSeconds) {
    final effectiveDuration = max(gameTimer, 1);
    final progress = (elapsedSeconds / effectiveDuration).clamp(0.0, 1.0);
    final rampMultiplier = 1 + (_difficultyProfile.speedRamp * progress);
    return _difficultyProfile.baseSpeed * rampMultiplier;
  }

  Future<void> _persistSessionResult() async {
    if (hasSessionLogged || lastGameResult == null) return;
    final result = lastGameResult!;
    final dbHelper = DBHelper();
    final log = SessionLog(
      dateKey: _todayKey(),
      totalTaps: result.totalTaps,
      wrongTaps: result.wrongTaps,
    );
    await dbHelper.addSessionLog(log);
    hasSessionLogged = true;
  }

  String _todayKey() {
    final now = DateTime.now();
    final mm = now.month.toString().padLeft(2, '0');
    final dd = now.day.toString().padLeft(2, '0');
    return '${now.year}-$mm-$dd';
  }

  @override
  void update(double dt) {
    super.update(dt);
    interval.update(dt);
  }

  @override
  void onTapDown(TapDownInfo info) {
    super.onTapDown(info);
    final touchPoint = info.eventPosition.widget;
    bool hitAnything = false;
    //* Hit detection is handled by asking each live creature if the touch landed inside its bounds.
    children.any((component) {
      if (component is Mice && component.containsPoint(touchPoint)) {
        FlameAudio.play(
          'mice_tap.mp3',
          volume: _isMuted ? 0 : (gameSettings?.characterVolume ?? 1),
        );
        clicksCounter.recordMiceTap();
        remove(component);
        hitAnything = true;
        return true;
      } else if (component is Bug && component.containsPoint(touchPoint)) {
        FlameAudio.play(
          'bug_tap.wav',
          volume: _isMuted ? 0 : (gameSettings?.characterVolume ?? 1),
        );
        clicksCounter.recordBugTap();
        remove(component);
        hitAnything = true;
        return true;
      }
      return false;
    });

    if (!hitAnything) {
      //! Misses are important because they reset streaks and feed the end-of-round accuracy.
      clicksCounter.recordMissTap();
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawImageRect(
      globalBackgroundImage,
      const Rect.fromLTWH(0, 0, 1024, 1024),
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint(),
    );
    super.render(canvas);
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            '$value',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _ResultSummaryChip extends StatelessWidget {
  const _ResultSummaryChip({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: accent,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultHeroBurst extends StatelessWidget {
  const _ResultHeroBurst({
    required this.title,
    required this.accuracy,
    required this.grade,
    required this.mood,
  });

  final String title;
  final int accuracy;
  final String grade;
  final _CatMood mood;

  @override
  Widget build(BuildContext context) {
    //? The grade ring is intentionally high-contrast because it will likely appear in screenshots.
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 126,
              height: 126,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    mood.color.withValues(alpha: 0.34),
                    Colors.white.withValues(alpha: 0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 102,
              height: 102,
              child: CircularProgressIndicator(
                value: (accuracy / 100).clamp(0, 1).toDouble(),
                strokeWidth: 8,
                color: mood.color,
                backgroundColor: Colors.white12,
              ),
            ),
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
                border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    grade,
                    style: TextStyle(
                      color: mood.color,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    '$accuracy%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        _MoodBadge(mood: mood),
      ],
    );
  }
}

class _MoodBadge extends StatelessWidget {
  const _MoodBadge({required this.mood});

  final _CatMood mood;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: mood.color.withValues(alpha: 0.16),
        border: Border.all(color: mood.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(mood.icon, color: mood.color, size: 18),
          const SizedBox(width: 8),
          Text(
            mood.label,
            style: TextStyle(color: mood.color, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _HudRoundButton extends StatelessWidget {
  const _HudRoundButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: PawPalette.midnight.withValues(alpha: 0.72),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            boxShadow: [
              BoxShadow(
                color: PawPalette.midnight.withValues(alpha: 0.22),
                blurRadius: 16,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}

class _TimerNestCard extends StatelessWidget {
  const _TimerNestCard({
    required this.label,
    required this.remainingTime,
    required this.progress,
  });

  final String label;
  final int remainingTime;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xDD120B2E), Color(0xDD2E215B)],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 4,
                  color: PawPalette.lemon,
                  backgroundColor: Colors.white12,
                ),
                const Icon(
                  Icons.access_time_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '$remainingTime',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopComboDock extends StatelessWidget {
  const _TopComboDock({required this.current, required this.best});

  final int current;
  final int best;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 108,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xDDFE5D8F), Color(0xDDFF8C42)],
        ),
        boxShadow: [
          BoxShadow(
            color: PawPalette.bubbleGum.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: current > 0 ? 16 : 14,
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Purr',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '$current',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            'Best $best',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniHudTag extends StatelessWidget {
  const _MiniHudTag({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withValues(alpha: 0.08),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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

class _StreakPill extends StatelessWidget {
  const _StreakPill({
    required this.label,
    required this.value,
    this.accent = PawPalette.bubbleGum,
  });

  final String label;
  final int value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withValues(alpha: 0.08),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome_rounded, color: accent, size: 16),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              '$label $value',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatResultTile extends StatelessWidget {
  const _StatResultTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.22),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$value',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogActionButton extends StatelessWidget {
  const _DialogActionButton({
    required this.color,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.foregroundColor = Colors.white,
  });

  final Color color;
  final Color foregroundColor;
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: foregroundColor,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(
        label,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _CatMood {
  const _CatMood({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;
}

_CatMood _resolveCatMood(
  AppLocalizations l10n, {
  required int accuracy,
  required int bestStreak,
  required int totalTaps,
}) {
  if (totalTaps == 0) {
    return _CatMood(
      label: l10n.cat_mood_warming_up,
      color: const Color(0xFFFFB347),
      icon: Icons.nights_stay_rounded,
    );
  }

  if (accuracy >= 85 && bestStreak >= 5) {
    return _CatMood(
      label: l10n.cat_mood_hunt_legend,
      color: PawPalette.lemon,
      icon: Icons.workspace_premium_rounded,
    );
  }

  if (accuracy >= 65) {
    return _CatMood(
      label: l10n.cat_mood_playful,
      color: PawPalette.teal,
      icon: Icons.pets_rounded,
    );
  }

  return _CatMood(
    label: l10n.cat_mood_curious,
    color: PawPalette.bubbleGum,
    icon: Icons.visibility_rounded,
  );
}

String _resolveHuntGrade({
  required int accuracy,
  required int bestStreak,
  required int totalTaps,
}) {
  if (totalTaps == 0) return 'C';
  if (accuracy >= 90 && bestStreak >= 6) return 'S';
  if (accuracy >= 80) return 'A';
  if (accuracy >= 65) return 'B';
  return 'C';
}

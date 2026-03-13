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

bool isBackButtonClicked = false;
int elapsedTicks = 0; // Seconds
ValueNotifier<int> elapsedTicksNotifier = ValueNotifier<int>(0);
bool isBackButtonDialogOpen = false;
GameClicksCounter clicksCounter = GameClicksCounter();
bool isOverlayBlocking = false;
bool isGameOverTriggered = false;
GameResult? lastGameResult;
bool hasSessionLogged = false;

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
  });

  final int totalTaps;
  final int miceTaps;
  final int bugTaps;
  final int wrongTaps;

  factory GameResult.fromCounter(GameClicksCounter counter) {
    final wrong = counter.totalTaps - (counter.bugTaps + counter.miceTaps);
    return GameResult(
      totalTaps: counter.totalTaps,
      miceTaps: counter.miceTaps,
      bugTaps: counter.bugTaps,
      wrongTaps: max(wrong, 0),
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

//* Alert for End Game
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
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
              ),
              child: const Icon(
                Icons.celebration_rounded,
                color: Colors.amber,
                size: 42,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.game_over,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _ResultSummaryChip(
                    label: l10n.activity_total_label,
                    value: '${stats.totalTaps}',
                    accent: PawPalette.lemon,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ResultSummaryChip(
                    label: l10n.activity_accuracy_label,
                    value: '$accuracy%',
                    accent: PawPalette.teal,
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

//* Game Ended, After This Function Triggers
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

//* Alert for BackButtonClicked
Dialog backButtonDialog(Game game, BuildContext context) {
  isBackButtonDialogOpen = true;
  isOverlayBlocking = true;
  game.pauseEngine();
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
            const Icon(Icons.logout, color: Colors.white, size: 46),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.exit_validation,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(
                context,
              )!.this_will_close_automatically_in_seconds,
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
                      AppLocalizations.of(context)!.i_am_cat,
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
                      AppLocalizations.of(context)!.i_am_human,
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

//* Function to close the dialog
void closeDialogAutomatically(Game game, BuildContext context) {
  if (!isBackButtonDialogOpen) return;
  if (context.mounted == true) {
    Navigator.pop(context);
  }
  isBackButtonDialogOpen = false;
  isOverlayBlocking = false;
  game.resumeEngine();
}

PreferredSizeWidget gameAppBar(BuildContext context, Game game) {
  return AppBar(
    automaticallyImplyLeading: false,
    backgroundColor: Colors.transparent,
    elevation: 0,
    flexibleSpace: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E1F29), Color(0xFF3B1D60)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    ),
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
      onPressed: () => showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          isBackButtonClicked = true;
          Future.delayed(
            const Duration(seconds: 2),
            () => closeDialogAutomatically(game, context),
          );
          return backButtonDialog(game, context);
        },
      ),
    ),
    title: ValueListenableBuilder<int>(
      valueListenable: elapsedTicksNotifier,
      builder: (context, elapsedTicks, _) {
        final remainingTime = max(gameTimer - elapsedTicks, 0);
        final label = remainingTime > 0
            ? '${AppLocalizations.of(context)!.countdown} $remainingTime'
            : AppLocalizations.of(context)!.game_over;
        return Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    ),
    actions: const [],
  );
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
      appBar: gameAppBar(context, _gameInstance),
      body: Stack(
        children: [
          Positioned.fill(
            child: GameWidget(
              game: _gameInstance,
              loadingBuilder: (p0) => loadingScreen(context),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
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

  Widget _buildStatsBar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              colors: [Color(0xD9160F34), Color(0xD92E215B), Color(0xCCFF5D8F)],
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
              ValueListenableBuilder<int>(
                valueListenable: elapsedTicksNotifier,
                builder: (context, elapsed, _) {
                  final progress = (elapsed / gameTimer).clamp(0.0, 1.0);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      LinearProgressIndicator(
                        value: progress.isFinite ? progress : 0,
                        backgroundColor: Colors.white24,
                        color: Colors.amberAccent,
                        minHeight: 6,
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
    //Add Collision
    add(ScreenHitbox());
    await _startBackgroundAudio();

    interval = Timer(
      1.0,
      onTick: () async {
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
        elapsedTicksNotifier.value = elapsedTicks; // Update the ValueNotifier
        if (elapsedTicks >= gameTimer) {
          await _handleGameOver();
        }
      },
      repeat: true,
    );
    return super.onLoad();
  }

  Future<void> restart() async {
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

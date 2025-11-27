// ignore_for_file: must_be_immutable, use_build_context_synchronously, deprecated_member_use
import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:game_for_cats_2025/models/notifiers/game_classes.dart';
import 'package:game_for_cats_2025/models/database/opc_database_list.dart';
import 'package:game_for_cats_2025/views/components/loading_screen_view.dart';
import 'package:game_for_cats_2025/models/global/argument_sender.dart';
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

bool isBackButtonClicked = false;
int elapsedTicks = 0; // Seconds
ValueNotifier<int> elapsedTicksNotifier = ValueNotifier<int>(0);
bool isBackButtonDialogOpen = false;
FlameGame<World>? _game;
GameClicksCounter clicksCounter = GameClicksCounter();
OPCDataBase? _gameDatabase;
bool isOverlayBlocking = false;
bool isGameOverTriggered = false;
GameResult? lastGameResult;

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
  const GameScreen({super.key});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

//* Alert for End Game
Dialog endGameDialog(BuildContext context) {
  isOverlayBlocking = true;
  _game?.pauseEngine();
  final stats = lastGameResult ?? GameResult.fromCounter(clicksCounter);
  final wrongTaps = stats.wrongTaps;
  return Dialog(
    backgroundColor: Colors.transparent,
    child: Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1F29), Color(0xFF3B1D60)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 30,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.celebration, color: Colors.amber, size: 48),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.game_over,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _StatResultTile(
            icon: Icons.pest_control,
            label: AppLocalizations.of(context)!.bugtap_count,
            value: stats.bugTaps,
            color: Colors.pinkAccent,
          ),
          _StatResultTile(
            icon: Icons.pets,
            label: AppLocalizations.of(context)!.micetap_count,
            value: stats.miceTaps,
            color: Colors.lightBlueAccent,
          ),
          _StatResultTile(
            icon: Icons.cancel_outlined,
            label: AppLocalizations.of(context)!.wrongtap_count,
            value: wrongTaps,
            color: Colors.orangeAccent,
          ),
          const SizedBox(height: 28),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 14,
            runSpacing: 12,
            children: [
              _DialogActionButton(
                color: PawPalette.bubbleGum,
                icon: Icons.refresh,
                label: AppLocalizations.of(context)!.tryagain_button,
                onPressed: () async {
                  await closeGame(
                    _game!,
                    context,
                    adress: '/game_screen',
                    arguments: ArgumentSender(
                      title: "",
                      dataBase: _gameDatabase,
                    ),
                  );
                },
              ),
              _DialogActionButton(
                color: Colors.white,
                foregroundColor: PawPalette.midnight,
                icon: Icons.home,
                label: AppLocalizations.of(context)!.return_mainmenu_button,
                onPressed: () async =>
                    await closeGame(_game!, context, adress: '/main_screen'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

//* Game Ended, After This Function Triggers
Future<void> closeGame(
  FlameGame<World> game,
  BuildContext context, {
  String? adress,
  ArgumentSender? arguments,
}) async {
  lastGameResult ??= GameResult.fromCounter(clicksCounter);
  await FlameAudio.bgm.stop();
  game.pauseEngine();
  clicksCounter.reset();
  elapsedTicks = 0;
  elapsedTicksNotifier.value = 0;
  isOverlayBlocking = false;
  isGameOverTriggered = false;

  if (adress != null) {
    if (arguments == null) {
      Navigator.pushNamedAndRemoveUntil(context, adress, (route) => false);
      return;
    } else {
      Navigator.pushNamedAndRemoveUntil(
        context,
        adress,
        (route) => false,
        arguments: arguments,
      );
    }
  }
  isBackButtonClicked = false;
}

//* Alert for BackButtonClicked
Dialog backButtonDialog(FlameGame<World> game, BuildContext context) {
  isBackButtonDialogOpen = true;
  isOverlayBlocking = true;
  _game?.pauseEngine();
  return Dialog(
    backgroundColor: Colors.transparent,
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
                    _game?.resumeEngine();
                    Navigator.pop(context);
                  },
                  child: Text(AppLocalizations.of(context)!.i_am_cat),
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
                      builder: (context) => endGameDialog(context),
                    );
                  },
                  child: Text(AppLocalizations.of(context)!.i_am_human),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

//* Function to close the dialog
void closeDialogAutomatically(BuildContext context) {
  if (isBackButtonDialogOpen && context.mounted == true) Navigator.pop(context);
  isBackButtonDialogOpen = false;
  if (!isOverlayBlocking) return;
  isOverlayBlocking = false;
  _game?.resumeEngine();
}

PreferredSizeWidget gameAppBar(BuildContext context) {
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
            () => closeDialogAutomatically(context),
          );
          return backButtonDialog(_game!, context);
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
  @override
  void initState() {
    super.initState();
    isOverlayBlocking = false;
    isGameOverTriggered = false;
    isBackButtonDialogOpen = false;
    isBackButtonClicked = false;
    lastGameResult = null;
    elapsedTicks = 0;
    elapsedTicksNotifier.value = 0;
    _game = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      clicksCounter.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as ArgumentSender;
    return Scaffold(
      appBar: gameAppBar(context),
      body: Stack(
        children: [
          Positioned.fill(
            child: GameWidget(
              game: Game(args.dataBase, context),
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
                child: Container(
                  color: Colors.black54,
                ),
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: const LinearGradient(
              colors: [Color(0xFF1F1C2C), Color(0xFF928DAB)],
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 20,
                offset: Offset(0, 12),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StatChip(
                    icon: Icons.pets,
                    label: l10n.micetap_count,
                    value: clicksCounter.miceTaps,
                    color: Colors.lightBlueAccent,
                  ),
                  _StatChip(
                    icon: Icons.bug_report,
                    label: l10n.bugtap_count,
                    value: clicksCounter.bugTaps,
                    color: Colors.pinkAccent,
                  ),
                  _StatChip(
                    icon: Icons.touch_app,
                    label: l10n.wrongtap_count,
                    value: wrongTaps,
                    color: Colors.orangeAccent,
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
  Game(this.gameDataBase, this.context);

  BuildContext context;
  OPCDataBase? gameDataBase;
  final Random _random = Random();

  late Timer interval; // Time Variable
  late DifficultyProfile _difficultyProfile;

  @override
  bool get debugMode => false;

  DifficultyProfile _resolveDifficultyProfile() {
    final difficulty = getDifficultyFromValue(gameDataBase?.difficulty);
    switch (difficulty) {
      case Difficulty.easy:
        return const DifficultyProfile(
          spawnIntervalSeconds: 5,
          maxActiveCreatures: 8,
          baseSpeed: 55,
          speedRamp: 0.2,
        );
      case Difficulty.medium:
        return const DifficultyProfile(
          spawnIntervalSeconds: 4,
          maxActiveCreatures: 12,
          baseSpeed: 70,
          speedRamp: 0.35,
        );
      case Difficulty.hard:
        return const DifficultyProfile(
          spawnIntervalSeconds: 3,
          maxActiveCreatures: 18,
          baseSpeed: 85,
          speedRamp: 0.5,
        );
      case Difficulty.sandbox:
        return const DifficultyProfile(
          spawnIntervalSeconds: 4,
          maxActiveCreatures: 24,
          baseSpeed: 70,
          speedRamp: 0.1,
        );
    }
  }

  @override
  Future<void> onLoad() async {
    _difficultyProfile = _resolveDifficultyProfile();
    try {
      await loadGameAudio();
      await loadGameImagesAndAssets();
      _game = this;
      _gameDatabase = gameDataBase;
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
    FlameAudio.bgm.play(
      'bird_background_sound.mp3',
      volume: gameDataBase?.musicVolume ?? 1,
    );

    interval = Timer(
      1.0,
      onTick: () async {
        if (isOverlayBlocking || isGameOverTriggered) return;
        if (_shouldSpawnThisTick(elapsedTicks)) {
          final activeCreatures = children.where((component) => component is Mice || component is Bug).length;
          if (activeCreatures < _difficultyProfile.maxActiveCreatures) {
            final startingSpeed = _currentSpeed(elapsedTicks);
            final startPosition = Vector2(
              0,
              gameScreenTopBarHeight + _random.nextDouble() * (size.y - gameScreenTopBarHeight),
            );
            final startRndVelocity = Utils.generateRandomVelocity(size, 10, 100);
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

  Future<void> _handleGameOver() async {
    if (isGameOverTriggered) return;
    isGameOverTriggered = true;
    isOverlayBlocking = true;
    lastGameResult = GameResult.fromCounter(clicksCounter);
    pauseEngine();
    await FlameAudio.bgm.stop();
    showDialog(
      context: context,
      builder: (context) => endGameDialog(context),
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
          volume: gameDataBase?.characterVolume ?? 1,
        );
        clicksCounter.recordMiceTap();
        remove(component);
        hitAnything = true;
        return true;
      } else if (component is Bug && component.containsPoint(touchPoint)) {
        FlameAudio.play(
          'bug_tap.wav',
          volume: gameDataBase?.characterVolume ?? 1,
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
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 6),
        Text(
          '$value',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
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
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label, style: const TextStyle(color: Colors.white70)),
            ),
            Text(
              '$value',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
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
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 160),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: foregroundColor,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label, textAlign: TextAlign.center),
      ),
    );
  }
}

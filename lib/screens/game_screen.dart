// ignore_for_file: must_be_immutable, use_build_context_synchronously
import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:game_for_cats_flutter/classes/game_classes.dart';
import 'package:game_for_cats_flutter/database/opc_database_list.dart';
import 'package:game_for_cats_flutter/functions/loading_screen_function.dart';
import 'package:game_for_cats_flutter/global/argumentsender_class.dart';
import 'package:game_for_cats_flutter/global/global_variables.dart';
import 'package:game_for_cats_flutter/objects/bug.dart';
import 'package:game_for_cats_flutter/objects/mice.dart';
import 'package:game_for_cats_flutter/global/global_images.dart';
import 'package:game_for_cats_flutter/utils/utils.dart';
import 'package:game_for_cats_flutter/l10n/app_localizations.dart';
import '../functions/game_functions.dart';

bool isBackButtonClicked = false;
int elapsedTicks = 0; // Seconds
ValueNotifier<int> elapsedTicksNotifier = ValueNotifier<int>(0);
bool isBackButtonDialogOpen = false;
FlameGame<World>? _game;
GameClicksCounter clicksCounter = GameClicksCounter();
OPCDataBase? _gameDatabase;
bool isPaused = false; // Is Game Stopped

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

//* Alert for End Game
AlertDialog endGameDialog(BuildContext context) {
  int wrongTaps = clicksCounter.totalTaps - (clicksCounter.bugTaps + clicksCounter.miceTaps);
  return AlertDialog(
      title: Text(AppLocalizations.of(context)!.game_over),
      content: Container(
        height: 100,
        decoration: BoxDecoration(border: Border.all(), color: const Color.fromARGB(179, 210, 210, 210), borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            Text("${AppLocalizations.of(context)!.bugtap_count} ${clicksCounter.bugTaps}"),
            const Spacer(flex: 1),
            Text("${AppLocalizations.of(context)!.micetap_count} ${clicksCounter.miceTaps}"),
            const Spacer(flex: 1),
            Text("${AppLocalizations.of(context)!.wrongtap_count} $wrongTaps"),
            const Spacer(flex: 3),
          ],
        ),
      ),
      actions: [
        //* Restart
        ElevatedButton(
          onPressed: () async {
            await closeGame(_game!, context, adress: '/game_screen', arguments: ArgumentSender(title: "", dataBase: _gameDatabase));
            //* Restarting Game Parameters
            isPaused = false;
            clicksCounter.reset();
            elapsedTicks = 0;
          },
          child: Text(AppLocalizations.of(context)!.tryagain_button),
        ),
        //* Return to Main Menu
        ElevatedButton(
          onPressed: () async => await closeGame(_game!, context, adress: '/main_screen'),
          child: Text(AppLocalizations.of(context)!.return_mainmenu_button),
        ),
      ]);
}

//* Game Ended, After This Function Triggers
Future<void> closeGame(FlameGame<World> game, BuildContext context, {String? adress, ArgumentSender? arguments}) async {
  await FlameAudio.bgm.stop();
  game.pauseEngine();

  if (adress != null) {
    if (arguments == null) {
      Navigator.pushNamedAndRemoveUntil(context, adress, (route) => false);
      return;
    } else {
      Navigator.pushNamedAndRemoveUntil(context, adress, (route) => false, arguments: arguments);
    }
  }
  isPaused = true; // Oyunu durdur
  isBackButtonClicked = false;
}

//* Alert for BackButtonClicked
AlertDialog backButtonDialog(FlameGame<World> game, BuildContext context) {
  isBackButtonDialogOpen = true;
  return AlertDialog(
    elevation: 10,
    title: Text(AppLocalizations.of(context)!.exit_validation),
    content: Container(
      height: 100,
      decoration: BoxDecoration(border: Border.all(), color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Text(AppLocalizations.of(context)!.this_will_close_automatically_in_seconds),
          const Spacer(flex: 1),
        ],
      ),
    ),
    actions: [
      //* I am Cat Option
      ElevatedButton(
          onPressed: () {
            isBackButtonDialogOpen = false;
            Navigator.pop(context);
          },
          child: Text(AppLocalizations.of(context)!.i_am_cat)),
      //* I am Human Option
      ElevatedButton(
        onPressed: () async {
          isBackButtonDialogOpen = false;
          Navigator.pop(context);
          await closeGame(game, context);
          showDialog(context: context, builder: (context) => endGameDialog(context));
        },
        child: Text(AppLocalizations.of(context)!.i_am_human),
      ),
    ],
  );
}

//* Function to close the dialog
void closeDialogAutomatically(BuildContext context) {
  if (isBackButtonDialogOpen && context.mounted == true) Navigator.pop(context);
  isBackButtonDialogOpen = false;
}

AppBar gameAppBar(BuildContext context) {
  return AppBar(
    leading: BackButton(
      onPressed: () => showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            isBackButtonClicked = true;
            Future.delayed(const Duration(seconds: 2), () => closeDialogAutomatically(context));
            return backButtonDialog(_game!, context);
          }),
    ),
    title: ValueListenableBuilder<int>(
      valueListenable: elapsedTicksNotifier,
      builder: (context, elapsedTicks, _) {
        int remainingTime = gameTimer - elapsedTicks;
        String remainingTimeString = AppLocalizations.of(context)!.countdown;
        return Text(
          remainingTime > 0 ? remainingTimeString + remainingTime.toString() : AppLocalizations.of(context)!.game_over,
          style: const TextStyle(color: Colors.white),
        );
      },
    ),
  );
}

class _GameScreenState extends State<GameScreen> {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as ArgumentSender;
    return Scaffold(
      appBar: gameAppBar(context),
      body: GameWidget(game: Game(args.dataBase, context), loadingBuilder: (p0) => loadingScreen(context)),
    );
  }
}

class Game extends FlameGame with TapDetector, HasGameRef, HasCollisionDetection {
  Game(this.gameDataBase, this.context);

  BuildContext context;
  OPCDataBase? gameDataBase;

  late Timer interval; // Time Variable

  @override
  bool get debugMode => false;

  @override
  Future<void> onLoad() async {
    try {
      await loadGameAudio();
      await loadGameImagesAndAssets();
      _game = game;
      _gameDatabase = gameDataBase;
    } catch (e) {
      showDialog(context: context, builder: (context) => AlertDialog(title: Text("${AppLocalizations.of(context)!.error} \n $e"), content: Text(e.toString())));
    }
    //Add Collision
    add(ScreenHitbox());
    if (!isPaused) FlameAudio.bgm.play('bird_background_sound.mp3', volume: gameDataBase?.musicVolume ?? 1);

    interval = Timer(
      1.0,
      onTick: () async {
        if (isPaused) return; // Game Paused
        if (elapsedTicks % 4 == 0) {
          double startingSpeed = 50;
          //Adding Mice or Bug Every 4 Seconds
          int randomValue = Random().nextInt(2); // 0 or 1
          Vector2 startPosition = Vector2(0, gameScreenTopBarHeight + Random().nextDouble() * (size.y - gameScreenTopBarHeight));
          Vector2 startRndVelocity = Utils.generateRandomVelocity(size, 10, 100);
          if (randomValue == 0) {
            Mice mice = Mice(startPosition, startRndVelocity, startingSpeed);
            add(mice);
          } else {
            Bug bug = Bug(startPosition, startRndVelocity, startingSpeed);
            add(bug);
          }
        }
        if (elapsedTicks == gameTimer) {
          //End Game
          await closeGame(game, context);
          showDialog(context: context, builder: (context) => endGameDialog(context));
        }
        elapsedTicks++;
        elapsedTicksNotifier.value = elapsedTicks; // Update the ValueNotifier
      },
      repeat: true,
    );
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (isPaused) return; // If Game Stopped, No More Updates!
    super.update(dt);
    interval.update(dt);
  }

  @override
  void onTapDown(TapDownInfo info) {
    super.onTapDown(info);
    final touchPoint = info.eventPosition.widget;
    children.any((component) {
      if (component is Mice && component.containsPoint(touchPoint)) {
        //? Mice Tap
        FlameAudio.play('mice_tap.mp3', volume: gameDataBase?.characterVolume ?? 1);
        clicksCounter.miceTaps++;
        remove(component);
        return true;
      } else if (component is Bug && component.containsPoint(touchPoint)) {
        //? Bug Tap
        FlameAudio.play('bug_tap.wav', volume: gameDataBase?.characterVolume ?? 1);
        clicksCounter.bugTaps++;
        remove(component);
        return true;
      }
      return false;
    });
    clicksCounter.totalTaps++;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawImageRect(globalBackgroundImage, const Rect.fromLTWH(0, 0, 1024, 1024), Rect.fromLTWH(0, 0, size.x, size.y), Paint());
    super.render(canvas);
  }
}

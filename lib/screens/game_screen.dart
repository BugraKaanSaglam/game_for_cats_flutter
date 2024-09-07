// ignore_for_file: must_be_immutable, use_build_context_synchronously
import 'dart:async';
import 'dart:math';
import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:game_for_cats_flutter/database/opc_database_list.dart';
import 'package:game_for_cats_flutter/functions/loading_screen_function.dart';
import 'package:game_for_cats_flutter/global/argumentsender_class.dart';
import 'package:game_for_cats_flutter/global/global_variables.dart';
import 'package:game_for_cats_flutter/main.dart';
import 'package:game_for_cats_flutter/objects/bug.dart';
import 'package:game_for_cats_flutter/objects/mice.dart';
import 'package:game_for_cats_flutter/global/global_images.dart';
import 'package:game_for_cats_flutter/utils/utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

bool isBackButtonClicked = false;
bool isGameClosing = false;

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as ArgumentSender;
    return GameWidget(game: Game(args.dataBase, context), loadingBuilder: (p0) => loadingScreen(context));
  }
}

class Game extends FlameGame with TapDetector, HasGameRef, HasCollisionDetection {
  Game(this.gameDataBase, this.context);

  BuildContext context;
  OPCDataBase? gameDataBase;

  late ButtonComponent backButton;
  bool isBackButtonDialogOpen = false;

  late Timer interval; // Time Variable
  int elapsedTicks = 0; // Seconds
  //* Clicks
  int totalTaps = 0;
  int miceTaps = 0;
  int bugTaps = 0;
  //* Inside of Bar Parameters
  double barParametersHeight = 13;
  @override
  bool get debugMode => false;

  @override
  Future<void> onLoad() async {
    try {
      //Loading Audio
      await FlameAudio.audioCache.load('mice_tap.mp3');
      await FlameAudio.audioCache.load('bug_tap.wav');

      await FlameAudio.audioCache.load('bird_background_sound.mp3');
      //Loading Images
      await Images().load('mice_sprite.png').then((value) => globalMiceImage = value);
      await Images().load('bug_sprite.png').then((value) => globalBugImage = value);

      await Images().load('background.webp').then((value) => globalBackgroundImage = value);
      await Images().load('back_button.png').then((value) => globalBackButtonImage = value);
    } catch (e) {
      showDialog(context: context, builder: (context) => AlertDialog(title: Text(AppLocalizations.of(context)!.error), content: Text(e.toString())));
    }
    //Add Button
    backButton = ButtonComponent(
        button: PositionComponent(position: Vector2(20, 20), size: Vector2(40, 40)),
        position: Vector2(10, barParametersHeight),
        children: [SpriteComponent.fromImage(globalBackButtonImage)],
        onPressed: () => showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              isBackButtonClicked = true;
              Future.delayed(const Duration(seconds: 2), () => closeDialogAutomatically());
              return backButtonDialog();
            }));

    add(backButton);

    //Add Collision
    add(ScreenHitbox());
    if (!isGameClosing) {
      FlameAudio.bgm.play('bird_background_sound.mp3', volume: gameDataBase?.musicVolume ?? 1);
    }

    interval = Timer(
      1.0,
      onTick: () async {
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
          await closeGame();
          showDialog(context: context, builder: (context) => endGameDialog());
        }
        elapsedTicks++;
      },
      repeat: true,
    );
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    interval.update(dt);
  }

  @override
  void onTapDown(TapDownInfo info) {
    super.onTapDown(info);
    final touchPoint = info.eventPosition.global;
    children.any((component) {
      //? Mice Tap
      if (component is Mice && component.containsPoint(touchPoint)) {
        FlameAudio.play('mice_tap.mp3', volume: gameDataBase?.characterVolume ?? 1);
        miceTaps++;
        remove(component);
        return true;
      }
      //? Bug Tap
      if (component is Bug && component.containsPoint(touchPoint)) {
        FlameAudio.play('bug_tap.wav', volume: gameDataBase?.characterVolume ?? 1);
        bugTaps++;
        remove(component);
        return true;
      }
      return false;
    });
    totalTaps++;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawImageRect(globalBackgroundImage, const Rect.fromLTWH(0, 0, 1024, 1024), Rect.fromLTWH(0, 0, size.x, size.y), Paint());
    canvas.drawRect(
        Vector2(gameRef.size.x, gameScreenTopBarHeight).toRect(), Paint()..color = MainAppState().gameTheme.appBarTheme.backgroundColor ?? Colors.deepOrange); //TopBar
    drawCountdown(canvas);
    super.render(canvas);
  }

  //* CountDown Text
  void drawCountdown(Canvas canvas) {
    const textStyle = TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold);
    late final TextPainter textPainter;
    if (gameTimer - elapsedTicks > 0) {
      textPainter = TextPainter(
        text: TextSpan(text: '${AppLocalizations.of(context)!.countdown}: ${gameTimer - elapsedTicks}', style: textStyle),
        textDirection: TextDirection.ltr,
      );
    } else {
      textPainter = TextPainter(text: TextSpan(text: AppLocalizations.of(context)!.game_over, style: textStyle), textDirection: TextDirection.ltr);
    }
    textPainter.layout();
    // Position the countdown text in the center of the top bar
    final textPosition = Offset((size.x - textPainter.width) / 2, barParametersHeight);
    // Draw the countdown text on the canvas
    textPainter.paint(canvas, textPosition);
  }

  //* Alert for End Game
  AlertDialog endGameDialog() {
    int wrongTaps = totalTaps - (bugTaps + miceTaps);
    return AlertDialog(
        title: Text(AppLocalizations.of(context)!.game_over),
        content: Container(
          height: 100,
          decoration: BoxDecoration(border: Border.all(), color: Colors.white70, borderRadius: BorderRadius.circular(20)),
          child: Column(
            children: [
              Text("${AppLocalizations.of(context)!.bugtap_count} $bugTaps"),
              const Spacer(flex: 1),
              Text("${AppLocalizations.of(context)!.micetap_count} $miceTaps"),
              const Spacer(flex: 1),
              Text("${AppLocalizations.of(context)!.wrongtap_count} $wrongTaps"),
              const Spacer(flex: 3),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async => await closeGame(adress: '/game_screen', arguments: ArgumentSender(title: "", dataBase: gameDataBase)),
            child: Text(AppLocalizations.of(context)!.tryagain_button),
          ),
          ElevatedButton(
            onPressed: () async => await closeGame(adress: '/main_screen'),
            child: Text(AppLocalizations.of(context)!.return_mainmenu_button),
          ),
        ]);
  }

  //* Alert for BackButtonClicked
  AlertDialog backButtonDialog() {
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
        ElevatedButton(
            onPressed: () {
              isBackButtonDialogOpen = false;
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.i_am_cat)),
        ElevatedButton(
          onPressed: () async {
            isBackButtonDialogOpen = false;
            Navigator.pop(context);
            await closeGame();
            showDialog(context: context, builder: (context) => endGameDialog());
          },
          child: Text(AppLocalizations.of(context)!.i_am_human),
        ),
      ],
    );
  }

  //* Function to close the dialog
  void closeDialogAutomatically() {
    if (isBackButtonDialogOpen && context.mounted == true) {
      Navigator.pop(context);
    }
    isBackButtonDialogOpen = false;
  }

  //* Game Ended, After This Function Triggers
  Future<void> closeGame({String? adress, ArgumentSender? arguments}) async {
    game.pauseEngine();
    await FlameAudio.bgm.stop();

    if (adress != null) {
      if (arguments == null) {
        Navigator.pushNamedAndRemoveUntil(context, adress, (route) => false);
        return;
      } else {
        Navigator.pushNamedAndRemoveUntil(context, adress, (route) => false, arguments: arguments);
      }
    }
    isGameClosing = true;
    isBackButtonClicked = false;
  }
}

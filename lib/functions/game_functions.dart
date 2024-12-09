import 'package:flame/cache.dart';
import 'package:flame_audio/flame_audio.dart';
import '../global/global_images.dart';

Future<void> loadGameAudio() async {
  await FlameAudio.audioCache.load('mice_tap.mp3');
  await FlameAudio.audioCache.load('bug_tap.wav');
  await FlameAudio.audioCache.load('bird_background_sound.mp3');
}

Future<void> loadGameImagesAndAssets() async {
  await Images().load('mice_sprite.png').then((value) => globalMiceImage = value);
  await Images().load('bug_sprite.png').then((value) => globalBugImage = value);

  await Images().load('background.webp').then((value) => globalBackgroundImage = value);
  await Images().load('back_button.png').then((value) => globalBackButtonImage = value);
}

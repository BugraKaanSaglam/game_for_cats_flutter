import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flame/cache.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:game_for_cats_2025/models/global/global_images.dart';

Future<void> loadGameAudio() async {
  await FlameAudio.audioCache.load('mice_tap.mp3');
  await FlameAudio.audioCache.load('bug_tap.wav');
  await FlameAudio.audioCache.load('bird_background_sound.mp3');
}

Future<void> loadGameImagesAndAssets({String? backgroundPath}) async {
  await Images().load('mice_sprite.png').then((value) => globalMiceImage = value);
  await Images().load('bug_sprite.png').then((value) => globalBugImage = value);

  globalBackgroundImage = await _loadBackgroundImage(backgroundPath);
  await Images().load('back_button.png').then((value) => globalBackButtonImage = value);
}

Future<Image> _loadBackgroundImage(String? path) async {
  try {
    if (path != null && path.isNotEmpty) {
      final file = File(path);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        final completer = Completer<Image>();
        decodeImageFromList(bytes, (image) => completer.complete(image));
        return completer.future;
      }
    }
  } catch (_) {
    // Fall back to bundled image below.
  }

  return Images().load('background.webp');
}

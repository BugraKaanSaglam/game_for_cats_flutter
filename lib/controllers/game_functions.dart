import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flame/cache.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:game_for_cats_2025/models/global/global_images.dart';

final Images _gameImages = Images();
bool _audioLoaded = false;
bool _coreImagesLoaded = false;
bool _backgroundLoaded = false;
String? _backgroundPath;

Future<void> loadGameAudio() async {
  if (_audioLoaded) return;
  await FlameAudio.audioCache.loadAll([
    'mice_tap.mp3',
    'bug_tap.wav',
    'bird_background_sound.mp3',
  ]);
  _audioLoaded = true;
}

Future<void> loadGameImagesAndAssets({String? backgroundPath}) async {
  if (!_coreImagesLoaded) {
    globalMiceImage = await _gameImages.load('mice_sprite.png');
    globalBugImage = await _gameImages.load('bug_sprite.png');
    globalBackButtonImage = await _gameImages.load('back_button.png');
    _coreImagesLoaded = true;
  }

  final normalizedPath = (backgroundPath != null && backgroundPath.isNotEmpty)
      ? backgroundPath
      : null;
  if (!_backgroundLoaded || _backgroundPath != normalizedPath) {
    final newBackground = await _loadBackgroundImage(normalizedPath);
    if (_backgroundLoaded) {
      globalBackgroundImage.dispose();
    }
    globalBackgroundImage = newBackground;
    _backgroundLoaded = true;
    _backgroundPath = normalizedPath;
  }
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

  return _gameImages.load('background.webp');
}

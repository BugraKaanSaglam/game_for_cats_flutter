import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flame/cache.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:game_for_cats_2025/models/global/global_images.dart';

//* Shared asset-loading entry points used by the Flame game.
//! This layer keeps expensive audio/image decoding out of individual components.
final Images _gameImages = Images();
bool _audioLoaded = false;
bool _coreImagesLoaded = false;
bool _backgroundLoaded = false;
String? _backgroundPath;

Future<void> loadGameAudio() async {
  //? Audio is cached once because every round reuses the same clips.
  if (_audioLoaded) return;
  await FlameAudio.audioCache.loadAll([
    'mice_tap.mp3',
    'bug_tap.wav',
    'bird_background_sound.mp3',
  ]);
  _audioLoaded = true;
}

Future<void> loadGameImagesAndAssets({String? backgroundPath}) async {
  //* Core creature sprites are stable across rounds; only the optional background can vary.
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
    //! Backgrounds can be replaced at runtime from Settings, so old images are disposed on swap.
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
    //? User-selected play mats are preferred when the file still exists locally.
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

  //* Safe fallback for first run or missing custom files.
  return _gameImages.load('background.webp');
}

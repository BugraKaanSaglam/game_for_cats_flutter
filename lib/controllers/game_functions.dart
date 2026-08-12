import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flame/cache.dart';
import 'package:flame_audio/flame_audio.dart';

class GameAssets {
  const GameAssets({
    required this.mice,
    required this.bug,
    required this.background,
  });

  final Image mice;
  final Image bug;
  final Image background;
}

//* Shared asset-loading entry points used by the Flame game.
//! This layer keeps expensive audio/image decoding out of individual components.
final Images _gameImages = Images();
bool _audioLoaded = false;
String? _backgroundPath;
Image? _cachedMice;
Image? _cachedBug;

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

Future<GameAssets> loadGameImagesAndAssets({String? backgroundPath}) async {
  //* Core creature sprites are stable across rounds; only the optional background can vary.
  _cachedMice ??= await _gameImages.load('mice_sprite.png');
  _cachedBug ??= await _gameImages.load('bug_sprite.png');

  final normalizedPath = (backgroundPath != null && backgroundPath.isNotEmpty)
      ? backgroundPath
      : null;
  if (_backgroundPath != normalizedPath || _cachedBackground == null) {
    final newBackground = await _loadBackgroundImage(normalizedPath);
    _cachedBackground?.dispose();
    _cachedBackground = newBackground;
    _backgroundPath = normalizedPath;
  }
  return GameAssets(
    mice: _cachedMice!,
    bug: _cachedBug!,
    background: _cachedBackground!,
  );
}

Image? _cachedBackground;

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

// Load up the sprite sheet with an even step time framerate
import 'dart:ui';

import 'package:flame/sprite.dart';

SpriteAnimation animationHandler(Image imageWithFrames, int columns, int rows, {double stepTime = 0.1}) {
  final frames = columns * rows;
  final spritesheet = SpriteSheet.fromColumnsAndRows(image: imageWithFrames, columns: columns, rows: rows);
  final sprites = List<Sprite>.generate(frames, spritesheet.getSpriteById);
  return SpriteAnimation.spriteList(sprites, stepTime: stepTime);
}

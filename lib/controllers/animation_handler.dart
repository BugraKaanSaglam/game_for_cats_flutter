//* Converts a sprite sheet into a Flame SpriteAnimation with a consistent frame cadence.
import 'dart:ui';

import 'package:flame/sprite.dart';

SpriteAnimation animationHandler(
  Image imageWithFrames,
  int columns,
  int rows, {
  double stepTime = 0.1,
}) {
  //? The creature assets in this project are simple sheets, so columns/rows are enough.
  final frames = columns * rows;
  final spritesheet = SpriteSheet.fromColumnsAndRows(
    image: imageWithFrames,
    columns: columns,
    rows: rows,
  );
  final sprites = List<Sprite>.generate(frames, spritesheet.getSpriteById);
  return SpriteAnimation.spriteList(sprites, stepTime: stepTime);
}

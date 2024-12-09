import 'dart:math';
import 'package:flame/components.dart';
import 'package:game_for_cats_flutter/global/global_variables.dart';

class Utils {
  static Vector2 generateRandomPosition(Vector2 screenSize, Vector2 margins) {
    var result = Vector2.zero();
    var randomGenerator = Random();
    result = Vector2(randomGenerator.nextInt(screenSize.x.toInt() - 2 * margins.x.toInt()).toDouble() + margins.x,
        randomGenerator.nextInt(screenSize.y.toInt() + gameScreenTopBarHeight.toInt() - 2 * margins.y.toInt()).toDouble() + margins.y);
    result.add(Vector2(0, gameScreenTopBarHeight));
    return result;
  }

  static Vector2 generateRandomVelocity(Vector2 screenSize, int min, int max) {
    var result = Vector2.zero();
    var randomGenerator = Random();
    double velocity;

    while (result == Vector2.zero()) {
      result = Vector2((randomGenerator.nextInt(3) - 1) * randomGenerator.nextDouble(), (randomGenerator.nextInt(3) - 1) * randomGenerator.nextDouble());
    }
    result.normalize();
    velocity = (randomGenerator.nextInt(max - min) + min).toDouble();

    return result * velocity;
  }

  static bool isPositionOutOfBounds(Vector2 bounds, Vector2 position) {
    bool result = false;

    if (position.x > bounds.x || position.x < 0 || position.y < gameScreenTopBarHeight || position.y > bounds.y) {
      result = true;
    }

    return result;
  }

  static Vector2 wrapPosition(Vector2 bounds, Vector2 position) {
    Vector2 result = position;

    if (position.x >= bounds.x) {
      result.x = gameScreenTopBarHeight;
    } else if (position.x <= gameScreenTopBarHeight) {
      result.x = bounds.x;
    }

    if (position.y >= bounds.y) {
      result.y = 0;
    } else if (position.y <= 0) {
      result.y = bounds.y;
    }

    return result;
  }

  static Vector2 generateRandomDirection() {
    var result = Vector2.zero();
    var randomGenerator = Random();

    while (result == Vector2.zero()) {
      result = Vector2((randomGenerator.nextInt(3) - 1), (randomGenerator.nextInt(3) - 1));
    }
    return result;
  }

  static double generateRandomSpeed(int min, int max) {
    var randomGenerator = Random();
    double speed;

    speed = (randomGenerator.nextInt(max - min) + min).toDouble();
    return speed;
  }
}

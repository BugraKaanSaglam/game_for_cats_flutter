import 'dart:math';

import 'package:flame/components.dart';

// * Small math helpers for movement, spawning, and wrap-around behavior.
class Utils {
  static Vector2 generateRandomPosition(
    Vector2 screenSize,
    Vector2 margins, {
    double topInset = 0,
  }) {
    final randomGenerator = Random();
    // ! topInset reserves space for the Flutter HUD overlay above the Flame field.
    final horizontalSpan = max(screenSize.x.toInt() - 2 * margins.x.toInt(), 1);
    final verticalSpan = max(
      screenSize.y.toInt() - topInset.toInt() - 2 * margins.y.toInt(),
      1,
    );
    return Vector2(
      randomGenerator.nextInt(horizontalSpan).toDouble() + margins.x,
      randomGenerator.nextInt(verticalSpan).toDouble() + margins.y + topInset,
    );
  }

  static Vector2 generateRandomVelocity(Vector2 screenSize, int min, int max) {
    var result = Vector2.zero();
    final randomGenerator = Random();
    double velocity;

    // ? We reject the zero vector so creatures always move immediately after spawning.
    while (result == Vector2.zero()) {
      result = Vector2(
        (randomGenerator.nextInt(3) - 1) * randomGenerator.nextDouble(),
        (randomGenerator.nextInt(3) - 1) * randomGenerator.nextDouble(),
      );
    }
    result.normalize();
    velocity = (randomGenerator.nextInt(max - min) + min).toDouble();

    return result * velocity;
  }

  static bool isPositionOutOfBounds(
    Vector2 bounds,
    Vector2 position, {
    double topInset = 0,
  }) {
    var result = false;

    if (position.x > bounds.x ||
        position.x < 0 ||
        position.y < topInset ||
        position.y > bounds.y) {
      result = true;
    }

    return result;
  }

  static Vector2 wrapPosition(
    Vector2 bounds,
    Vector2 position, {
    double topInset = 0,
  }) {
    var result = position;

    // ! Wrap-around keeps motion continuous instead of bouncing, which reads better for cats.
    if (position.x >= bounds.x) {
      result.x = 0;
    } else if (position.x <= 0) {
      result.x = bounds.x;
    }

    if (position.y >= bounds.y) {
      result.y = topInset;
    } else if (position.y <= topInset) {
      result.y = bounds.y;
    }

    return result;
  }

  static Vector2 generateRandomDirection() {
    var result = Vector2.zero();
    final randomGenerator = Random();

    while (result == Vector2.zero()) {
      result = Vector2(
        (randomGenerator.nextInt(3) - 1),
        (randomGenerator.nextInt(3) - 1),
      );
    }
    return result;
  }

  static double generateRandomSpeed(int min, int max) {
    final randomGenerator = Random();
    double speed;

    speed = (randomGenerator.nextInt(max - min) + min).toDouble();
    return speed;
  }
}

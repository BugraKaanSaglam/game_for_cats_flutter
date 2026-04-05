// ignore_for_file: deprecated_member_use

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:game_for_cats_2025/controllers/animation_handler.dart';
import 'package:game_for_cats_2025/models/global/global_images.dart';
import 'package:game_for_cats_2025/models/global/global_variables.dart';
import 'package:game_for_cats_2025/controllers/utils.dart';

//* Bug target entity.
//? It mirrors the mouse movement model, but uses a different sheet and slightly different size / cadence.
class Bug extends SpriteAnimationComponent
    with HasGameRef<FlameGame>, CollisionCallbacks {
  late Vector2 _velocity;
  late final double _speed;
  bool _isColliding = false;
  DateTime? _lastCollisionTime;

  double acceleration = 2000.0;
  double friction = 0.1;
  double steeringFactor = 0.01;
  Vector2 target = Vector2.zero();

  Bug(Vector2 position, Vector2 velocity, double speed)
    : _velocity = velocity,
      _speed = speed,
      super(
        animation: animationHandler(globalBugImage, 3, 1, stepTime: 0.08),
        position: position,
        size: Vector2(60, 60),
        anchor: Anchor.center,
      ) {
    add(RectangleHitbox());
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _velocity = (_velocity)..scaleTo(_speed);
    angle = _velocity.screenAngle();
    target = Utils.generateRandomPosition(gameRef.size, Vector2(0, 10));
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    final currentTime = DateTime.now();
    if (!_isColliding ||
        _lastCollisionTime == null ||
        currentTime.difference(_lastCollisionTime!) >=
            Duration(milliseconds: waitTimeForCollisions)) {
      _isColliding = true;
      _lastCollisionTime = currentTime;
      target = Utils.generateRandomPosition(gameRef.size, Vector2(0, 10));

      //? Cooldown avoids unstable collision feedback loops.
      Future.delayed(Duration(milliseconds: waitTimeForCollisions), () {
        _isColliding = false;
      });
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    final directionToTarget = (target - position).normalized();

    final desiredVelocity = directionToTarget * acceleration;

    _velocity += (desiredVelocity - _velocity) * steeringFactor;

    _velocity *= (1.0 - friction);

    if (_velocity.length > _speed) {
      _velocity = _velocity.normalized()..scaleTo(_speed);
    }

    position += _velocity * dt;

    if ((target - position).length < 10.0) {
      target = Utils.generateRandomPosition(gameRef.size, Vector2(0, 10));
    }

    if (Utils.isPositionOutOfBounds(gameRef.size, position)) {
      position = Utils.wrapPosition(gameRef.size, position);
    }

    angle = _velocity.screenAngle();
  }
}

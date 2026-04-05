// ignore_for_file: deprecated_member_use

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:game_for_cats_2025/controllers/animation_handler.dart';
import 'package:game_for_cats_2025/models/global/global_images.dart';
import 'package:game_for_cats_2025/models/global/global_variables.dart';
import 'package:game_for_cats_2025/controllers/utils.dart';

//* Mouse target entity:
//* steers toward random targets, wraps at edges, and updates its facing angle from velocity.
class Mice extends SpriteAnimationComponent
    with HasGameRef<FlameGame>, CollisionCallbacks {
  late Vector2 _velocity;
  late final double _speed;
  bool _isColliding = false;
  DateTime? _lastCollisionTime;

  double acceleration = 2000.0;
  double friction = 0.1;
  double steeringFactor = 0.01;
  Vector2 target = Vector2.zero();

  Mice(Vector2 position, Vector2 velocity, double speed)
    : _velocity = velocity,
      _speed = speed,
      super(
        animation: animationHandler(globalMiceImage, 5, 1),
        position: position,
        size: Vector2(64, 64),
        anchor: Anchor.center,
      ) {
    //! Collision bounds are intentionally simple rectangles; precision is less important than responsiveness.
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

      //? The cooldown prevents endless jitter when components keep intersecting.
      Future.delayed(Duration(milliseconds: waitTimeForCollisions), () {
        _isColliding = false;
      });
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    //* Steering model:
    //* choose target -> accelerate toward it -> damp velocity -> clamp speed -> move.
    final directionToTarget = (target - position).normalized();

    final desiredVelocity = directionToTarget * acceleration;

    _velocity += (desiredVelocity - _velocity) * steeringFactor;

    _velocity *= (1.0 - friction);

    if (_velocity.length > _speed) {
      _velocity = _velocity.normalized()..scaleTo(_speed);
    }

    position += _velocity * dt;

    //? Reaching the current target simply picks a new roam point.
    if ((target - position).length < 10.0) {
      target = Utils.generateRandomPosition(gameRef.size, Vector2(0, 10));
    }

    if (Utils.isPositionOutOfBounds(gameRef.size, position)) {
      position = Utils.wrapPosition(gameRef.size, position);
    }

    angle = _velocity.screenAngle();
  }
}

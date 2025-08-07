// ignore_for_file: deprecated_member_use

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:game_for_cats_2025/functions/animation_handler.dart';
import 'package:game_for_cats_2025/global/global_images.dart';
import 'package:game_for_cats_2025/global/global_variables.dart';

import '../utils/utils.dart';

// Bug class is a PositionComponent so we get the angle and position of the element.
class Bug extends SpriteAnimationComponent with HasGameRef<FlameGame>, CollisionCallbacks {
  late Vector2 _velocity;
  late final double _speed;
  bool _isColliding = false;
  DateTime? _lastCollisionTime;

  double acceleration = 2000.0;
  double friction = 0.1;
  double steeringFactor = 0.01;
  Vector2 target = Vector2.zero();

  Bug(Vector2 position, Vector2 velocity, double speed) : _velocity = velocity, _speed = speed, super(animation: animationHandler(globalBugImage, 3, 1, stepTime: 0.08), position: position, size: Vector2(60, 60), anchor: Anchor.center) {
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
    if (!_isColliding || _lastCollisionTime == null || currentTime.difference(_lastCollisionTime!) >= Duration(milliseconds: waitTimeForCollisions)) {
      _isColliding = true;
      _lastCollisionTime = currentTime;
      target = Utils.generateRandomPosition(gameRef.size, Vector2(0, 10));

      // Reset _isColliding after a certain delay
      Future.delayed(Duration(milliseconds: waitTimeForCollisions), () {
        _isColliding = false;
      });
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    //Select Target Direction
    Vector2 directionToTarget = (target - position).normalized();

    //Add Acceleration
    Vector2 desiredVelocity = directionToTarget * acceleration;

    //Update Velocity
    _velocity += (desiredVelocity - _velocity) * steeringFactor;

    //Friction Added
    _velocity *= (1.0 - friction);

    //Max Speed Check
    if (_velocity.length > _speed) {
      _velocity = _velocity.normalized()..scaleTo(_speed);
    }

    //Update Position
    position += _velocity * dt;

    //New Target Added, When Bug Get the Current Target
    if ((target - position).length < 10.0) {
      target = Utils.generateRandomPosition(gameRef.size, Vector2(0, 10));
    }

    //Don't Let It Go OutOfBounds
    if (Utils.isPositionOutOfBounds(gameRef.size, position)) {
      position = Utils.wrapPosition(gameRef.size, position);
    }

    //Update Bug Angle
    angle = _velocity.screenAngle();
  }
}

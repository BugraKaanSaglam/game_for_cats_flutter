// ignore_for_file: deprecated_member_use

import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:game_for_cats_2025/controllers/animation_handler.dart';
import 'package:game_for_cats_2025/controllers/utils.dart';

const _collisionCooldown = Duration(milliseconds: 5000);

/// Animated mouse target that steers, wraps, and reacts to collisions.
class Mice extends SpriteAnimationComponent
    with HasGameRef<FlameGame>, CollisionCallbacks {
  late Vector2 _velocity;
  late final double _speed;
  final double topInset;
  final bool highContrast;
  final Paint _contrastOuter = Paint()
    ..color = const Color(0xFF182329)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 7;
  final Paint _contrastInner = Paint()
    ..color = const Color(0xFFFFFCF5)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;
  bool _isColliding = false;
  DateTime? _lastCollisionTime;

  double acceleration = 2000.0;
  double friction = 0.1;
  double steeringFactor = 0.01;
  Vector2 target = Vector2.zero();

  Mice(
    Vector2 position,
    Vector2 velocity,
    double speed,
    Image spriteSheet, {
    this.topInset = 0,
    double sizeScale = 1,
    this.highContrast = false,
  }) : _velocity = velocity,
       _speed = speed,
       super(
         animation: animationHandler(spriteSheet, 5, 1),
         position: position,
         size: Vector2.all(64 * sizeScale),
         anchor: Anchor.center,
       ) {
    // ! Collision bounds are intentionally simple rectangles; precision is less important than responsiveness.
    add(RectangleHitbox());
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _velocity = (_velocity)..scaleTo(_speed);
    angle = _velocity.screenAngle();
    target = Utils.generateRandomPosition(
      gameRef.size,
      Vector2(0, 10),
      topInset: topInset,
    );
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    final currentTime = DateTime.now();
    if (!_isColliding ||
        _lastCollisionTime == null ||
        currentTime.difference(_lastCollisionTime!) >= _collisionCooldown) {
      _isColliding = true;
      _lastCollisionTime = currentTime;
      target = Utils.generateRandomPosition(
        gameRef.size,
        Vector2(0, 10),
        topInset: topInset,
      );

      // ? The cooldown prevents endless jitter when components keep intersecting.
      Future.delayed(_collisionCooldown, () {
        _isColliding = false;
      });
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // * Steering model:
    // * choose target -> accelerate toward it -> damp velocity -> clamp speed -> move.
    final directionToTarget = (target - position).normalized();

    final desiredVelocity = directionToTarget * acceleration;

    _velocity += (desiredVelocity - _velocity) * steeringFactor;

    _velocity *= (1.0 - friction);

    if (_velocity.length > _speed) {
      _velocity = _velocity.normalized()..scaleTo(_speed);
    }

    position += _velocity * dt;

    // ? Reaching the current target simply picks a new roam point.
    if ((target - position).length < 10.0) {
      target = Utils.generateRandomPosition(
        gameRef.size,
        Vector2(0, 10),
        topInset: topInset,
      );
    }

    if (Utils.isPositionOutOfBounds(
      gameRef.size,
      position,
      topInset: topInset,
    )) {
      position = Utils.wrapPosition(gameRef.size, position, topInset: topInset);
    }

    angle = _velocity.screenAngle();
  }

  @override
  void render(Canvas canvas) {
    if (highContrast) {
      final center = Offset(size.x / 2, size.y / 2);
      final radius = size.x * 0.42;
      canvas.drawCircle(center, radius, _contrastOuter);
      canvas.drawCircle(center, radius, _contrastInner);
    }
    super.render(canvas);
  }
}

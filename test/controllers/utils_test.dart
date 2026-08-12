import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_for_cats_2025/controllers/utils.dart';

void main() {
  test('spawns targets inside the playable field below the HUD inset', () {
    final bounds = Vector2(400, 300);
    final margins = Vector2(10, 10);

    for (var i = 0; i < 20; i++) {
      final position = Utils.generateRandomPosition(
        bounds,
        margins,
        topInset: 88,
      );

      expect(position.x, inInclusiveRange(10, 389));
      expect(position.y, inInclusiveRange(98, 289));
    }
  });

  test('wraps horizontal and vertical movement within the playable field', () {
    expect(
      Utils.wrapPosition(Vector2(400, 300), Vector2(401, 300), topInset: 88),
      Vector2(0, 88),
    );
    expect(
      Utils.wrapPosition(Vector2(400, 300), Vector2(-1, 87), topInset: 88),
      Vector2(400, 300),
    );
  });
}

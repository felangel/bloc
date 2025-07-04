import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:movable_ball/models/ball.dart';

void main() {
  group('Ball', () {
    group('constructor', () {
      test('creates a Ball instance with correct properties', () {
        const ball = Ball(
          id: 1,
          position: 0.5,
          isMoving: true,
          color: Color(0xFF0000FF),
        );

        expect(ball.id, 1);
        expect(ball.position, 0.5);
        expect(ball.isMoving, true);
        expect(ball.color, const Color(0xFF0000FF));
      });
    });
    test('copyWith creates a new instance with updated properties', () {
      const ball = Ball(
        id: 1,
        position: 0.5,
        isMoving: true,
        color: Color(0xFF0000FF),
      );

      final updatedBall = ball.copyWith(
        id: 2,
        position: 0.75,
        isMoving: false,
        color: const Color(0xFFFF0000),
      );

      expect(updatedBall.id, 2);
      expect(updatedBall.position, 0.75);
      expect(updatedBall.isMoving, false);
      expect(updatedBall.color, const Color(0xFFFF0000));
    });
  });
}

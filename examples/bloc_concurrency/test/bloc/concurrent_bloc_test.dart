import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movable_ball/bloc/index.dart';

void main() {
  // ==========================================================================
  //  CONCURRENT BLOC TESTS
  // ==========================================================================
  group('ConcurrentBloc Tests', () {
    late ConcurrentBloc bloc;

    setUp(() {
      bloc = ConcurrentBloc();
    });

    tearDown(() {
      bloc.close();
    });

    test('should allow multiple balls to cross simultaneously', () async {
      // Send multiple balls quickly
      bloc
        ..add(SendBallEvent(1))
        ..add(SendBallEvent(2))
        ..add(SendBallEvent(3));

      // Wait a bit for processing
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // All balls should be on bridge
      expect(bloc.state.ballsOnBridge.length, 3);
      expect(bloc.state.ballsOnBridge.map((b) => b.id), [1, 2, 3]);

      // All balls should be green (concurrent color)
      expect(
        bloc.state.ballsOnBridge.every((b) => b.color == Colors.green),
        true,
      );
    });

    blocTest<ConcurrentBloc, BridgeState>(
      'should add ball with correct properties on SendBallEvent',
      build: () => bloc,
      act: (bloc) => bloc.add(SendBallEvent(1)),
      expect: () => [
        isA<BridgeState>()
            .having((state) => state.ballsOnBridge.length, 'balls count', 1)
            .having((state) => state.ballsOnBridge.first.id, 'ball id', 1)
            .having(
              (state) => state.ballsOnBridge.first.color,
              'ball color',
              Colors.green,
            )
            .having(
              (state) => state.ballsOnBridge.first.position,
              'ball position',
              0.0,
            )
            .having(
              (state) => state.logs.last,
              'last log',
              contains('Concurrent'),
            ),
      ],
    );

    test('concurrent behavior - multiple balls should not interfere', () async {
      // Send 5 balls in quick succession
      for (var i = 1; i <= 5; i++) {
        bloc.add(SendBallEvent(i));
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }

      await Future<void>.delayed(const Duration(milliseconds: 100));

      // All 5 balls should be on bridge
      expect(bloc.state.ballsOnBridge.length, 5);

      // Verify all ball IDs are present
      final ballIds = bloc.state.ballsOnBridge.map((b) => b.id).toList();
      expect(ballIds, [1, 2, 3, 4, 5]);
    });
  });
}

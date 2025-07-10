import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movable_ball/bloc/index.dart';

void main() {
  // ==========================================================================
  //  DROPPABLE BLOC TESTS
  // ==========================================================================
  group('DroppableBloc Tests', () {
    late DroppableBloc bloc;

    setUp(() {
      bloc = DroppableBloc();
    });

    tearDown(() {
      bloc.close();
    });

    blocTest<DroppableBloc, BridgeState>(
      'should add ball with orange color',
      build: () => bloc,
      act: (bloc) => bloc.add(SendBallEvent(1)),
      expect: () => [
        isA<BridgeState>()
            .having(
              (state) => state.logs.any((log) => log.contains('Droppable')),
              'logs contain Droppable',
              true,
            )
            .having(
              (state) => state.logs.any(
                (log) => log.contains('dropped while crossing'),
              ),
              'logs contain dropped while crossing',
              true,
            )
            .having(
              (state) => state.ballsOnBridge.first.position,
              'ball position',
              0.0,
            )
            .having(
              (state) => state.ballsOnBridge.first.color,
              'ball color',
              Colors.orange,
            ),
      ],
    );

    test('droppable behavior - should only allow one ball at a time', () async {
      // Send first ball
      bloc.add(SendBallEvent(1));
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Send second ball - should replace first
      bloc.add(SendBallEvent(2));
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Only one ball should be on bridge (the latest one)
      expect(bloc.state.ballsOnBridge.length, 1);
      expect(bloc.state.ballsOnBridge.first.id, 1);
    });
  });
}

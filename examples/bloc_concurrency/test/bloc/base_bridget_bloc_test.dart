import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movable_ball/bloc/index.dart';
import 'package:movable_ball/models/ball.dart';

void main() {
  group('Bridge BLoC Test Suite', () {
    // ==============================================================
    //  BASE BRIDGE BLOC TESTS
    // ==============================================================
    group('BaseBridgeBloc Tests', () {
      late BaseBridgeBloc bloc;

      setUp(() {
        // Use ConcurrentBloc as concrete implementation of BaseBridgeBloc
        bloc = ConcurrentBloc();
      });

      tearDown(() {
        bloc.close();
      });

      test('initial state should be empty', () {
        expect(bloc.state.ballsOnBridge, isEmpty);
        expect(bloc.state.ballsCompleted, isEmpty);
        expect(bloc.state.ballsDropped, isEmpty);
        expect(bloc.state.logs, isEmpty);
        expect(bloc.state.totalBallsSent, 0);
      });

      blocTest<BaseBridgeBloc, BridgeState>(
        'should update ball position when UpdateBallPositionEvent is added',
        build: () {
          bloc.emit(
            bloc.state.copyWith(
              ballsOnBridge: [
                const Ball(
                  id: 1,
                  position: 0,
                  isMoving: true,
                  color: Colors.red,
                ),
              ],
            ),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(UpdateBallPositionEvent(1, 0.5)),
        expect: () => [
          isA<BridgeState>().having(
            (state) => state.ballsOnBridge.first.position,
            'ball position',
            0.5,
          ),
        ],
      );

      blocTest<BaseBridgeBloc, BridgeState>(
        'should remove ball and mark as completed when RemoveBallEvent done',
        build: () {
          bloc.emit(
            bloc.state.copyWith(
              ballsOnBridge: [
                const Ball(
                  id: 1,
                  position: 1,
                  isMoving: false,
                  color: Colors.red,
                ),
              ],
            ),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(RemoveBallEvent(ballId: 1, completed: true)),
        expect: () => [
          isA<BridgeState>()
              .having(
                (state) => state.ballsOnBridge,
                'balls on bridge',
                isEmpty,
              )
              .having((state) => state.ballsCompleted, 'completed balls', [1])
              .having(
                (state) => state.logs.last,
                'last log',
                contains('Ball 1 reached destination'),
              ),
        ],
      );

      blocTest<BaseBridgeBloc, BridgeState>(
        'should drop ball when DropBallEvent is added',
        build: () => bloc,
        act: (bloc) => bloc.add(DropBallEvent(1)),
        expect: () => [
          isA<BridgeState>()
              .having((state) => state.ballsDropped, 'dropped balls', [1])
              .having(
                (state) => state.logs.last,
                'last log',
                contains('Ball 1 was dropped'),
              ),
        ],
      );

      blocTest<BaseBridgeBloc, BridgeState>(
        'should reset state when ResetEvent is added',
        build: () {
          bloc.emit(
            bloc.state.copyWith(
              ballsOnBridge: [
                const Ball(
                  id: 1,
                  position: 0.5,
                  isMoving: true,
                  color: Colors.red,
                ),
              ],
              ballsCompleted: [2],
              ballsDropped: [3],
              logs: ['Test log'],
              totalBallsSent: 5,
            ),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(ResetEvent()),
        expect: () => [
          const BridgeState(
            logs: [],
            ballsOnBridge: [],
            ballsCompleted: [],
            ballsDropped: [],
            totalBallsSent: 0,
          ),
        ],
      );
    });
  });
}

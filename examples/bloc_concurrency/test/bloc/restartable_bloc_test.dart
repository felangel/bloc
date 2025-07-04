import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movable_ball/bloc/index.dart';

void main() {
  // ==========================================================================
  //  RESTARTABLE BLOC TESTS
  // ==========================================================================
  group('RestartableBloc Tests', () {
    late RestartableBloc bloc;

    setUp(() {
      bloc = RestartableBloc();
    });

    tearDown(() {
      bloc.close();
    });

    blocTest<RestartableBloc, BridgeState>(
      'should add ball with purple color',
      build: () => bloc,
      act: (bloc) => bloc.add(SendBallEvent(1)),
      expect: () => [
        isA<BridgeState>()
            .having(
              (state) => state.logs.last,
              'last log',
              contains('cancels previous'),
            )
            .having(
              (state) => state.ballsOnBridge.first.color,
              'ball color',
              Colors.purple,
            ),
      ],
    );

    test(
      'restartable behavior - new ball should cancel previous ones',
      () async {
        // Send first ball
        bloc.add(SendBallEvent(1));
        await Future<void>.delayed(const Duration(milliseconds: 100));

        // Send second ball - should cancel first
        bloc.add(SendBallEvent(2));
        await Future<void>.delayed(const Duration(milliseconds: 100));

        // Should have dropped first ball
        expect(bloc.state.ballsDropped, contains(1));

        // Only second ball should be on bridge
        expect(bloc.state.ballsOnBridge.length, 1);
        expect(bloc.state.ballsOnBridge.first.id, 2);
      },
    );
  });
}

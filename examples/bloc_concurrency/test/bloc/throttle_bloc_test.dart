import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movable_ball/bloc/index.dart';

void main() {
  // ==========================================================================
  //  THROTTLE BLOC TESTS
  // ==========================================================================
  group('ThrottleBloc Tests', () {
    late ThrottleBloc bloc;

    setUp(() {
      bloc = ThrottleBloc();
    });

    tearDown(() {
      bloc.close();
    });

    blocTest<ThrottleBloc, BridgeState>(
      'should add ball with indigo color',
      build: () => bloc,
      act: (bloc) => bloc.add(SendBallEvent(1)),
      expect: () => [
        isA<BridgeState>()
            .having(
              (state) => state.ballsOnBridge.first.color,
              'ball color',
              Colors.indigo,
            )
            .having(
              (state) => state.logs.last,
              'last log',
              contains('Throttle'),
            ),
      ],
    );

    test('throttle behavior - should limit events to one per second', () async {
      // Send multiple balls quickly
      bloc.add(SendBallEvent(1));
      bloc.add(SendBallEvent(2));
      bloc.add(SendBallEvent(3));

      // Wait less than throttle duration
      await Future<void>.delayed(const Duration(milliseconds: 500));

      // Only first ball should be processed due to throttling
      expect(bloc.state.ballsOnBridge.length, 1);
      expect(bloc.state.ballsOnBridge.first.id, 1);

      // Wait for throttle duration to pass
      await Future<void>.delayed(const Duration(milliseconds: 600));

      // Send another ball
      bloc.add(SendBallEvent(4));
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Now second ball should be processed
      expect(bloc.state.ballsOnBridge.length, 2);
    });
  });
}

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movable_ball/bloc/index.dart';

void main() {
  // ==========================================================================
  //  DEBOUNCE BLOC TESTS
  // ==========================================================================
  group('DebounceBloc Tests', () {
    late DebounceBloc bloc;

    setUp(() {
      bloc = DebounceBloc();
    });

    tearDown(() {
      bloc.close();
    });

    blocTest<DebounceBloc, BridgeState>(
      'should add ball with deep orange color after debounce delay',
      build: () => bloc,
      act: (bloc) => bloc.add(SendBallEvent(1)),
      wait: const Duration(milliseconds: 2000), // Wait for debounce
      expect: () => [
        isA<BridgeState>()
            .having(
              (state) => state.logs.last,
              'last log',
              contains('2000ms'),
            )
            .having(
              (state) => state.ballsOnBridge.first.color,
              'ball color',
              Colors.deepOrange,
            ),
      ],
    );

    test(
      'debounce behavior - should only process last event after delay',
      () async {
        // Send multiple balls quickly
        bloc.add(SendBallEvent(1));
        await Future<void>.delayed(const Duration(milliseconds: 100));
        bloc.add(SendBallEvent(2));
        await Future<void>.delayed(const Duration(milliseconds: 100));
        bloc.add(SendBallEvent(3));

        // Wait less than debounce duration
        await Future<void>.delayed(const Duration(milliseconds: 1000));

        // No balls should be processed yet
        expect(bloc.state.ballsOnBridge.length, 0);

        // Wait for debounce duration to complete
        await Future<void>.delayed(const Duration(milliseconds: 1200));

        // Only the last ball (3) should be processed
        expect(bloc.state.ballsOnBridge.length, 1);
        expect(bloc.state.ballsOnBridge.first.id, 3);
      },
    );
  });
}

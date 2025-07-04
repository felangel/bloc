import 'package:flutter_test/flutter_test.dart';
import 'package:movable_ball/bloc/index.dart';

void main() {
  // ==========================================================================
  // INTEGRATION TESTS
  // ==========================================================================
  group('Integration Tests', () {
    test('all blocs should handle reset event properly', () async {
      final blocs = [
        ConcurrentBloc(),
        SequentialBloc(),
        DroppableBloc(),
        RestartableBloc(),
        ThrottleBloc(),
        DebounceBloc(),
      ];

      for (final bloc in blocs) {
        // Add some data
        bloc.add(SendBallEvent(1));
        await Future<void>.delayed(const Duration(milliseconds: 100));

        // Reset
        bloc.add(ResetEvent());
        await Future<void>.delayed(const Duration(milliseconds: 100));

        // Verify reset
        expect(bloc.state.ballsOnBridge, isEmpty);
        expect(bloc.state.ballsCompleted, isEmpty);
        expect(bloc.state.ballsDropped, isEmpty);
        expect(bloc.state.logs, isEmpty);
        expect(bloc.state.totalBallsSent, 0);

        await bloc.close();
      }
    });

    test('ball animation should update positions correctly', () async {
      final bloc = ConcurrentBloc()
        // Send a ball
        ..add(SendBallEvent(1));
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Simulate position updates
      bloc.add(UpdateBallPositionEvent(1, 0.02));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.ballsOnBridge.first.position, 0.02);

      bloc.add(UpdateBallPositionEvent(1, 0.04));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.ballsOnBridge.first.position, 0.04);

      await bloc.close();
    });
  });

  // ==========================================================================
  //  EDGE CASE TESTS
  // ==========================================================================
  group('Edge Cases', () {
    test('should handle non-existent ball position updates', () async {
      final bloc = ConcurrentBloc()
        // Try to update position of non-existent ball
        ..add(UpdateBallPositionEvent(999, 0.5));
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // State should remain unchanged
      expect(bloc.state.ballsOnBridge, isEmpty);

      await bloc.close();
    });

    test('should handle removing non-existent ball', () async {
      final bloc = ConcurrentBloc()
        // Try to remove non-existent ball
        ..add(RemoveBallEvent(ballId: 999, completed: true));
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // State should remain unchanged
      expect(bloc.state.ballsOnBridge, isEmpty);
      expect(bloc.state.ballsCompleted, isEmpty);

      await bloc.close();
    });

    test('should handle multiple rapid resets', () async {
      final bloc = ConcurrentBloc()
        // Send ball
        ..add(SendBallEvent(1));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // Multiple resets
      bloc
        ..add(ResetEvent())
        ..add(ResetEvent())
        ..add(ResetEvent());
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Should be in clean state
      expect(bloc.state.ballsOnBridge, isEmpty);
      expect(bloc.state.ballsCompleted, isEmpty);
      expect(bloc.state.ballsDropped, isEmpty);
      expect(bloc.state.logs, isEmpty);

      await bloc.close();
    });
  });
}

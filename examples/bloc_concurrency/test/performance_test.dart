import 'package:flutter_test/flutter_test.dart';
import 'package:movable_ball/bloc/index.dart';

void main() {
  // ==========================================================================
  //  PERFORMANCE TESTS
  // ==========================================================================
  group('Performance Tests', () {
    test('should handle large number of concurrent balls', () async {
      final bloc = ConcurrentBloc();

      // Send 100 balls
      for (var i = 1; i <= 100; i++) {
        bloc.add(SendBallEvent(i));
      }

      await Future<void>.delayed(const Duration(milliseconds: 500));

      // All balls should be on bridge
      expect(bloc.state.ballsOnBridge.length, 100);

      // Verify all IDs are present
      final ballIds = bloc.state.ballsOnBridge.map((b) => b.id).toSet();
      expect(ballIds.length, 100);

      await bloc.close();
    });

    test('should handle rapid fire events', () async {
      final bloc = ThrottleBloc();

      // Send 50 balls as fast as possible
      for (var i = 1; i <= 50; i++) {
        bloc.add(SendBallEvent(i));
      }

      await Future<void>.delayed(const Duration(milliseconds: 200));

      // Due to throttling, only first ball should be processed
      expect(bloc.state.ballsOnBridge.length, 1);
      expect(bloc.state.ballsOnBridge.first.id, 1);

      await bloc.close();
    });
  });
}

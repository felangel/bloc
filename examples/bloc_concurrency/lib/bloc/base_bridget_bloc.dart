// // Base BLoC with animation support
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movable_ball/bloc/bridge_event.dart';
import 'package:movable_ball/bloc/bridge_state.dart';

/// Base BLoC class for managing bridge animations and state transitions.
abstract class BaseBridgeBloc extends Bloc<dynamic, BridgeState> {
  /// Initializes the bridge state with empty lists and zero counters.
  BaseBridgeBloc()
    : super(
        const BridgeState(
          logs: [],
          ballsOnBridge: [],
          ballsCompleted: [],
          ballsDropped: [],
          totalBallsSent: 0,
        ),
      ) {
    on<UpdateBallPositionEvent>(_onUpdateBallPosition);
    on<RemoveBallEvent>(_onRemoveBall);
    on<DropBallEvent>(_onDropBall);
    on<ResetEvent>(_onReset);
  }

  void _onUpdateBallPosition(
    UpdateBallPositionEvent event,
    Emitter<BridgeState> emit,
  ) {
    final updatedBalls =
        state.ballsOnBridge.map((ball) {
          if (ball.id == event.ballId) {
            return ball.copyWith(position: event.position);
          }
          return ball;
        }).toList();

    emit(state.copyWith(ballsOnBridge: updatedBalls));
  }

  void _onRemoveBall(RemoveBallEvent event, Emitter<BridgeState> emit) {
    final updatedBalls =
        state.ballsOnBridge.where((ball) => ball.id != event.ballId).toList();
    final updatedCompleted =
        event.completed
            ? [...state.ballsCompleted, event.ballId]
            : state.ballsCompleted;
    final updatedLogs =
        event.completed
            ? [...state.logs, '✅ Ball ${event.ballId} reached destination!']
            : state.logs;

    emit(
      state.copyWith(
        ballsOnBridge: updatedBalls,
        ballsCompleted: updatedCompleted,
        logs: updatedLogs,
      ),
    );
  }

  void _onDropBall(DropBallEvent event, Emitter<BridgeState> emit) {
    emit(
      state.copyWith(
        ballsDropped: [...state.ballsDropped, event.ballId],
        logs: [...state.logs, '❌ Ball ${event.ballId} was dropped/cancelled'],
      ),
    );
  }

  void _onReset(ResetEvent event, Emitter<BridgeState> emit) {
    emit(
      const BridgeState(
        logs: [],
        ballsOnBridge: [],
        ballsCompleted: [],
        ballsDropped: [],
        totalBallsSent: 0,
      ),
    );
  }

  // Animation helper
  /// Animates a ball across the bridge.
  Future<void> animateBall(int ballId, Color ballColor) async {
    const duration = 5000; // 5 seconds
    const steps = 50;
    const stepDuration = duration ~/ steps;

    for (var i = 0; i <= steps; i++) {
      if (state.ballsOnBridge.any((ball) => ball.id == ballId)) {
        add(UpdateBallPositionEvent(ballId, i / steps));
        await Future<void>.delayed(const Duration(milliseconds: stepDuration));
      } else {
        break; // Ball was removed/cancelled
      }
    }

    // Only mark as completed if ball is still on bridge
    if (state.ballsOnBridge.any((ball) => ball.id == ballId)) {
      add(RemoveBallEvent(ballId: ballId, completed: true));
    }
  }
}

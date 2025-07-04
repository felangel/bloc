import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movable_ball/bloc/base_bridget_bloc.dart';
import 'package:movable_ball/bloc/bridge_event.dart';
import 'package:movable_ball/bloc/bridge_state.dart';
import 'package:movable_ball/models/ball.dart';

// Restartable BLoC - Latest ball cancels previous ones
/// This BLoC allows only the latest ball to cross the bridge,
class RestartableBloc extends BaseBridgeBloc {
  /// Creates an instance of [RestartableBloc].
  RestartableBloc() : super() {
    on<SendBallEvent>(_onSendBall, transformer: restartable());
  }

  Future<void> _onSendBall(
    SendBallEvent event,
    Emitter<BridgeState> emit,
  ) async {
    // Cancel previous balls
    if (state.ballsOnBridge.isNotEmpty) {
      for (final ball in state.ballsOnBridge) {
        add(DropBallEvent(ball.id));
      }
      emit(
        state.copyWith(
          logs: [
            ...state.logs,
            '❌ Previous balls cancelled by Ball ${event.ballId}',
          ],
        ),
      );
    }

    final ball = Ball(
      id: event.ballId,
      position: 0,
      isMoving: true,
      color: Colors.purple,
    );

    emit(
      state.copyWith(
        ballsOnBridge: [ball], // Only latest ball crosses
        logs: [
          ...state.logs,
          '🟣 Ball ${event.ballId} starts crossing (Restartable:',
          ' cancels previous)',
        ],
      ),
    );

    // Use try-catch to handle potential close errors
    try {
      if (!isClosed) {
        await animateBall(event.ballId, Colors.purple);
      }
    } catch (e) {
      // Ignore errors if bloc is closed during animation
      if (!e.toString().contains('Cannot add new events after calling close')) {
        rethrow;
      }
    }
  }
}

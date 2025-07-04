import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movable_ball/bloc/base_bridget_bloc.dart';
import 'package:movable_ball/bloc/bridge_event.dart';
import 'package:movable_ball/bloc/bridge_state.dart';
import 'package:movable_ball/models/ball.dart';

// Sequential BLoC - One ball at a time
/// This BLoC allows only one ball to cross the bridge at a time.
class SequentialBloc extends BaseBridgeBloc {
  /// Creates an instance of [SequentialBloc].
  SequentialBloc() : super() {
    on<SendBallEvent>(_onSendBall, transformer: sequential());
  }

  Future<void> _onSendBall(
    SendBallEvent event,
    Emitter<BridgeState> emit,
  ) async {
    final ball = Ball(
      id: event.ballId,
      position: 0,
      isMoving: true,
      color: Colors.blue,
    );

    emit(
      state.copyWith(
        ballsOnBridge: [...state.ballsOnBridge, ball],
        logs: [
          ...state.logs,
          '🔵 Ball ${event.ballId} starts crossing bridge (Sequential:',
          ' waits for previous)',
        ],
      ),
    );

    // Use try-catch to handle potential close errors
    try {
      if (!isClosed) {
        await animateBall(event.ballId, Colors.blue);
      }
    } catch (e) {
      // Ignore errors if bloc is closed during animation
      if (!e.toString().contains('Cannot add new events after calling close')) {
        rethrow;
      }
    }
  }
}

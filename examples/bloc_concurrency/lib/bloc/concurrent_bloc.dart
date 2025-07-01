import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movable_ball/bloc/base_bridget_bloc.dart';
import 'package:movable_ball/bloc/bridge_event.dart';
import 'package:movable_ball/bloc/bridge_state.dart';
import 'package:movable_ball/data/ball.dart';

// Concurrent BLoC - All balls cross together
/// This BLoC allows multiple balls to cross the bridge simultaneously.
class ConcurrentBloc extends BaseBridgeBloc {
  /// Creates an instance of [ConcurrentBloc].
  ConcurrentBloc() : super() {
    on<SendBallEvent>(_onSendBall, transformer: concurrent());
  }

  Future<void> _onSendBall(
    SendBallEvent event,
    Emitter<BridgeState> emit,
  ) async {
    final ball = Ball(
      id: event.ballId,
      position: 0,
      isMoving: true,
      color: Colors.green,
    );

    emit(
      state.copyWith(
        ballsOnBridge: [...state.ballsOnBridge, ball],
        logs: [
          ...state.logs,
          '🟢 Ball ${event.ballId} crossing (Concurrent: all cross together)',
        ],
      ),
    );

    await animateBall(event.ballId, Colors.green);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movable_ball/bloc/base_bridget_bloc.dart';
import 'package:movable_ball/bloc/bridge_event.dart';
import 'package:movable_ball/bloc/bridge_state.dart';
import 'package:movable_ball/data/ball.dart';
import 'package:rxdart/rxdart.dart';

/// BLoC that implements throttle behavior for sending balls across the bridge.
class ThrottleBloc extends BaseBridgeBloc {
  /// Creates an instance of [ThrottleBloc].
  ThrottleBloc() : super() {
    on<SendBallEvent>(
      _onSendBall,
      transformer: throttleTransformer(const Duration(seconds: 1)),
    );
  }
  // Throttle transformer
  EventTransformer<E> throttleTransformer<E>(Duration duration) {
    return (events, mapper) => events.throttleTime(duration).flatMap(mapper);
  }

  Future<void> _onSendBall(
    SendBallEvent event,
    Emitter<BridgeState> emit,
  ) async {
    final ball = Ball(
      id: event.ballId,
      position: 0,
      isMoving: true,
      color: Colors.indigo,
    );

    emit(
      state.copyWith(
        ballsOnBridge: [...state.ballsOnBridge, ball],
        logs: [
          ...state.logs,
          '🔵 Ball ${event.ballId} starts crossing (Throttle: one every 1s)',
        ],
      ),
    );

    await animateBall(event.ballId, Colors.indigo);
  }
}

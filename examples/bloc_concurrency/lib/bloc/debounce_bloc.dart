import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movable_ball/bloc/base_bridget_bloc.dart';
import 'package:movable_ball/bloc/bridge_event.dart';
import 'package:movable_ball/bloc/bridge_state.dart';
import 'package:movable_ball/data/ball.dart';
import 'package:rxdart/rxdart.dart';

/// BLoC that implements debounce behavior for sending balls across the bridge.
class DebounceBloc extends BaseBridgeBloc {
  /// Creates an instance of [DebounceBloc].
  DebounceBloc() : super() {
    on<SendBallEvent>(
      _onSendBall,
      transformer: debounceTransformer(const Duration(milliseconds: 2000)),
    );
  }
  // Debounce transformer
  /// This transformer delays the processing of events until a specified duration
  EventTransformer<E> debounceTransformer<E>(Duration duration) {
    return (events, mapper) => events.debounceTime(duration).flatMap(mapper);
  }

  Future<void> _onSendBall(
    SendBallEvent event,
    Emitter<BridgeState> emit,
  ) async {
    final ball = Ball(
      id: event.ballId,
      position: 0,
      isMoving: true,
      color: Colors.deepOrange,
    );

    emit(
      state.copyWith(
        ballsOnBridge: [...state.ballsOnBridge, ball],
        logs: [
          ...state.logs,
          '🟧 Ball ${event.ballId} crossing (Debounce: ',
          '2000ms delay after click)',
        ],
      ),
    );

    await animateBall(event.ballId, Colors.deepOrange);
  }
}

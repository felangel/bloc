import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movable_ball/bloc/base_bridget_bloc.dart';
import 'package:movable_ball/bloc/bridge_event.dart';
import 'package:movable_ball/bloc/bridge_state.dart';
import 'package:movable_ball/models/ball.dart';

// Droppable BLoC - Drop balls while one is crossing
/// This BLoC allows only one ball to cross the bridge at a time.
class DroppableBloc extends BaseBridgeBloc {
  /// Creates an instance of [DroppableBloc].
  DroppableBloc() : super() {
    on<SendBallEvent>(_onSendBall, transformer: droppable());
  }

  Future<void> _onSendBall(
    SendBallEvent event,
    Emitter<BridgeState> emit,
  ) async {
    // Drop any balls that were queued
    if (state.ballsOnBridge.isNotEmpty) {
      for (final ball in state.ballsOnBridge) {
        if (ball.position == 0.0) {
          // Only drop balls that haven't started moving
          add(DropBallEvent(ball.id));
        }
      }
    }

    final ball = Ball(
      id: event.ballId,
      position: 0,
      isMoving: true,
      color: Colors.orange,
    );

    emit(
      state.copyWith(
        ballsOnBridge: [ball], // Only this ball crosses
        logs: [
          ...state.logs,
          '🟠 Ball ${event.ballId} starts crossing (Droppable:',
          ' others dropped while crossing)',
        ],
      ),
    );

    // Use try-catch to handle potential close errors
    try {
      if (!isClosed) {
        await animateBall(event.ballId, Colors.orange);
      }
    } catch (e) {
      // Ignore errors if bloc is closed during animation
      if (!e.toString().contains('Cannot add new events after calling close')) {
        rethrow;
      }
    }
  }
}

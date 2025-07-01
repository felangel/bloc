import 'package:equatable/equatable.dart';
import 'package:movable_ball/data/ball.dart';

/// Represents the state of the bridge in the BLoC architecture.
class BridgeState extends Equatable {
  /// Creates an instance of [BridgeState] with the provided parameters.
  const BridgeState({
    required this.logs,
    required this.ballsOnBridge,
    required this.ballsCompleted,
    required this.ballsDropped,
    required this.totalBallsSent,
  });

  /// The logs of events that have occurred on the bridge.
  final List<String> logs;

  /// The list of balls currently on the bridge.
  final List<Ball> ballsOnBridge;

  /// The list of IDs of balls that have completed their
  /// journey across the bridge.
  final List<int> ballsCompleted;

  /// The list of IDs of balls that have been dropped from the bridge.
  final List<int> ballsDropped;

  /// The total number of balls that have been sent across the bridge.
  final int totalBallsSent;

  /// Creates a copy of the current [BridgeState] with the option to
  BridgeState copyWith({
    List<String>? logs,
    List<Ball>? ballsOnBridge,
    List<int>? ballsCompleted,
    List<int>? ballsDropped,
    int? totalBallsSent,
  }) {
    return BridgeState(
      logs: logs ?? this.logs,
      ballsOnBridge: ballsOnBridge ?? this.ballsOnBridge,
      ballsCompleted: ballsCompleted ?? this.ballsCompleted,
      ballsDropped: ballsDropped ?? this.ballsDropped,
      totalBallsSent: totalBallsSent ?? this.totalBallsSent,
    );
  }

  @override
  List<Object> get props => [
    logs,
    ballsOnBridge,
    ballsCompleted,
    ballsDropped,
    totalBallsSent,
  ];
}

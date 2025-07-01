import 'package:equatable/equatable.dart';

/// Base class for bridge events in the BLoC architecture.
sealed class BridgeEvent extends Equatable {}

// Event
/// Represents a request to send a ball across the bridge.
final class SendBallEvent extends BridgeEvent {
  /// Creates an event to send a ball with the specified ID.
  SendBallEvent(this.ballId);

  /// The unique identifier for the ball being sent.
  final int ballId;

  @override
  List<Object> get props => [ballId];
}

/// Represents a request to reset the bridge state.
final class ResetEvent extends BridgeEvent {
  @override
  List<Object> get props => [];
}

/// This event is used to update the position of a ball on the bridge.
final class UpdateBallPositionEvent extends BridgeEvent {
  /// Creates an event to update the position of a ball with the specified ID.
  UpdateBallPositionEvent(this.ballId, this.position);

  /// The unique identifier for the ball whose position is being updated.
  final int ballId;

  /// The new position of the ball on the bridge, represented as a double.
  final double position;

  @override
  List<Object> get props => [ballId, position];
}

/// Represents an event to remove a ball from the bridge.
final class RemoveBallEvent extends BridgeEvent {
  /// Creates an event to remove a ball with the specified ID.
  RemoveBallEvent({required this.ballId, required this.completed});

  /// The unique identifier for the ball being removed.
  final int ballId;

  /// Indicates whether the ball has completed its journey across the bridge.
  final bool completed;

  @override
  List<Object> get props => [ballId, completed];
}

/// Represents an event to drop a ball from the bridge.
final class DropBallEvent extends BridgeEvent {
  /// Creates an event to drop a ball with the specified ID.
  DropBallEvent(this.ballId);

  /// The unique identifier for the ball being dropped.
  final int ballId;

  @override
  List<Object> get props => [ballId];
}

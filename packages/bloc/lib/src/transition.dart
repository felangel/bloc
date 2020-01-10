import 'package:meta/meta.dart';

/// {@template transition}
/// Occurs when an [event] is `added` after `mapEventToState` has been called
/// but before the [bloc]'s `state` has been updated.
/// A [Transition] consists of the [currentState], the [event] which was
/// `added`, and the [nextState].
/// {@endtemplate}
@immutable
class Transition<Event, State> {
  /// The current [State] of the [bloc] at the time of the [Transition].
  final State currentState;

  /// The [Event] which triggered the current [Transition].
  final Event event;

  /// The next [State] of the [bloc] at the time of the [Transition].
  final State nextState;

  /// {@macro transition}
  const Transition({
    @required this.currentState,
    @required this.event,
    @required this.nextState,
  })  : assert(currentState != null),
        assert(event != null),
        assert(nextState != null);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transition<Event, State> &&
          runtimeType == other.runtimeType &&
          currentState == other.currentState &&
          event == other.event &&
          nextState == other.nextState;

  @override
  int get hashCode =>
      currentState.hashCode ^ event.hashCode ^ nextState.hashCode;

  @override
  String toString() =>
      'Transition { currentState: $currentState, event: $event, '
      'nextState: $nextState }';
}

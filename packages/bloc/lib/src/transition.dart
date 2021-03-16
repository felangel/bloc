import 'package:meta/meta.dart';

/// {@template transition}
/// A [Transition] is the change from one state to another.
/// Consists of the [currentState], an [event], and the [nextState].
/// {@endtemplate}
@immutable
class Transition<Event, State> {
  /// {@macro transition}
  const Transition({
    required this.currentState,
    required this.event,
    required this.nextState,
  });

  /// The current [State] at the time of the [Transition].
  final State currentState;

  /// The [Event] which triggered the current [Transition].
  final Event event;

  /// The next [State] at the time of the [Transition].
  final State nextState;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transition<Event, State> &&
          runtimeType == other.runtimeType &&
          currentState == other.currentState &&
          event == other.event &&
          nextState == other.nextState;

  @override
  int get hashCode {
    return currentState.hashCode ^ event.hashCode ^ nextState.hashCode;
  }

  @override
  String toString() {
    return '''Transition { currentState: $currentState, ${event == null ? '' : 'event: $event, '}nextState: $nextState }''';
  }
}

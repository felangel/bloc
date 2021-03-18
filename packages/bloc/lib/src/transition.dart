import 'package:meta/meta.dart';

/// {@template change}
/// A [Change] represents the change from one [State] to another.
/// A [Change] consists of the [currentState] and [nextState].
/// {@endtemplate}
@immutable
class Change<State> {
  /// {@macro change}
  const Change({required this.currentState, required this.nextState});

  /// The current [State] at the time of the [Change].
  final State currentState;

  /// The next [State] at the time of the [Change].
  final State nextState;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Change<State> &&
          runtimeType == other.runtimeType &&
          currentState == other.currentState &&
          nextState == other.nextState;

  @override
  int get hashCode => currentState.hashCode ^ nextState.hashCode;

  @override
  String toString() {
    return 'Change { currentState: $currentState, nextState: $nextState }';
  }
}

/// {@template transition}
/// A [Transition] is the change from one state to another.
/// Consists of the [currentState], an [event], and the [nextState].
/// {@endtemplate}
@immutable
class Transition<Event, State> extends Change<State> {
  /// {@macro transition}
  const Transition({
    required State currentState,
    required this.event,
    required State nextState,
  }) : super(currentState: currentState, nextState: nextState);

  /// The [Event] which triggered the current [Transition].
  final Event event;

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
    return '''Transition { currentState: $currentState, event: $event, nextState: $nextState }''';
  }
}

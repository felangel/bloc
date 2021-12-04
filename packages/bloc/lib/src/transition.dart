import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

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

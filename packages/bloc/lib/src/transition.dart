import 'package:cubit/cubit.dart' as cubit;
import 'package:meta/meta.dart';

/// {@template transition}
/// Occurs when an [event] is `added` after `mapEventToState` has been called
/// but before the [bloc]'s `state` has been updated.
/// A [Transition] consists of the [currentState], the [event] which was
/// `added`, and the [nextState].
/// {@endtemplate}
@immutable
class Transition<Event, State> extends cubit.Transition<State> {
  /// {@macro transition}
  const Transition({
    @required State currentState,
    @required this.event,
    @required State nextState,
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

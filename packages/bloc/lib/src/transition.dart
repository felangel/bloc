import 'package:meta/meta.dart';

/// Occurs when an [Event] is `dispatched` after `mapEventToState` has been called
/// but before the [Bloc]'s [State] has been updated.
/// A [Transition] consists of the `currentState`, the `event` which was `dispatched`, and the `nextState`.
class Transition<Event, State> {
  final State currentState;
  final Event event;
  final State nextState;

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
      'Transition { currentState: $currentState, event: $event, nextState: $nextState }';
}

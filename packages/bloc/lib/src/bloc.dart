import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:bloc/bloc.dart';

/// Takes a [Stream] of [Event]s as input
/// and transforms them into a [Stream] of [State]s as output.
abstract class Bloc<Event, State> {
  final PublishSubject<Event> _eventSubject = PublishSubject<Event>();

  BehaviorSubject<State> _stateSubject;

  /// Returns [Stream] of [State]s.
  /// Consumed by [BlocBuilder].
  Stream<State> get state => _stateSubject.stream;

  /// Returns the [State] before any [Event]s have been `dispatched`.
  State get initialState;

  /// Returns the current [State] of the [Bloc].
  State get currentState => _stateSubject.value;

  Bloc() {
    _stateSubject = BehaviorSubject<State>(seedValue: initialState);
    _bindStateSubject();
  }

  /// Called whenever a [Transition] occurs with the given [Transition].
  /// A [Transition] occurs when a new [Event] is dispatched and `mapEventToState` executed.
  /// `onTransition` is called before a [Bloc]'s [State] has been updated.
  /// A great spot to add logging/analytics.
  void onTransition(Transition<Event, State> transition) => null;

  /// Takes an [Event] and triggers `mapEventToState`.
  /// `Dispatch` may be called from the presentation layer or from within the [Bloc].
  /// `Dispatch` notifies the [Bloc] of a new [Event].
  void dispatch(Event event) {
    _eventSubject.sink.add(event);
  }

  /// Closes the [Event] and [State] [Stream]s.
  void dispose() {
    _eventSubject.close();
    _stateSubject.close();
  }

  /// Transform the `Stream<Event>` before `mapEventToState` is called.
  /// This allows for operations like `distinct()`, `debounce()`, etc... to be applied.
  Stream<Event> transform(Stream<Event> events) => events;

  /// Must be implemented when a class extends [Bloc].
  /// Takes the current `state` and incoming `event` as arguments.
  /// `mapEventToState` is called whenever an [Event] is `dispatched` by the presentation layer.
  /// `mapEventToState` must convert that [Event], along with the current [State], into a new [State]
  /// and return the new [State] in the form of a [Stream] which is consumed by the presentation layer.
  Stream<State> mapEventToState(State currentState, Event event);

  void _bindStateSubject() {
    Event currentEvent;

    (transform(_eventSubject) as Observable<Event>).concatMap((Event event) {
      currentEvent = event;
      return mapEventToState(_stateSubject.value, event);
    }).forEach(
      (State nextState) {
        final transition = Transition(
          currentState: _stateSubject.value,
          event: currentEvent,
          nextState: nextState,
        );
        BlocSupervisor().delegate?.onTransition(transition);
        onTransition(transition);
        _stateSubject.add(nextState);
      },
    );
  }
}

import 'dart:async';

import 'package:rxdart/rxdart.dart';

/// Takes a [Stream] of events as input
/// and transforms them into a [Stream] of states as output.
abstract class Bloc<E, S> {
  final PublishSubject<E> _eventSubject = PublishSubject<E>();

  final BehaviorSubject<S> _stateSubject = BehaviorSubject<S>();

  /// Returns [Stream] of states.
  /// Consumed by [BlocBuilder].
  Stream<S> get state => _stateSubject;

  /// Returns the state before any events have been `dispatched`.
  S get initialState => null;

  Bloc() {
    _bindStateSubject();
  }

  /// Takes an event and triggers `mapEventToState`.
  /// `Dispatch` may be called from the presentation layer or from within the Bloc.
  /// `Dispatch` notifies the [Bloc] of a new event.
  void dispatch(E event) {
    _eventSubject.sink.add(event);
  }

  /// Closes the event [Stream].
  /// This is automatically handled by [BlocBuilder].
  void dispose() {
    _eventSubject.close();
    _stateSubject.close();
  }

  /// Transform the `Stream<Event>` before `mapEventToState` is called.
  /// This allows for operations like `distinct()`, `debounce()`, etc... to be applied.
  Stream<E> transform(Stream<E> events) => events;

  /// Must be implemented when a class extends Bloc.
  /// Takes the current `state` and incoming `event` as arguments.
  /// `mapEventToState` is called whenever an event is dispatched by the presentation layer.
  /// `mapEventToState` must convert that event, along with the current state, into a new state
  /// and return the new state in the form of a [Stream] which is consumed by the presentation layer.
  Stream<S> mapEventToState(S state, E event);

  void _bindStateSubject() {
    (transform(_eventSubject) as Observable<E>)
        .concatMap(
      (E event) => mapEventToState(_stateSubject.value ?? initialState, event),
    )
        .forEach(
      (S state) {
        _stateSubject.add(state);
      },
    );
  }
}

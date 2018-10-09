import 'dart:async';

import 'package:rxdart/rxdart.dart';

/// Takes a [Stream] of events as input
/// and transforms them into a [Stream] of states as output.
abstract class Bloc<E, S> {
  final _eventSubject = PublishSubject<E>();
  Stream<S> _stateSubject;

  Stream<S> get state => _stateSubject;

  /// Returns the state before any events have been `dispatched`.
  S get initialState => null;

  Bloc() {
    _stateSubject = (transform(_eventSubject) as Observable<E>)
        .switchMap((E event) => mapEventToState(event));
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
  }

  /// Transform the `Stream<Event>` before `mapEventToState` is called.
  /// This allows for operations like `distinct()`, `debounce()`, etc... to be applied.
  Stream<E> transform(Stream<E> events) => events;

  /// Must be implemented when a class extends Bloc.
  /// Takes a single argument, `event`.
  /// `mapEventToState` is called whenever an event is dispatched by the presentation layer.
  /// `mapEventToState` must convert that event into a state and return the state
  /// in the form of a [Stream] so that it can be consumed by the presentation layer.
  Stream<S> mapEventToState(E event);
}

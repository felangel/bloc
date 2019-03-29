import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

/// Takes a [Stream] of [Event]s as input
/// and transforms them into a [Stream] of [State]s as output.
abstract class Bloc<Event, State> {
  final PublishSubject<Event> _eventSubject = PublishSubject<Event>();

  BehaviorSubject<State> _stateSubject;

  /// Returns [Stream] of [State]s.
  /// Consumed by the presentation layer.
  Stream<State> get state => _stateSubject.stream;

  /// Returns the [State] before any [Event]s have been `dispatched`.
  State get initialState;

  /// Returns the current [State] of the [Bloc].
  State get currentState => _stateSubject.value;

  Bloc() {
    _stateSubject = BehaviorSubject<State>.seeded(initialState);
    _bindStateSubject();
  }

  /// Called whenever a [Transition] occurs with the given [Transition].
  /// A [Transition] occurs when a new [Event] is dispatched and `mapEventToState` executed.
  /// `onTransition` is called before a [Bloc]'s [State] has been updated.
  /// A great spot to add logging/analytics.
  void onTransition(Transition<Event, State> transition) => null;

  /// Called whenever an [Exception] is thrown within `mapEventToState`.
  /// By default all exceptions will be ignored and [Bloc] functionality will be unaffected.
  /// The stacktrace argument may be `null` if the state stream received an error without a [StackTrace].
  /// A great spot to handle exceptions at the individual [Bloc] level.
  void onError(Object error, StackTrace stacktrace) => null;

  /// Takes an [Event] and triggers `mapEventToState`.
  /// `Dispatch` may be called from the presentation layer or from within the [Bloc].
  /// `Dispatch` notifies the [Bloc] of a new [Event].
  /// If `dispose` has already been called, any subsequent calls to `dispatch` will
  /// be delegated to the `onError` method which can be overriden at the [Bloc]
  /// as well as the [BlocDelegate] level.
  void dispatch(Event event) {
    try {
      _eventSubject.sink.add(event);
    } catch (error) {
      _handleError(error);
    }
  }

  /// Closes the [Event] and [State] [Stream]s.
  @mustCallSuper
  void dispose() {
    _eventSubject.close();
    _stateSubject.close();
  }

  /// Transform the `Stream<Event>` before `mapEventToState` is called.
  /// This allows for operations like `distinct()`, `debounce()`, etc... to be applied.
  Stream<Event> transform(Stream<Event> events) => events;

  /// Must be implemented when a class extends [Bloc].
  /// Takes the incoming `event` as the argument.
  /// `mapEventToState` is called whenever an [Event] is `dispatched` by the presentation layer.
  /// `mapEventToState` must convert that [Event] into a new [State]
  /// and return the new [State] in the form of a [Stream] which is consumed by the presentation layer.
  Stream<State> mapEventToState(Event event);

  void _bindStateSubject() {
    Event currentEvent;

    transform(_eventSubject).asyncExpand((Event event) {
      currentEvent = event;
      return mapEventToState(currentEvent).handleError(_handleError);
    }).forEach(
      (State nextState) {
        if (currentState == nextState) return;
        final transition = Transition(
          currentState: currentState,
          event: currentEvent,
          nextState: nextState,
        );
        BlocSupervisor().delegate?.onTransition(transition);
        onTransition(transition);
        _stateSubject.add(nextState);
      },
    );
  }

  void _handleError(Object error, [StackTrace stacktrace]) {
    onError(error, stacktrace);
    BlocSupervisor().delegate?.onError(error, stacktrace);
  }
}

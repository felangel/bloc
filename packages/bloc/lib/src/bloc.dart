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
  /// Usually consumed by the presentation layer.
  Stream<State> get state => _stateSubject.stream;

  /// Returns the [State] before any [Event]s have been `dispatched`.
  State get initialState;

  /// Returns the current [State] of the [Bloc].
  State get currentState => _stateSubject.value;

  Bloc() {
    _stateSubject = BehaviorSubject<State>.seeded(initialState);
    _bindStateSubject();
  }

  /// Called whenever an [Event] is dispatched to the [Bloc].
  /// A great spot to add logging/analytics at the individual [Bloc] level.
  void onEvent(Event event) => null;

  /// Called whenever a [Transition] occurs with the given [Transition].
  /// A [Transition] occurs when a new [Event] is dispatched and `mapEventToState` executed.
  /// `onTransition` is called before a [Bloc]'s [State] has been updated.
  /// A great spot to add logging/analytics at the individual [Bloc] level.
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
      BlocSupervisor.delegate.onEvent(this, event);
      onEvent(event);
      _eventSubject.sink.add(event);
    } catch (error) {
      _handleError(error);
    }
  }

  /// Closes the [Event] and [State] [Stream]s.
  /// This method should be called when a [Bloc] is no longer needed.
  /// Once `dispose` is called, events that are `dispatched` will not be
  /// processed and will result in an error being passed to `onError`.
  /// In addition, if `dispose` is called while [Event]s are still being processed,
  /// any [State]s yielded after are ignored and will not result in a [Transition].
  @mustCallSuper
  void dispose() {
    _eventSubject.close();
    _stateSubject.close();
  }

  /// Transforms the `Stream<Event>` along with a `next` function into a `Stream<State>`.
  /// Events that should be processed by `mapEventToState` need to be passed to `next`.
  /// By default `asyncExpand` is used to ensure all events are processed in the order
  /// in which they are received. You can override `transformEvents` for advanced usage
  /// in order to manipulate the frequency and specificity with which `mapEventToState`
  /// is called as well as which events are processed.
  ///
  /// For example, if you only want `mapEventToState` to be called on the most recent
  /// event you can use `switchMap` instead of `asyncExpand`.
  ///
  /// ```dart
  /// @override
  /// Stream<State> transformEvents(events, next) {
  ///   return (events as Observable<Event>).switchMap(next);
  /// }
  /// ```
  ///
  /// Alternatively, if you only want `mapEventToState` to be called for distinct events:
  ///
  /// ```dart
  /// @override
  /// Stream<State> transformEvents(events, next) {
  ///   return super.transformEvents(
  ///     (events as Observable<Event>).distinct(),
  ///     next,
  ///   );
  /// }
  /// ```
  Stream<State> transformEvents(
    Stream<Event> events,
    Stream<State> next(Event event),
  ) {
    return events.asyncExpand(next);
  }

  /// Must be implemented when a class extends [Bloc].
  /// Takes the incoming `event` as the argument.
  /// `mapEventToState` is called whenever an [Event] is `dispatched` by the presentation layer.
  /// `mapEventToState` must convert that [Event] into a new [State]
  /// and return the new [State] in the form of a [Stream] which is consumed by the presentation layer.
  Stream<State> mapEventToState(Event event);

  /// Transforms the `Stream<State>` into a new `Stream<State>`.
  /// By default `transformStates` returns the incoming `Stream<State>`.
  /// You can override `transformStates` for advanced usage
  /// in order to manipulate the frequency and specificity at which `transitions` (state changes)
  /// occur.
  ///
  /// For example, if you want to debounce outgoing states:
  ///
  /// ```dart
  /// @override
  /// Stream<State> transformStates(Stream<State> states) {
  ///   return (states as Observable<State>).debounceTime(Duration(seconds: 1));
  /// }
  /// ```
  Stream<State> transformStates(Stream<State> states) => states;

  void _bindStateSubject() {
    Event currentEvent;

    transformStates(transformEvents(_eventSubject, (Event event) {
      currentEvent = event;
      return mapEventToState(currentEvent).handleError(_handleError);
    })).forEach(
      (State nextState) {
        if (currentState == nextState || _stateSubject.isClosed) return;
        final transition = Transition(
          currentState: currentState,
          event: currentEvent,
          nextState: nextState,
        );
        BlocSupervisor.delegate.onTransition(this, transition);
        onTransition(transition);
        _stateSubject.add(nextState);
      },
    );
  }

  void _handleError(Object error, [StackTrace stacktrace]) {
    BlocSupervisor.delegate.onError(this, error, stacktrace);
    onError(error, stacktrace);
  }
}

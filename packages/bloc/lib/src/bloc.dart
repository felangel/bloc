import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import '../bloc.dart';

/// {@template bloc}
/// Takes a `Stream` of `Events` as input
/// and transforms them into a `Stream` of `States` as output.
/// {@endtemplate}
abstract class Bloc<Event, State> extends Stream<State> implements Sink<Event> {
  final PublishSubject<Event> _eventSubject = PublishSubject<Event>();

  BehaviorSubject<State> _stateSubject;

  /// Returns the current [state] of the [bloc].
  State get state => _stateSubject.value;

  /// Returns the [state] before any `events` have been [add]ed.
  State get initialState;

  /// Returns whether the `Stream<State>` is a broadcast stream.
  @override
  bool get isBroadcast => _stateSubject.isBroadcast;

  /// {@macro bloc}
  Bloc() {
    _stateSubject = BehaviorSubject<State>.seeded(initialState);
    _bindStateSubject();
  }

  /// Adds a subscription to the `Stream<State>`.
  /// Returns a [StreamSubscription] which handles events from
  /// the `Stream<State>` using the provided [onData], [onError] and [onDone]
  /// handlers.
  @override
  StreamSubscription<State> listen(
    void Function(State) onData, {
    Function onError,
    void Function() onDone,
    bool cancelOnError,
  }) {
    return _stateSubject.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  /// Called whenever an [event] is [add]ed to the [bloc].
  /// A great spot to add logging/analytics at the individual [bloc] level.
  void onEvent(Event event) => null;

  /// Called whenever a [transition] occurs with the given [transition].
  /// A [transition] occurs when a new `event` is [add]ed and [mapEventToState]
  /// executed.
  /// [onTransition] is called before a [bloc]'s [state] has been updated.
  /// A great spot to add logging/analytics at the individual [bloc] level.
  void onTransition(Transition<Event, State> transition) => null;

  /// Called whenever an [error] is thrown within [mapEventToState].
  /// By default all [error]s will be ignored and [bloc] functionality will be
  /// unaffected.
  /// The [stacktrace] argument may be `null` if the [state] stream received
  /// an error without a [stacktrace].
  /// A great spot to handle errors at the individual [Bloc] level.
  void onError(Object error, StackTrace stacktrace) => null;

  /// Notifies the [bloc] of a new [event] which triggers [mapEventToState].
  /// If [close] has already been called, any subsequent calls to [add] will
  /// be delegated to the [onError] method which can be overriden at the [bloc]
  /// as well as the [BlocDelegate] level.
  @override
  void add(Event event) {
    try {
      BlocSupervisor.delegate.onEvent(this, event);
      onEvent(event);
      _eventSubject.sink.add(event);
    } on dynamic catch (error) {
      _handleError(error);
    }
  }

  /// Closes the `event` and `state` `Streams`.
  /// This method should be called when a [bloc] is no longer needed.
  /// Once [close] is called, `events` that are [add]ed will not be
  /// processed and will result in an error being passed to [onError].
  /// In addition, if [close] is called while `events` are still being
  /// processed,
  /// the [bloc] will continue to process the pending `events` to completion.
  @override
  @mustCallSuper
  Future<void> close() async {
    await _eventSubject.close();
    await _stateSubject.close();
  }

  /// Transforms the [events] stream along with a [next] function into
  /// a `Stream<State>`.
  /// Events that should be processed by [mapEventToState] need to be passed to
  /// [next].
  /// By default `asyncExpand` is used to ensure all [events] are processed in
  /// the order in which they are received.
  /// You can override [transformEvents] for advanced usage in order to
  /// manipulate the frequency and specificity with which [mapEventToState] is
  /// called as well as which [events] are processed.
  ///
  /// For example, if you only want [mapEventToState] to be called on the most
  /// recent [event] you can use `switchMap` instead of `asyncExpand`.
  ///
  /// ```dart
  /// @override
  /// Stream<State> transformEvents(events, next) => events.switchMap(next);
  /// ```
  ///
  /// Alternatively, if you only want [mapEventToState] to be called for
  /// distinct [events]:
  ///
  /// ```dart
  /// @override
  /// Stream<State> transformEvents(events, next) {
  ///   return super.transformEvents(
  ///     events.distinct(),
  ///     next,
  ///   );
  /// }
  /// ```
  Stream<State> transformEvents(
    Stream<Event> events,
    Stream<State> Function(Event) next,
  ) {
    return events.asyncExpand(next);
  }

  /// Must be implemented when a class extends [bloc].
  /// Takes the incoming [event] as the argument.
  /// [mapEventToState] is called whenever an [event] is [add]ed.
  /// [mapEventToState] must convert that [event] into a new [state]
  /// and return the new [state] in the form of a `Stream<State>`.
  Stream<State> mapEventToState(Event event);

  /// Transforms the `Stream<State>` into a new `Stream<State>`.
  /// By default [transformStates] returns the incoming `Stream<State>`.
  /// You can override [transformStates] for advanced usage in order to
  /// manipulate the frequency and specificity at which `transitions`
  /// (state changes) occur.
  ///
  /// For example, if you want to debounce outgoing [states]:
  ///
  /// ```dart
  /// @override
  /// Stream<State> transformStates(Stream<State> states) {
  ///   return states.debounceTime(Duration(seconds: 1));
  /// }
  /// ```
  Stream<State> transformStates(Stream<State> states) => states;

  void _bindStateSubject() {
    Event currentEvent;

    transformStates(transformEvents(_eventSubject, (event) {
      currentEvent = event;
      return mapEventToState(currentEvent).handleError(_handleError);
    })).forEach(
      (nextState) {
        if (state == nextState || _stateSubject.isClosed) return;
        final transition = Transition(
          currentState: state,
          event: currentEvent,
          nextState: nextState,
        );
        try {
          BlocSupervisor.delegate.onTransition(this, transition);
          onTransition(transition);
          _stateSubject.add(nextState);
        } on dynamic catch (error) {
          _handleError(error);
        }
      },
    );
  }

  void _handleError(Object error, [StackTrace stacktrace]) {
    BlocSupervisor.delegate.onError(this, error, stacktrace);
    onError(error, stacktrace);
  }
}

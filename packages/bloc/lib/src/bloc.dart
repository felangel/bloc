import 'dart:async';

import 'package:meta/meta.dart';

import 'bloc_observer.dart';
import 'transition.dart';

/// Signature for a mapper function which takes an [Event] as input
/// and outputs a [Stream] of [Transition] objects.
typedef TransitionFunction<Event, State> = Stream<Transition<Event, State>>
    Function(Event);

/// {@template bloc_unhandled_error_exception}
/// Exception thrown when an unhandled error occurs within a [Bloc].
///
/// _Note: thrown in debug mode only_
/// {@endtemplate}
class BlocUnhandledErrorException implements Exception {
  /// {@macro bloc_unhandled_error_exception}
  BlocUnhandledErrorException(
    this.bloc,
    this.error, [
    this.stackTrace = StackTrace.empty,
  ]);

  /// The [bloc] in which the unhandled error occurred.
  final Bloc bloc;

  /// The unhandled [error] object.
  final Object error;

  /// Stack trace which accompanied the error.
  /// May be [StackTrace.empty] if no stack trace was provided.
  final StackTrace stackTrace;

  @override
  String toString() {
    return 'Unhandled error $error occurred in $bloc.\n'
        '$stackTrace';
  }
}

/// {@template bloc}
/// Takes a `Stream` of `Events` as input
/// and transforms them into a `Stream` of `States` as output.
/// {@endtemplate}
abstract class Bloc<Event, State> extends Stream<State>
    implements EventSink<Event> {
  /// {@macro bloc}
  Bloc(this._state) {
    // ignore: invalid_use_of_protected_member
    _observer.onCreate(this);
    if (this is! Cubit<State>) _bindEventsToStates();
  }

  BlocObserver get _observer => Bloc.observer;

  /// The current [state].
  State get state => _state;

  /// The current [BlocObserver].
  static BlocObserver observer = BlocObserver();

  State _state;

  StreamSubscription<Transition<Event, State>>? _transitionSubscription;

  StreamController<State>? _stateController;

  StreamController<Event>? _eventController;

  bool _emitted = false;

  /// Notifies the [Bloc] of a new [event] which triggers [mapEventToState].
  /// If [close] has already been called, any subsequent calls to [add] will
  /// be ignored and will not result in any subsequent state changes.
  @override
  void add(Event event) {
    _eventController ??= StreamController<Event>();
    if (_eventController!.isClosed) return;
    try {
      onEvent(event);
      _eventController!.add(event);
    } catch (error, stackTrace) {
      onError(error, stackTrace);
    }
  }

  /// Adds a subscription to the `Stream<State>`.
  /// Returns a [StreamSubscription] which handles events from
  /// the `Stream<State>` using the provided [onData], [onError] and [onDone]
  /// handlers.
  @override
  StreamSubscription<State> listen(
    void Function(State)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    _stateController ??= StreamController<State>.broadcast();
    return _stateController!.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  /// Returns whether the `Stream<State>` is a broadcast stream.
  /// Every [Bloc] is a broadcast stream.
  @override
  bool get isBroadcast => true;

  /// Called whenever an [event] is [add]ed to the [Bloc].
  /// A great spot to add logging/analytics at the individual [Bloc] level.
  ///
  /// **Note: `super.onEvent` should always be called first.**
  /// ```dart
  /// @override
  /// void onEvent(Event event) {
  ///   // Always call super.onEvent with the current event
  ///   super.onEvent(event);
  ///
  ///   // Custom onEvent logic goes here
  /// }
  /// ```
  ///
  /// See also:
  ///
  /// * [BlocObserver] for observing [Bloc] behavior globally.
  ///
  @protected
  @mustCallSuper
  void onEvent(Event event) {
    // ignore: invalid_use_of_protected_member
    observer.onEvent(this, event);
  }

  /// Transforms the [events] stream along with a [transitionFn] function into
  /// a `Stream<Transition>`.
  /// Events that should be processed by [mapEventToState] need to be passed to
  /// [transitionFn].
  /// By default `asyncExpand` is used to ensure all [events] are processed in
  /// the order in which they are received.
  /// You can override [transformEvents] for advanced usage in order to
  /// manipulate the frequency and specificity with which [mapEventToState] is
  /// called as well as which [events] are processed.
  ///
  /// For example, if you only want [mapEventToState] to be called on the most
  /// recent [Event] you can use `switchMap` instead of `asyncExpand`.
  ///
  /// ```dart
  /// @override
  /// Stream<Transition<Event, State>> transformEvents(events, transitionFn) {
  ///   return events.switchMap(transitionFn);
  /// }
  /// ```
  ///
  /// Alternatively, if you only want [mapEventToState] to be called for
  /// distinct [events]:
  ///
  /// ```dart
  /// @override
  /// Stream<Transition<Event, State>> transformEvents(events, transitionFn) {
  ///   return super.transformEvents(
  ///     events.distinct(),
  ///     transitionFn,
  ///   );
  /// }
  /// ```
  Stream<Transition<Event, State>> transformEvents(
    Stream<Event> events,
    TransitionFunction<Event, State> transitionFn,
  ) {
    return events.asyncExpand(transitionFn);
  }

  /// {@template emit}
  /// **[emit] should never be used outside of tests.**
  ///
  /// Updates the state of the bloc to the provided [state].
  /// A bloc's state should only be updated by `yielding` a new `state`
  /// from `mapEventToState` in response to an event.
  /// {@endtemplate}
  @protected
  @visibleForTesting
  void emit(State state) {
    _stateController ??= StreamController<State>.broadcast();
    if (_stateController!.isClosed) return;
    if (state == _state && _emitted) return;
    if (this is Cubit<State>) {
      onTransition(
        Transition<Event, State>(
          currentState: this.state,
          nextState: state,
        ),
      );
    }
    _state = state;
    _stateController!.add(_state);
    _emitted = true;
  }

  /// Must be implemented when a class extends [Bloc].
  /// [mapEventToState] is called whenever an [event] is [add]ed
  /// and is responsible for converting that [event] into a new [state].
  /// [mapEventToState] can `yield` zero, one, or multiple states for an event.
  Stream<State> mapEventToState(Event event);

  /// Transforms the `Stream<Transition>` into a new `Stream<Transition>`.
  /// By default [transformTransitions] returns
  /// the incoming `Stream<Transition>`.
  /// You can override [transformTransitions] for advanced usage in order to
  /// manipulate the frequency and specificity at which `transitions`
  /// (state changes) occur.
  ///
  /// For example, if you want to debounce outgoing state changes:
  ///
  /// ```dart
  /// @override
  /// Stream<Transition<Event, State>> transformTransitions(
  ///   Stream<Transition<Event, State>> transitions,
  /// ) {
  ///   return transitions.debounceTime(Duration(seconds: 1));
  /// }
  /// ```
  Stream<Transition<Event, State>> transformTransitions(
    Stream<Transition<Event, State>> transitions,
  ) {
    return transitions;
  }

  /// Called whenever a [transition] occurs with the given [transition].
  /// A [transition] occurs when a new `event` is [add]ed and [mapEventToState]
  /// executed.
  /// [onTransition] is called before a [Bloc]'s [state] has been updated.
  /// A great spot to add logging/analytics at the individual [Bloc] level.
  ///
  /// **Note: `super.onTransition` should always be called first.**
  /// ```dart
  /// @override
  /// void onTransition(Transition<Event, State> transition) {
  ///   // Always call super.onTransition with the current transition
  ///   super.onTransition(transition);
  ///
  ///   // Custom onTransition logic goes here
  /// }
  /// ```
  ///
  /// See also:
  ///
  /// * [BlocObserver] for observing [Bloc] behavior globally.
  ///
  @protected
  @mustCallSuper
  void onTransition(Transition<Event, State> transition) {
    // ignore: invalid_use_of_protected_member
    observer.onTransition(this, transition);
  }

  /// Notifies the [Bloc] of an [error] which triggers [onError].
  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    onError(error, stackTrace ?? StackTrace.current);
  }

  /// Called whenever an [error] occurs within a [Bloc].
  /// By default all [error]s will be ignored and [Bloc] functionality will be
  /// unaffected.
  /// A great spot to handle errors at the individual [Bloc] level.
  ///
  /// **Note: `super.onError` should always be called last.**
  /// ```dart
  /// @override
  /// void onError(Object error, StackTrace stackTrace) {
  ///   // Custom onError logic goes here
  ///
  ///   // Always call super.onError with the current error and stackTrace
  ///   super.onError(error, stackTrace);
  /// }
  /// ```
  @protected
  @mustCallSuper
  void onError(Object error, StackTrace stackTrace) {
    // ignore: invalid_use_of_protected_member
    _observer.onError(this, error, stackTrace);
    assert(() {
      throw BlocUnhandledErrorException(this, error, stackTrace);
    }());
  }

  /// Closes the `event` and `state` `Streams`.
  /// This method should be called when a [Bloc] is no longer needed.
  /// Once [close] is called, `events` that are [add]ed will not be
  /// processed.
  /// In addition, if [close] is called while `events` are still being
  /// processed, the [Bloc] will finish processing the pending `events`.
  @override
  @mustCallSuper
  Future<void> close() async {
    // ignore: invalid_use_of_protected_member
    _observer.onClose(this);
    _stateController ??= StreamController<State>.broadcast();
    if (this is! Cubit<State>) {
      await _eventController?.close();
      await _transitionSubscription?.cancel();
    }
    await _stateController!.close();
  }

  void _bindEventsToStates() {
    _eventController ??= StreamController<Event>();
    _transitionSubscription = transformTransitions(
      transformEvents(
        _eventController!.stream,
        (event) => mapEventToState(event).map(
          (nextState) => Transition(
            currentState: state,
            event: event,
            nextState: nextState,
          ),
        ),
      ),
    ).listen(
      (transition) {
        if (transition.nextState == state && _emitted) return;
        try {
          onTransition(transition);
          emit(transition.nextState);
        } catch (error, stackTrace) {
          onError(error, stackTrace);
        }
      },
      onError: onError,
    );
  }
}

/// {@template cubit}
/// A [Cubit] is a type of [Bloc] which has no notion of events
/// and relies on methods to [emit] new states.
///
/// Every [Cubit] requires an initial state which will be the
/// state of the [Cubit] before [emit] has been called.
///
/// The current state of a [Cubit] can be accessed via the [state] getter.
///
/// ```dart
/// class CounterCubit extends Cubit<int> {
///   CounterCubit() : super(0);
///
///   void increment() => emit(state + 1);
/// }
/// ```
///
/// {@endtemplate}
abstract class Cubit<State> extends Bloc<Null, State> {
  /// {@macro cubit}
  Cubit(State initialState) : super(initialState);

  /// Updates the [state] to the provided [state].
  /// [emit] does nothing if the [Cubit] has been closed or if the
  /// [state] being emitted is equal to the current [state].
  ///
  /// To allow for the possibility of notifying listeners of the initial state,
  /// emitting a state which is equal to the initial state is allowed as long
  /// as it is the first thing emitted by the [Cubit].
  @override
  void emit(State state) => super.emit(state);

  @nonVirtual
  @override
  Stream<State> mapEventToState(Null event) {
    throw StateError(
      'mapEventToState should never be invoked on an instance of type Cubit',
    );
  }

  @mustCallSuper
  @override
  void onError(Object error, StackTrace stackTrace) {
    super.onError(error, stackTrace);
  }

  @mustCallSuper
  @override
  void onTransition(Transition<Null, State> transition) {
    super.onTransition(transition);
  }

  @mustCallSuper
  @override
  Future<void> close() => super.close();
}

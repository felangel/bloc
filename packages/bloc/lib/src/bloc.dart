import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

/// Signature for the callbacks registered via `on<E>()`
/// isType allows for type comparisons to support inheritance
/// The handler is an [EventHandler] which is responsible for event processing.
/// The modifier if an [EventModifier] which determines if/how the event is processed.
class _OnEvent<Event, State> {
  const _OnEvent({
    required this.isType,
    required this.handler,
    required this.modifier,
  });

  final bool Function(Event) isType;
  final EventHandler<Event, State> handler;
  final EventModifier<Event> modifier;
}

/// {@template event_modifier}
/// An event modifier which can be used to change
/// how events are processed.
///
/// An [EventModifier] is called when an event of type `E` is added
/// and the modifier can determine if/how the event should be processed
/// based on the event itself and the outstanding events of type `E`.
/// Calling the `next` function signifies that the `event` should be processed.
///
/// **Note**: it is possible to alter the outstanding events by modifying the
/// `events` map.
///
/// By default events are processed concurrently.
///
/// Custom event modifiers can be created like:
///
/// ```dart
/// EventModifier<E> customEventModifier<E>() {
///  return ((event, events, next) { ... });
/// }
/// ```
///
/// See also:
/// * [concurrent]
/// * [restartable]
/// * [drop]
/// * [enqueue]
/// * [keepLatest]
/// * [debounceTime]
/// {@endtemplate}
typedef EventModifier<Event> = FutureOr<void> Function(
  Event event,
  Map<Object, Future<void>> events,
  void Function() next,
);

/// Process events concurrently. This is the default behavior.
EventModifier<E> concurrent<E>() => ((event, events, next) => next());

/// Process events one at a time by maintaining a queue of added events
/// and processing the events sequentially.
///
/// **Note**: there is no event handler overlap and every event is guaranteed
/// to be handled in the order it was received.
EventModifier<E> enqueue<E>() {
  return (event, events, next) async {
    while (events.isNotEmpty) {
      await Future.wait<void>(events.values);
    }
    next();
  };
}

/// Process only one event by cancelling any pending events and
/// processing the new event immediately.
///
/// **Note**: there is no event handler overlap and any currently running tasks
/// will be aborted if a new event is added before a prior one completes.
EventModifier<E> restartable<E>() {
  return (event, events, next) {
    events.clear();
    next();
  };
}

/// Process only one event and drop any new events
/// until the current event is done.
/// Dropped events never trigger the event handler.
EventModifier<E> drop<E>() {
  return (event, events, next) {
    if (events.isEmpty) next();
  };
}

/// Process the current event and enqueue the most recent event
/// once the current event is done. All intermediate events are dropped.
EventModifier<E> keepLatest<E>() {
  return (event, events, next) async {
    if (events.isEmpty) return next();
    final entry = events.entries.first;
    events
      ..clear()
      ..addAll({entry.key: entry.value});
    await entry.value;
    if (events.isEmpty) return next();
  };
}

/// Process only one event at a time dropping all events which
/// are added less than [duration] apart.
///
/// **Note**: `debounceTime` is very useful in cases where the rate
/// of input must be controlled such as type-ahead scenarios.
EventModifier<E> debounceTime<E>(Duration duration) {
  Timer? timer;
  return (event, events, next) {
    timer?.cancel();
    timer = Timer(duration, () {
      if (events.isEmpty) next();
    });
  };
}

/// Signature for the `emit` method is used to emit a new state.
typedef Emit<State> = void Function(State);

/// Signature for a a mapper function which is invoked with a specific [Event].
typedef EventHandler<Event, State> = FutureOr<void> Function(
  Event,
  Emit<State>,
);

/// Signature of the `on` closure used to add event handlers.
typedef On<Event, State> = void Function(Event, void Function(Emit<State>));

/// {@template bloc_unhandled_error_exception}
/// Exception thrown when an unhandled error occurs within a bloc.
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

  /// The bloc in which the unhandled error occurred.
  final BlocBase bloc;

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
abstract class Bloc<Event, State> extends BlocBase<State> {
  /// {@macro bloc}
  Bloc(State initialState) : super(initialState);

  /// The current [BlocObserver] instance.
  static BlocObserver observer = BlocObserver();

  late final _onEventCallbacks = <_OnEvent<Event, State>>{};
  final _pendingEvents = <dynamic, Map<Object, Future<void>>>{};

  /// Notifies the [Bloc] of a new [event]
  /// which triggers any registered handlers.
  /// If [close] has already been called, any subsequent calls to [add] will
  /// be ignored and will not result in any subsequent state changes.
  void add(Event event) {
    if (isClosed) return;
    try {
      onEvent(event);
      _onEvent(event);
    } catch (error, stackTrace) {
      onError(error, stackTrace);
    }
  }

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
  /// * [BlocObserver.onEvent] for observing events globally.
  ///
  @protected
  @mustCallSuper
  void onEvent(Event event) {
    // ignore: invalid_use_of_protected_member
    observer.onEvent(this, event);
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
  @override
  void emit(State state) => super.emit(state);

  /// Register event handler for an event [E].
  /// There should only ever be one event handler for each event.
  ///
  /// * A [StateError] will be thrown if there are multiple event handlers
  /// registered for the same type [E].
  ///
  /// * A [StateError] will be thrown if there is a missing event handler for
  /// an event of type [E] when [add] is called.
  ///
  /// By default, the [concurrent] modifier will be used.
  FutureOr<void> on<E extends Event>(
    EventHandler<E, State> handler, [
    EventModifier<E>? modifier,
  ]) {
    modifier = modifier ?? concurrent<E>();
    final onEvent = _OnEvent<E, State>(
      isType: (Event e) => e is E,
      handler: handler,
      modifier: modifier,
    );
    final callbacks = _onEventCallbacks.where(
      (e) => e.runtimeType == onEvent.runtimeType,
    );
    if (callbacks.isNotEmpty) {
      throw StateError(
        'on<$E> was called multiple times. '
        'There should only be a single event handler for each event.',
      );
    }
    _onEventCallbacks.add(onEvent);
  }

  /// Called whenever a [transition] occurs with the given [transition].
  /// A [transition] occurs when a new `event` is [add]ed
  /// and a new state is [emit] is called with a new [state].
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
  /// * [BlocObserver.onTransition] for observing transitions globally.
  ///
  @protected
  @mustCallSuper
  void onTransition(Transition<Event, State> transition) {
    // ignore: invalid_use_of_protected_member
    Bloc.observer.onTransition(this, transition);
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
    try {
      final futures = () => _pendingEvents.values.fold<Iterable<Future>>(
            [],
            (prev, element) => <Future>[...prev, ...element.values],
          );
      while (futures().isNotEmpty) {
        await Future.wait<void>(futures());
      }
    } catch (_) {}
    await super.close();
  }

  Future<void> _onEvent(Event event) async {
    final callbacks = _onEventCallbacks.where((e) => e.isType(event));

    if (callbacks.isEmpty) {
      final eventType = event.runtimeType;
      throw StateError(
        '''add<$eventType> was called without a registered event handler.\n'''
        '''Make sure to register a handler via on<$eventType>((event, emit) {...})''',
      );
    }

    for (final dynamic onEvent in callbacks) {
      void next() async {
        final key = Object();
        try {
          final eventHandler = () async {
            await onEvent.handler(event, (State state) {
              if (_pendingEvents[onEvent]?[key] == null) return;
              onTransition(Transition(
                currentState: this.state,
                event: event,
                nextState: state,
              ));
              emit(state);
            });
          };

          final placeholder = Future<void>.value();
          _pendingEvents.putIfAbsent(onEvent, () => {key: placeholder});
          _pendingEvents[onEvent]![key] = placeholder;
          _pendingEvents[onEvent]![key] = eventHandler();
          await _pendingEvents[onEvent]![key];
        } catch (error, stackTrace) {
          onError(error, stackTrace);
        }
        _unawaited(_pendingEvents[onEvent]!.remove(key));
      }

      _pendingEvents.putIfAbsent(onEvent, () => {});
      final events = _pendingEvents[onEvent]!;
      onEvent.modifier(event, events, next);
    }
  }
}

/// {@template cubit}
/// A [Cubit] is similar to [Bloc] but has no notion of events
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
abstract class Cubit<State> extends BlocBase<State> {
  /// {@macro cubit}
  Cubit(State initialState) : super(initialState);
}

/// {@template bloc_stream}
/// An interface for the core functionality implemented by
/// both [Bloc] and [Cubit].
/// {@endtemplate}
abstract class BlocBase<State> {
  /// {@macro bloc_stream}
  BlocBase(this._state) {
    // ignore: invalid_use_of_protected_member
    Bloc.observer.onCreate(this);
  }

  StreamController<State>? __stateController;
  StreamController<State> get _stateController {
    return __stateController ??= StreamController<State>.broadcast();
  }

  State _state;

  bool _emitted = false;

  /// The current [state].
  State get state => _state;

  /// The current state stream.
  Stream<State> get stream => transformStates(_stateController.stream);

  /// Updates the [state] to the provided [state].
  /// [emit] does nothing if the instance has been closed or if the
  /// [state] being emitted is equal to the current [state].
  ///
  /// To allow for the possibility of notifying listeners of the initial state,
  /// emitting a state which is equal to the initial state is allowed as long
  /// as it is the first thing emitted by the instance.
  void emit(State state) {
    if (isClosed) return;
    if (state == _state && _emitted) return;
    onChange(Change<State>(currentState: this.state, nextState: state));
    _state = state;
    _stateController.add(_state);
    _emitted = true;
  }

  /// Transforms the `Stream<States>` into a new `Stream<State>`.
  /// By default [transformStates] returns
  /// the incoming `Stream<State>`.
  /// You can override [transformStates] for advanced usage in order to
  /// manipulate the frequency and specificity at which
  /// state changes occur.
  ///
  /// For example, if you want to debounce outgoing state changes:
  ///
  /// ```dart
  /// @override
  /// Stream<State> transformStates(Stream<State> states) {
  ///   return states.debounceTime(const Duration(seconds: 1));
  /// }
  /// ```
  Stream<State> transformStates(Stream<State> states) => states;

  /// Called whenever a [change] occurs with the given [change].
  /// A [change] occurs when a new `state` is emitted.
  /// [onChange] is called before the `state` of the `cubit` is updated.
  /// [onChange] is a great spot to add logging/analytics for a specific `cubit`.
  ///
  /// **Note: `super.onChange` should always be called first.**
  /// ```dart
  /// @override
  /// void onChange(Change change) {
  ///   // Always call super.onChange with the current change
  ///   super.onChange(change);
  ///
  ///   // Custom onChange logic goes here
  /// }
  /// ```
  ///
  /// See also:
  ///
  /// * [BlocObserver] for observing [Cubit] behavior globally.
  @mustCallSuper
  void onChange(Change<State> change) {
    // ignore: invalid_use_of_protected_member
    Bloc.observer.onChange(this, change);
  }

  /// Reports an [error] which triggers [onError] with an optional [StackTrace].
  @mustCallSuper
  void addError(Object error, [StackTrace? stackTrace]) {
    onError(error, stackTrace ?? StackTrace.current);
  }

  /// Called whenever an [error] occurs and notifies [BlocObserver.onError].
  ///
  /// In debug mode, [onError] throws a [BlocUnhandledErrorException] for
  /// improved visibility.
  ///
  /// In release mode, [onError] does not throw and will instead only report
  /// the error to [BlocObserver.onError].
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
    Bloc.observer.onError(this, error, stackTrace);
    assert(() {
      throw BlocUnhandledErrorException(this, error, stackTrace);
    }());
  }

  /// Closes the instance.
  /// This method should be called when the instance is no longer needed.
  /// Once [close] is called, the instance can no longer be used.
  @mustCallSuper
  Future<void> close() async {
    _isClosed = true;
    // ignore: invalid_use_of_protected_member
    Bloc.observer.onClose(this);
    await _stateController.close();
  }

  bool _isClosed = false;

  /// Whether the bloc is closed.
  bool get isClosed => _isClosed;
}

void _unawaited(Future<void>? future) {}

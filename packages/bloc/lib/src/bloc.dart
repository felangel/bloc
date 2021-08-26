import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

/// {@template emitter}
/// Base interface for emitting states in response to events.
/// {@endtemplate}
abstract class Emitter<State> {
  /// Subscribes to the provided [stream] and invokes the [onData] callback
  /// when the [stream] emits new data.
  ///
  /// [listen] completes when the event handler is cancelled or when
  /// the provided [stream] has ended.
  Future<void> listen<T>(Stream<T> stream, void Function(T) onData);

  // Subscribes to the provided [stream] and invokes the [onData] callback
  /// when the [stream] emits new data and the result of [onData] is emitted.
  ///
  /// [forEach] completes when the event handler is cancelled or when
  /// the provided [stream] has ended.
  Future<void> forEach<T>(
    Stream<T> stream,
    FutureOr<State> Function(T) onData,
  );

  /// Emits the provided [state].
  void call(State state);
}

/// Docs
typedef EventHandler<Event, State> = FutureOr<void> Function(
  Event,
  Emitter<State>,
);

/// Docs
typedef Convert<Event> = Stream<Event> Function(Event);

/// Docs
typedef EventTransformer<Event> = Stream<Event> Function(
  Stream<Event>,
  Convert<Event>,
);

/// Docs
EventTransformer<Event> enqueue<Event>() {
  return (Stream<Event> events, Convert<Event> convert) {
    return events.asyncExpand(convert);
  };
}

/// Docs
EventTransformer<Event> concurrent<Event>() {
  return (Stream<Event> events, Convert<Event> convert) {
    return events.flatMap(convert);
  };
}

/// Docs
EventTransformer<Event> restartable<Event>() {
  return (Stream<Event> events, Convert<Event> convert) {
    return events.switchMap(convert);
  };
}

/// Docs
EventTransformer<Event> drop<Event>() {
  return (Stream<Event> events, Convert<Event> convert) {
    return events.exhaustMap(convert);
  };
}

class _Emitter<State> implements Emitter<State> {
  _Emitter(this._emit);
  final void Function(State) _emit;

  final _completer = Completer<void>();
  final _disposables = <FutureOr<void> Function()>[];

  @override
  Future<void> listen<T>(Stream<T> stream, void Function(T) onData) async {
    final completer = Completer<void>();
    final subscription = stream.listen(onData, onDone: completer.complete);
    _disposables.add(subscription.cancel);
    return Future.any([future, completer.future]);
  }

  @override
  Future<void> forEach<T>(
    Stream<T> stream,
    FutureOr<State> Function(T) onData,
  ) {
    return listen<T>(stream, (x) async => _emit(await onData(x)));
  }

  @override
  void call(State state) => _emit(state);

  void cancel() {
    if (_disposables.isNotEmpty) {
      for (final dispose in _disposables) dispose();
      _disposables.clear();
      if (isCompleted) return;
      _completer.complete();
    }
  }

  Future<void> get future => _completer.future;

  bool get isCompleted => _completer.isCompleted;
}

class _HandlerTest {
  const _HandlerTest({required this.test, required this.type});
  final bool Function(dynamic) test;
  final Type type;
}

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

  final _eventController = StreamController<Event>.broadcast(sync: true);
  final _subscriptions = <StreamSubscription<Event>>[];
  final _handlerTests = <_HandlerTest>[];
  final _emitters = <_Emitter>[];

  /// Notifies the [Bloc] of a new [event]
  /// which triggers any registered handlers.
  /// If [close] has already been called, any subsequent calls to [add] will
  /// be ignored and will not result in any subsequent state changes.
  void add(Event event) {
    if (_eventController.isClosed) return;

    assert(() {
      final handlerExists = _handlerTests.any((handler) => handler.test(event));
      if (!handlerExists) {
        final eventType = event.runtimeType;
        throw StateError(
          '''add($eventType) was called without a registered event handler.\n'''
          '''Make sure to register a handler via on<$eventType>((event, emit) {...})''',
        );
      }
      return true;
    }());

    try {
      onEvent(event);
      _eventController.add(event);
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
  /// A bloc's state should only be updated by emitting a new `state`
  /// from an [EventHandler] (in response to an event).
  /// {@endtemplate}
  @internal
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
  void on<E extends Event>(
    EventHandler<E, State> handler, [
    EventTransformer<Event>? transform,
  ]) {
    assert(() {
      final handlerExists = _handlerTests.any((handler) => handler.type == E);
      if (handlerExists) {
        throw StateError(
          'on<$E> was called multiple times. '
          'There should only be a single event handler for each event.',
        );
      }
      return true;
    }());

    _handlerTests.add(_HandlerTest(test: (dynamic e) => e is E, type: E));
    final subscription = (transform ?? concurrent())(
      _eventController.stream.where((event) => event is E),
      (event) async* {
        var cancelled = false;

        _Emitter<State>? emitter;
        Stream<Event> processEvent() async* {
          emitter = _Emitter((State state) {
            if (cancelled) return;
            if (emitter!.isCompleted) return;
            if (this.state == state && _emitted) return;
            onTransition(Transition(
              currentState: this.state,
              event: event,
              nextState: state,
            ));
            emit(state);
          });

          try {
            _emitters.add(emitter!);
            await (handler as dynamic)(event, emitter);
          } catch (error, stackTrace) {
            onError(error, stackTrace);
          } finally {
            emitter?.cancel();
            _emitters.remove(emitter);
          }
        }

        yield* processEvent().doOnCancel(() {
          cancelled = true;
          emitter?.cancel();
          _emitters.remove(emitter);
        });
      },
    ).listen(null);
    _subscriptions.add(subscription);
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
    await _eventController.close();
    for (final emitter in _emitters) emitter.cancel();
    await Future.wait<void>(_emitters.map((e) => e._completer.future));
    await Future.wait<void>(_subscriptions.map((s) => s.cancel()));
    await super.close();
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
  Stream<State> get stream => _stateController.stream;

  /// Whether the bloc is closed.
  ///
  /// A bloc is considered closed once [close] is called.
  /// Subsequent state changes cannot occur within a closed bloc.
  bool get isClosed => _stateController.isClosed;

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
    // ignore: invalid_use_of_protected_member
    Bloc.observer.onClose(this);
    await _stateController.close();
  }
}

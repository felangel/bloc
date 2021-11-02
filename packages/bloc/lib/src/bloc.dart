import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

/// {@template emitter}
/// An [Emitter] is a class which is capable of emitting new states.
///
/// See also:
///
/// * [EventHandler] which has access to an [Emitter].
///
/// {@endtemplate}
abstract class Emitter<State> {
  /// Subscribes to the provided [stream] and invokes the [onData] callback
  /// when the [stream] emits new data.
  ///
  /// [onEach] completes when the event handler is cancelled or when
  /// the provided [stream] has ended.
  ///
  /// If [onError] is omitted, any errors on this [stream]
  /// are considered unhandled, and will be thrown by [onEach].
  /// As a result, the internal subscription to the [stream] will be canceled.
  ///
  /// If [onError] is provided, any errors on this [stream] will be passed on to
  /// [onError] and will not result in unhandled exceptions or cancelations to
  /// the internal stream subscription.
  ///
  /// **Note**: The stack trace argument may be [StackTrace.empty]
  /// if the [stream] received an error without a stack trace.
  Future<void> onEach<T>(
    Stream<T> stream, {
    required void Function(T data) onData,
    void Function(Object error, StackTrace stackTrace)? onError,
  });

  // Subscribes to the provided [stream] and invokes the [onData] callback
  /// when the [stream] emits new data and the result of [onData] is emitted.
  ///
  /// [forEach] completes when the event handler is cancelled or when
  /// the provided [stream] has ended.
  ///
  /// If [onError] is omitted, any errors on this [stream]
  /// are considered unhandled, and will be thrown by [forEach].
  /// As a result, the internal subscription to the [stream] will be canceled.
  ///
  /// If [onError] is provided, any errors on this [stream] will be passed on to
  /// [onError] and will not result in unhandled exceptions or cancelations to
  /// the internal stream subscription.
  ///
  /// **Note**: The stack trace argument may be [StackTrace.empty]
  /// if the [stream] received an error without a stack trace.
  Future<void> forEach<T>(
    Stream<T> stream, {
    required State Function(T data) onData,
    State Function(Object error, StackTrace stackTrace)? onError,
  });

  /// Whether the [EventHandler] associated with this [Emitter]
  /// has been completed or canceled.
  bool get isDone;

  /// Emits the provided [state].
  void call(State state);
}

/// An event handler is responsible for reacting to an incoming [Event]
/// and can emit zero or more states via the [Emitter].
typedef EventHandler<Event, State> = FutureOr<void> Function(
  Event event,
  Emitter<State> emit,
);

/// Signature for a function which converts an incoming event
/// into an outbound stream of events.
/// Used when defining custom [EventTransformer]s.
typedef EventMapper<Event> = Stream<Event> Function(Event event);

/// Used to change how events are processed.
/// By default events are processed concurrently.
typedef EventTransformer<Event> = Stream<Event> Function(
  Stream<Event> events,
  EventMapper<Event> mapper,
);

class _Emitter<State> implements Emitter<State> {
  _Emitter(this._emit);

  final void Function(State state) _emit;
  final _completer = Completer<void>();
  final _disposables = <FutureOr<void> Function()>[];

  var _isCanceled = false;
  var _isCompleted = false;

  @override
  Future<void> onEach<T>(
    Stream<T> stream, {
    required void Function(T data) onData,
    void Function(Object error, StackTrace stackTrace)? onError,
  }) async {
    final completer = Completer<void>();
    final subscription = stream.listen(
      onData,
      onDone: completer.complete,
      onError: onError ?? completer.completeError,
      cancelOnError: onError == null,
    );
    _disposables.add(subscription.cancel);
    return Future.any([future, completer.future]).whenComplete(() {
      subscription.cancel();
      _disposables.remove(subscription.cancel);
    });
  }

  @override
  Future<void> forEach<T>(
    Stream<T> stream, {
    required State Function(T data) onData,
    State Function(Object error, StackTrace stackTrace)? onError,
  }) {
    return onEach<T>(
      stream,
      onData: (data) => call(onData(data)),
      onError: onError != null
          ? (Object error, StackTrace stackTrace) {
              call(onError(error, stackTrace));
            }
          : null,
    );
  }

  @override
  void call(State state) {
    assert(
      !_isCompleted,
      '''\n\n
emit was called after an event handler completed normally.
This is usually due to an unawaited future in an event handler.
Please make sure to await all asynchronous operations with event handlers
and use emit.isDone after asynchronous operations before calling emit() to
ensure the event handler has not completed.

  **BAD**
  on<Event>((event, emit) {
    future.whenComplete(() => emit(...));
  });

  **GOOD**
  on<Event>((event, emit) async {
    await future.whenComplete(() => emit(...));
  });
''',
    );
    if (!_isCanceled) _emit(state);
  }

  @override
  bool get isDone => _isCanceled || _isCompleted;

  void cancel() {
    if (isDone) return;
    _isCanceled = true;
    _close();
  }

  void complete() {
    if (isDone) return;
    assert(
      _disposables.isEmpty,
      '''\n\n
An event handler completed but left pending subscriptions behind.
This is most likely due to an unawaited emit.forEach or emit.onEach. 
Please make sure to await all asynchronous operations within event handlers.

  **BAD**
  on<Event>((event, emit) {
    emit.forEach(...);
  });  
  
  **GOOD**
  on<Event>((event, emit) async {
    await emit.forEach(...);
  });

  **GOOD**
  on<Event>((event, emit) {
    return emit.forEach(...);
  });

  **GOOD**
  on<Event>((event, emit) => emit.forEach(...));

''',
    );
    _isCompleted = true;
    _close();
  }

  void _close() {
    for (final disposable in _disposables) disposable.call();
    _disposables.clear();
    if (!_completer.isCompleted) _completer.complete();
  }

  Future<void> get future => _completer.future;
}

class _Handler {
  const _Handler({required this.isType, required this.type});
  final bool Function(dynamic value) isType;
  final Type type;
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

  /// The default [EventTransformer] used for all event handlers.
  /// By default all events are processed concurrently.
  ///
  /// If a custom transformer is specified for a particular event handler,
  /// it will take precendence over the global transformer.
  ///
  /// See also:
  ///
  /// * [package:bloc_concurrency](https://pub.dev/packages/bloc_concurrency) for an
  /// opinionated set of event transformers.
  ///
  static EventTransformer<dynamic> transformer = (events, mapper) {
    return events
        .map(mapper)
        .transform<dynamic>(const _FlatMapStreamTransformer<dynamic>());
  };

  final _eventController = StreamController<Event>.broadcast();
  final _subscriptions = <StreamSubscription<dynamic>>[];
  final _handlers = <_Handler>[];
  final _emitters = <_Emitter>[];

  /// Notifies the [Bloc] of a new [event] which triggers
  /// all corresponding [EventHandler] instances.
  ///
  /// * A [StateError] will be thrown if there is no event handler
  /// registered for the incoming [event].
  ///
  /// * A [StateError] will be thrown if the bloc is closed and the
  /// [event] will not be processed.
  void add(Event event) {
    assert(() {
      final handlerExists = _handlers.any((handler) => handler.isType(event));
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
      rethrow;
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
  /// **[emit] is only for internal use and should never be called directly.
  /// The [Emitter] instance provided to each [EventHandler]
  /// should be used instead.**
  ///
  /// ```dart
  /// class MyBloc extends Bloc<MyEvent, MyState> {
  ///   MyBloc() : super(MyInitialState()) {
  ///     on<MyEvent>((event, emit) {
  ///       // use `emit` to update the state.
  ///       emit(MyOtherState());
  ///     });
  ///   }
  /// }
  /// ```
  ///
  /// Updates the state of the bloc to the provided [state].
  /// A bloc's state should only be updated by `emitting` a new `state`
  /// from an [EventHandler] in response to an incoming event.
  /// {@endtemplate}
  @internal
  @override
  void emit(State state) => super.emit(state);

  /// Register event handler for an event of type `E`.
  /// There should only ever be one event handler per event type `E`.
  ///
  /// ```dart
  /// abstract class CounterEvent {}
  /// class Increment extends CounterEvent {}
  ///
  /// class CounterBloc extends Bloc<CounterEvent, int> {
  ///   CounterBloc() : super(0) {
  ///     on<Increment>((event, emit) => emit(state + 1));
  ///   }
  /// }
  /// ```
  ///
  /// * A [StateError] will be thrown if there are multiple event handlers
  /// registered for the same type `E`.
  ///
  /// By default, events will be processed concurrently.
  ///
  /// See also:
  ///
  /// * [EventTransformer] to customize how events are processed.
  /// * [package:bloc_concurrency](https://pub.dev/packages/bloc_concurrency) for an
  /// opinionated set of event transformers.
  ///
  void on<E extends Event>(
    EventHandler<E, State> handler, {
    EventTransformer<E>? transformer,
  }) {
    assert(() {
      final handlerExists = _handlers.any((handler) => handler.type == E);
      if (handlerExists) {
        throw StateError(
          'on<$E> was called multiple times. '
          'There should only be a single event handler per event type.',
        );
      }
      _handlers.add(_Handler(isType: (dynamic e) => e is E, type: E));
      return true;
    }());

    final _transformer = transformer ?? Bloc.transformer;
    final subscription = _transformer(
      _eventController.stream.where((event) => event is E).cast<E>(),
      (dynamic event) {
        void onEmit(State state) {
          if (isClosed) return;
          if (this.state == state && _emitted) return;
          onTransition(Transition(
            currentState: this.state,
            event: event as E,
            nextState: state,
          ));
          emit(state);
        }

        final emitter = _Emitter(onEmit);
        final controller = StreamController<E>.broadcast(
          sync: true,
          onCancel: emitter.cancel,
        );

        void handleEvent() async {
          void onDone() {
            emitter.complete();
            _emitters.remove(emitter);
            if (!controller.isClosed) controller.close();
          }

          try {
            _emitters.add(emitter);
            await handler(event as E, emitter);
          } catch (error, stackTrace) {
            onError(error, stackTrace);
            rethrow;
          } finally {
            onDone();
          }
        }

        handleEvent();
        return controller.stream;
      },
    ).listen(null);
    _subscriptions.add(subscription);
  }

  /// Called whenever a [transition] occurs with the given [transition].
  /// A [transition] occurs when a new `event` is added
  /// and a new state is `emitted` from a corresponding [EventHandler].
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
    await Future.wait<void>(_emitters.map((e) => e.future));
    await Future.wait<void>(_subscriptions.map((s) => s.cancel()));
    return super.close();
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
  /// [emit] does nothing if the [state] being emitted
  /// is equal to the current [state].
  ///
  /// To allow for the possibility of notifying listeners of the initial state,
  /// emitting a state which is equal to the initial state is allowed as long
  /// as it is the first thing emitted by the instance.
  ///
  /// * Throws a [StateError] if the bloc is closed.
  @protected
  void emit(State state) {
    try {
      if (isClosed) {
        throw StateError('Cannot emit new states after calling close');
      }
      if (state == _state && _emitted) return;
      onChange(Change<State>(currentState: this.state, nextState: state));
      _state = state;
      _stateController.add(_state);
      _emitted = true;
    } catch (error, stackTrace) {
      onError(error, stackTrace);
      rethrow;
    }
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
  ///
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
  /// **Note: `super.onError` should always be called last.**
  ///
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

class _FlatMapStreamTransformer<T> extends StreamTransformerBase<Stream<T>, T> {
  const _FlatMapStreamTransformer();

  @override
  Stream<T> bind(Stream<Stream<T>> stream) {
    final controller = StreamController<T>.broadcast(sync: true);

    controller.onListen = () {
      final subscriptions = <StreamSubscription<dynamic>>[];

      final outerSubscription = stream.listen(
        (inner) {
          final subscription = inner.listen(
            controller.add,
            onError: controller.addError,
          );

          subscription.onDone(() {
            subscriptions.remove(subscription);
            if (subscriptions.isEmpty) controller.close();
          });

          subscriptions.add(subscription);
        },
        onError: controller.addError,
      );

      outerSubscription.onDone(() {
        subscriptions.remove(outerSubscription);
        if (subscriptions.isEmpty) controller.close();
      });

      subscriptions.add(outerSubscription);

      controller.onCancel = () {
        if (subscriptions.isEmpty) return null;
        final cancels = [for (final s in subscriptions) s.cancel()];
        return Future.wait(cancels).then((_) {});
      };
    };

    return controller.stream;
  }
}

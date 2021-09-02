import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

/// {@template emitter}
/// Base interface for emitting states in response to events.
/// {@endtemplate}
abstract class Emitter<State> {
  /// Subscribes to the provided [stream] and invokes the [onData] callback
  /// when the [stream] emits new data.
  ///
  /// [onEach] completes when the event handler is cancelled or when
  /// the provided [stream] has ended.
  Future<void> onEach<T>(Stream<T> stream, void Function(T) onData);

  // Subscribes to the provided [stream] and invokes the [onData] callback
  /// when the [stream] emits new data and the result of [onData] is emitted.
  ///
  /// [forEach] completes when the event handler is cancelled or when
  /// the provided [stream] has ended.
  Future<void> forEach<T>(
    Stream<T> stream,
    FutureOr<State> Function(T) onData,
  );

  /// Whether the [EventHandler] associated with this [Emitter]
  /// has been canceled.
  bool get isCanceled;

  /// Emits the provided [state].
  void call(State state);
}

/// An event handler is responsible for reacting to an incoming [Event]
/// and can emit zero or more states via the [Emitter].
typedef EventHandler<Event, State> = FutureOr<void> Function(
  Event,
  Emitter<State>,
);

/// Signature for a function which converts an incoming event
/// into an outbound stream of events.
/// Used when defining custom [EventTransformer]s.
typedef EventMapper<Event> = Stream<Event> Function(Event);

/// Used to change how events are processed.
/// By default events are processed concurrently.
///
/// See also:
///
/// * [concurrent]
/// * [droppable]
/// * [restartable]
/// * [sequential]
typedef EventTransformer<Event> = Stream<Event> Function(
  Stream<Event>,
  EventMapper<Event>,
);

/// Process events concurrently. This is the default behavior.
///
/// **Note**: there may be event handler overlap and state changes will occur
/// as soon as they are emitted. This means that states may be emitted in
/// an order that does not match the order in which the corresponding events
/// were added.
EventTransformer<Event> concurrent<Event>() {
  return (events, mapper) => events.flatMap(mapper);
}

/// Process events one at a time by maintaining a queue of added events
/// and processing the events sequentially.
///
/// **Note**: there is no event handler overlap and every event is guaranteed
/// to be handled in the order it was received.
EventTransformer<Event> sequential<Event>() {
  return (events, mapper) => events.asyncExpand(mapper);
}

/// Process only one event by cancelling any pending events and
/// processing the new event immediately.
///
/// Avoid using [restartable] if you expect an event to have
/// immediate results -- it should only be used with asynchronous APIs.
///
/// **Note**: there is no event handler overlap and any currently running tasks
/// will be aborted if a new event is added before a prior one completes.
EventTransformer<Event> restartable<Event>() {
  return (events, mapper) => events.switchMap(mapper);
}

/// Process only one event and ignore (drop) any new events
/// until the current event is done.
///
/// **Note**: dropped events never trigger the event handler.
EventTransformer<Event> droppable<Event>() {
  return (events, mapper) => events.exhaustMap(mapper);
}

class _Emitter<State> implements Emitter<State> {
  _Emitter(this._emit);
  final void Function(State) _emit;

  final _completer = Completer<void>();
  final _disposables = <FutureOr<void> Function()>[];

  @override
  Future<void> onEach<T>(Stream<T> stream, void Function(T) onData) async {
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
    return onEach<T>(stream, (data) async => _emit(await onData(data)));
  }

  @override
  void call(State state) => _emit(state);

  @override
  bool get isCanceled => _completer.isCompleted;

  void cancel() {
    for (final dispose in _disposables) dispose();
    _disposables.clear();
    if (!isCanceled) _completer.complete();
  }

  Future<void> get future => _completer.future;
}

class _Handler {
  const _Handler({required this.isType, required this.type});
  final bool Function(dynamic) isType;
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

  final _eventController = StreamController<Event>.broadcast();
  final _subscriptions = <StreamSubscription<Event>>[];
  final _handlers = <_Handler>[];
  final _emitters = <_Emitter>[];

  /// Notifies the [Bloc] of a new [event]
  /// which triggers any registered handlers.
  /// If [close] has already been called, any subsequent calls to [add] will
  /// be ignored and will not result in any subsequent state changes.
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

    if (_eventController.isClosed) return;

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

  /// Register event handler for an event of type [E].
  /// There should only ever be one event handler per event type [E].
  ///
  /// * A [StateError] will be thrown if there are multiple event handlers
  /// registered for the same type [E].
  ///
  /// * A [StateError] will be thrown if there is a missing event handler for
  /// an event of type [E] when [add] is called.
  ///
  /// By default, events will be processed concurrently.
  ///
  /// See also:
  ///
  /// * [EventTransformer] to customize how events are processed.
  void on<E extends Event>(
    EventHandler<E, State> handler, {
    EventTransformer<Event>? transformer,
  }) {
    assert(() {
      final handlerExists = _handlers.any((handler) => handler.type == E);
      if (handlerExists) {
        throw StateError(
          'on<$E> was called multiple times. '
          'There should only be a single event handler for each event.',
        );
      }
      _handlers.add(_Handler(isType: (dynamic e) => e is E, type: E));
      return true;
    }());

    final subscription = (transformer ?? concurrent())(
      _eventController.stream.where((event) => event is E),
      (event) async* {
        void onDone(_Emitter<State> emitter) {
          emitter.cancel();
          _emitters.remove(emitter);
        }

        void onEmit(State state, _Emitter<State> emitter) {
          if (isClosed) return;
          if (emitter.isCanceled) return;
          if (this.state == state && _emitted) return;
          onTransition(Transition(
            currentState: this.state,
            event: event,
            nextState: state,
          ));
          emit(state);
        }

        Stream<Event> handleEvent(_Emitter<State> emitter) async* {
          try {
            _emitters.add(emitter);
            await (handler)(event as E, emitter);
          } catch (error, stackTrace) {
            onError(error, stackTrace);
          } finally {
            onDone(emitter);
          }
        }

        late final _Emitter<State> emitter;
        emitter = _Emitter((state) => onEmit(state, emitter));
        yield* handleEvent(emitter).doOnCancel(() => onDone(emitter));
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

extension _StreamX<T> on Stream<T> {
  Stream<T> flatMap(EventMapper<T> mapper) {
    return map(mapper).transform(_FlatMapStreamTransformer<T>());
  }

  Stream<T> switchMap(EventMapper<T> mapper) {
    return map(mapper).transform(_SwitchMapStreamTransformer<T>());
  }

  Stream<T> exhaustMap(EventMapper<T> mapper) {
    return transform(_ExhaustMapStreamTransformer(mapper));
  }

  Stream<T> doOnCancel(void Function() onCancel) {
    return transform(_DoOnCancelStreamTransformer(onCancel));
  }
}

class _DoOnCancelStreamTransformer<T> extends StreamTransformerBase<T, T> {
  const _DoOnCancelStreamTransformer(this.onCancel);

  final void Function() onCancel;

  @override
  Stream<T> bind(Stream<T> stream) {
    late StreamSubscription<T> subscription;
    final controller = StreamController<T>(
      onCancel: () {
        onCancel();
        return subscription.cancel();
      },
      sync: true,
    );

    subscription = stream.listen(
      controller.add,
      onError: controller.addError,
      onDone: controller.close,
    );

    return controller.stream;
  }
}

class _ExhaustMapStreamTransformer<T> extends StreamTransformerBase<T, T> {
  _ExhaustMapStreamTransformer(this.mapper);

  final EventMapper<T> mapper;

  @override
  Stream<T> bind(Stream<T> stream) {
    late StreamSubscription<T> subscription;
    StreamSubscription<T>? mappedSubscription;

    final controller = StreamController<T>(
      onCancel: () async {
        await mappedSubscription?.cancel();
        return subscription.cancel();
      },
      sync: true,
    );

    subscription = stream.listen(
      (data) {
        if (mappedSubscription != null) return;
        final Stream<T> mappedStream;

        mappedStream = mapper(data);
        mappedSubscription = mappedStream.listen(
          controller.add,
          onError: controller.addError,
          onDone: () => mappedSubscription = null,
        );
      },
      onError: controller.addError,
      onDone: () => mappedSubscription ?? controller.close(),
    );

    return controller.stream;
  }
}

class _SwitchMapStreamTransformer<T>
    extends StreamTransformerBase<Stream<T>, T> {
  const _SwitchMapStreamTransformer();

  @override
  Stream<T> bind(Stream<Stream<T>> stream) {
    final controller = StreamController<T>.broadcast(sync: true);

    controller.onListen = () {
      StreamSubscription<T>? innerSubscription;

      final outerSubscription = stream.listen(
        (innerStream) {
          innerSubscription?.cancel();
          innerSubscription = innerStream.listen(
            controller.add,
            onError: controller.addError,
            onDone: () => innerSubscription = null,
          );
        },
        onError: controller.addError,
        onDone: () {
          if (innerSubscription == null) controller.close();
        },
      );

      controller.onCancel = () {
        final cancels = [
          outerSubscription.cancel(),
          if (innerSubscription != null) innerSubscription!.cancel(),
        ]..removeWhere((Object? f) => f == null);
        if (cancels.isEmpty) return null;
        return Future.wait(cancels).then((_) {});
      };
    };

    return controller.stream;
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
        final cancels = [for (final s in subscriptions) s.cancel()]
          ..removeWhere((Object? f) => f == null);
        return Future.wait(cancels).then((_) {});
      };
    };

    return controller.stream;
  }
}

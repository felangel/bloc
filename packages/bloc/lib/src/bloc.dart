import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'bloc_base.dart';
part 'bloc_overrides.dart';
part 'emitter.dart';

/// An [ErrorSink] that supports adding events.
///
/// Multiple events can be reported to the sink via `add`.
abstract class BlocEventSink<Event extends Object?> implements ErrorSink {
  /// Adds an [event] to the sink.
  ///
  /// Must not be called on a closed sink.
  void add(Event event);
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

/// {@template bloc}
/// Takes a `Stream` of `Events` as input
/// and transforms them into a `Stream` of `States` as output.
/// {@endtemplate}
abstract class Bloc<Event, State> extends BlocBase<State>
    implements BlocEventSink<Event> {
  /// {@macro bloc}
  Bloc(State initialState) : super(initialState);

  /// The current [BlocObserver] instance.
  static BlocObserver observer = const _DefaultBlocObserver();

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
  final _emitters = <_Emitter<dynamic>>[];
  final _eventTransformer =
      // ignore: deprecated_member_use_from_same_package
      BlocOverrides.current?.eventTransformer ?? Bloc.transformer;

  /// Notifies the [Bloc] of a new [event] which triggers
  /// all corresponding [EventHandler] instances.
  ///
  /// * A [StateError] will be thrown if there is no event handler
  /// registered for the incoming [event].
  ///
  /// * A [StateError] will be thrown if the bloc is closed and the
  /// [event] will not be processed.
  @override
  void add(Event event) {
    // ignore: prefer_asserts_with_message
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
    _blocObserver.onEvent(this, event);
  }

  /// {@template emit}
  /// **[emit] is only for internal use and should never be called directly
  /// outside of tests. The [Emitter] instance provided to each [EventHandler]
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
  @visibleForTesting
  @override
  void emit(State state) => super.emit(state);

  /// Register event handler for an event of type `E`.
  /// There should only ever be one event handler per event type `E`.
  ///
  /// ```dart
  /// abstract class CounterEvent {}
  /// class CounterIncrementPressed extends CounterEvent {}
  ///
  /// class CounterBloc extends Bloc<CounterEvent, int> {
  ///   CounterBloc() : super(0) {
  ///     on<CounterIncrementPressed>((event, emit) => emit(state + 1));
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
    // ignore: prefer_asserts_with_message
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

    final subscription = (transformer ?? _eventTransformer)(
      _eventController.stream.where((event) => event is E).cast<E>(),
      (dynamic event) {
        void onEmit(State state) {
          if (isClosed) return;
          if (this.state == state && _emitted) return;
          onTransition(
            Transition(
              currentState: this.state,
              event: event as E,
              nextState: state,
            ),
          );
          emit(state);
        }

        final emitter = _Emitter(onEmit);
        final controller = StreamController<E>.broadcast(
          sync: true,
          onCancel: emitter.cancel,
        );

        Future<void> handleEvent() async {
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
  ///
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
    _blocObserver.onTransition(this, transition);
  }

  /// Closes the `event` and `state` `Streams`.
  /// This method should be called when a [Bloc] is no longer needed.
  /// Once [close] is called, `events` that are [add]ed will not be
  /// processed.
  /// In addition, if [close] is called while `events` are still being
  /// processed, the [Bloc] will finish processing the pending `events`.
  @mustCallSuper
  @override
  Future<void> close() async {
    await _eventController.close();
    for (final emitter in _emitters) {
      emitter.cancel();
    }
    await Future.wait<void>(_emitters.map((e) => e.future));
    await Future.wait<void>(_subscriptions.map((s) => s.cancel()));
    return super.close();
  }
}

class _Handler {
  const _Handler({required this.isType, required this.type});
  final bool Function(dynamic value) isType;
  final Type type;
}

class _DefaultBlocObserver extends BlocObserver {
  const _DefaultBlocObserver();
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

import 'dart:async';

import 'package:cubit/cubit.dart';
import 'package:meta/meta.dart';

import '../bloc.dart';

/// {@template bloc_unhandled_error_exception}
/// Exception thrown in debug mode when an unhandled error occurs within a bloc.
/// {@endtemplate}
class BlocUnhandledErrorException implements Exception {
  /// The [bloc] in which the unhandled error occurred.
  final Bloc bloc;

  /// The unhandled [error] object.
  final Object error;

  /// An optional [stackTrace] which accompanied the error.
  final StackTrace stackTrace;

  /// {@macro bloc_unhandled_error_exception}
  BlocUnhandledErrorException(this.bloc, this.error, [this.stackTrace]);

  @override
  String toString() {
    return 'Unhandled error $error occurred in bloc $bloc.\n'
        '${stackTrace ?? ''}';
  }
}

/// Signature for a mapper function which takes an [Event] as input
/// and outputs a [Stream] of [Transition] objects.
typedef TransitionFunction<Event, State> = Stream<Transition<Event, State>>
    Function(Event);

/// {@template bloc}
/// Takes a `Stream` of `Events` as input
/// and transforms them into a `Stream` of `States` as output.
/// {@endtemplate}
abstract class Bloc<Event, State> extends Cubit<State> implements Sink<Event> {
  final _eventController = StreamController<Event>.broadcast();

  StreamSubscription<Transition<Event, State>> _transitionSubscription;

  /// {@macro bloc}
  Bloc(State state) : super(state) {
    _bindEventsToStates();
  }

  /// Called whenever an [event] is [add]ed to the [bloc].
  /// A great spot to add logging/analytics at the individual [bloc] level.
  ///
  /// **Note: `super.onEvent` should always be called last.**
  /// ```dart
  /// @override
  /// void onEvent(Event event) {
  ///   // Custom onEvent logic goes here
  ///
  ///   // Always call super.onEvent with the current event
  ///   super.onEvent(event);
  /// }
  /// ```
  @mustCallSuper
  void onEvent(Event event) {
    BlocSupervisor.delegate.onEvent(this, event);
  }

  /// Called whenever a [transition] occurs with the given [transition].
  /// A [transition] occurs when a new `event` is [add]ed and [mapEventToState]
  /// executed.
  /// [onTransition] is called before a [bloc]'s [state] has been updated.
  /// A great spot to add logging/analytics at the individual [bloc] level.
  ///
  /// **Note: `super.onTransition` should always be called last.**
  /// ```dart
  /// @override
  /// void onTransition(Transition<Event, State> transition) {
  ///   // Custom onTransition logic goes here
  ///
  ///   // Always call super.onTransition with the current transition
  ///   super.onTransition(transition);
  /// }
  /// ```
  @mustCallSuper
  void onTransition(Transition<Event, State> transition) {
    BlocSupervisor.delegate.onTransition(this, transition);
  }

  /// Called whenever an [error] is thrown within [mapEventToState].
  /// By default all [error]s will be ignored and [bloc] functionality will be
  /// unaffected.
  /// The [stackTrace] argument may be `null` if the [state] stream received
  /// an error without a [stackTrace].
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
  @mustCallSuper
  void onError(Object error, StackTrace stackTrace) {
    BlocSupervisor.delegate.onError(this, error, stackTrace);
    assert(() {
      throw BlocUnhandledErrorException(this, error, stackTrace);
    }());
  }

  /// Notifies the [bloc] of a new [event] which triggers [mapEventToState].
  /// If [close] has already been called, any subsequent calls to [add] will
  /// be delegated to the [onError] method which can be overridden at the [bloc]
  /// as well as the [BlocDelegate] level.
  @override
  void add(Event event) {
    try {
      onEvent(event);
      _eventController.add(event);
    } on dynamic catch (error, stackTrace) {
      onError(error, stackTrace);
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
    await _eventController.close();
    await _transitionSubscription?.cancel();
    return super.close();
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
  /// recent [event] you can use `switchMap` instead of `asyncExpand`.
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

  /// Must be implemented when a class extends [bloc].
  /// Takes the incoming [event] as the argument.
  /// [mapEventToState] is called whenever an [event] is [add]ed.
  /// [mapEventToState] must convert that [event] into a new [state]
  /// and return the new [state] in the form of a `Stream<State>`.
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

  void _bindEventsToStates() {
    _transitionSubscription = transformTransitions(
      transformEvents(
        _eventController.stream,
        (event) => mapEventToState(event).map(
          (nextState) => Transition(
            currentState: state,
            event: event,
            nextState: nextState,
          ),
        ),
      ),
    ).listen((transition) {
      if (transition.nextState == state) return;
      try {
        onTransition(transition);
        emit(transition.nextState);
      } on dynamic catch (error, stackTrace) {
        onError(error, stackTrace);
      }
    }, onError: onError);
  }
}

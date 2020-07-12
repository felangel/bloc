import 'dart:async';

import 'package:meta/meta.dart';

import 'bloc.dart';
import 'bloc_observer.dart';
import 'change.dart';

/// {@template cubit_unhandled_error_exception}
/// Exception thrown when an unhandled error occurs within a [Cubit].
///
/// _Note: thrown in debug mode only_
/// {@endtemplate}
class CubitUnhandledErrorException implements Exception {
  /// {@macro cubit_unhandled_error_exception}
  CubitUnhandledErrorException(this.cubit, this.error, [this.stackTrace]);

  /// The [cubit] in which the unhandled error occurred.
  final Cubit cubit;

  /// The unhandled [error] object.
  final Object error;

  /// An optional [stackTrace] which accompanied the error.
  final StackTrace stackTrace;

  @override
  String toString() {
    return 'Unhandled error $error occurred in $cubit.\n'
        '${stackTrace ?? ''}';
  }
}

/// {@template cubit}
/// A [Cubit] is a subset of [Bloc] which has no notion of events
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
abstract class Cubit<State> extends Stream<State> {
  /// {@macro cubit}
  Cubit(this._state);

  /// The current [state].
  State get state => _state;

  BlocObserver get _observer => Bloc.observer;

  final _controller = StreamController<State>.broadcast();

  State _state;

  bool _emitted = false;

  /// {@template emit}
  /// Updates the [state] to the provided [state].
  /// [emit] does nothing if the [Cubit] has been closed or if the
  /// [state] being emitted is equal to the current [state].
  ///
  /// To allow for the possibility of notifying listeners of the initial state,
  /// emitting a state which is equal to the initial state is allowed as long
  /// as it is the first thing emitted by the [Cubit].
  /// {@endtemplate}
  @protected
  void emit(State state) {
    if (_controller.isClosed) return;
    if (state == _state && _emitted) return;
    onChange(Change<State>(currentState: this.state, nextState: state));
    _state = state;
    _controller.add(_state);
    _emitted = true;
  }

  /// Notifies the [Cubit] of an [error] which triggers [onError].
  void addError(Object error, [StackTrace stackTrace]) {
    onError(error, stackTrace);
  }

  /// Called whenever a [change] occurs with the given [change].
  /// A [change] occurs when a new `state` is emitted.
  /// [onChange] is called before the `state` of the `cubit` is updated.
  /// [onChange] is a great spot to add logging/analytics for a specific `cubit`.
  ///
  /// **Note: `super.onChange` should always be called last.**
  /// ```dart
  /// @override
  /// void onChange(Change change) {
  ///   // Custom onChange logic goes here
  ///
  ///   // Always call super.onChange with the current change
  ///   super.onChange(change);
  /// }
  /// ```
  ///
  /// See also:
  ///
  /// * [BlocObserver] for observing [Cubit] behavior globally.
  @mustCallSuper
  void onChange(Change<State> change) {
    // ignore: invalid_use_of_protected_member
    _observer.onChange(this, change);
  }

  /// Called whenever an [error] occurs within a [Cubit].
  /// By default all [error]s will be ignored and [Cubit] functionality will be
  /// unaffected.
  /// The [stackTrace] argument may be `null` if the [state] stream received
  /// an error without a [stackTrace].
  /// A great spot to handle errors at the individual [Cubit] level.
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
      throw CubitUnhandledErrorException(this, error, stackTrace);
    }());
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
    return _controller.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  /// Returns whether the `Stream<State>` is a broadcast stream.
  /// Every [Cubit] is a broadcast stream.
  @override
  bool get isBroadcast => _controller.stream.isBroadcast;

  /// Closes the [Cubit].
  /// When close is called, new states can no longer be emitted.
  /// All data on the stream is discarded and a [Future] is returned
  /// which resolves when it is done or an error occurred.
  @mustCallSuper
  Future<void> close() async {
    await _controller.close();
    await _controller.stream.drain<State>();
  }
}

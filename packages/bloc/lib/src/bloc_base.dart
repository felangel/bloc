part of 'bloc.dart';

/// An object that provides access to a stream of states over time.
abstract class Streamable<State extends Object?> {
  /// The current [stream] of states.
  Stream<State> get stream;
}

/// A [Streamable] that provides synchronous access to the current [state].
abstract class StateStreamable<State> implements Streamable<State> {
  /// The current [state].
  State get state;
}

/// A [StateStreamable] that must be closed when no longer in use.
abstract class StateStreamableSource<State>
    implements StateStreamable<State>, Closable {}

/// An object that must be closed when no longer in use.
abstract class Closable {
  /// Closes the current instance.
  /// The returned future completes when the instance has been closed.
  FutureOr<void> close();

  /// Whether the object is closed.
  ///
  /// An object is considered closed once [close] is called.
  bool get isClosed;
}

/// An object that can emit new states.
// ignore: one_member_abstracts
abstract class Emittable<State extends Object?> {
  /// Emits a new [state].
  void emit(State state);
}

/// A generic destination for errors.
///
/// Multiple errors can be reported to the sink via `addError`.
abstract class ErrorSink implements Closable {
  /// Adds an [error] to the sink with an optional [stackTrace].
  ///
  /// Must not be called on a closed sink.
  void addError(Object error, [StackTrace? stackTrace]);
}

/// {@template bloc_base}
/// An interface for the core functionality implemented by
/// both [Bloc] and [Cubit].
/// {@endtemplate}
abstract class BlocBase<State>
    implements StateStreamableSource<State>, Emittable<State>, ErrorSink {
  /// {@macro bloc_base}
  BlocBase(this._state) {
    // ignore: invalid_use_of_protected_member
    _blocObserver.onCreate(this);
  }

  // ignore: deprecated_member_use_from_same_package
  final _blocObserver = BlocOverrides.current?.blocObserver ?? Bloc.observer;

  late final _stateController = StreamController<State>.broadcast();

  State _state;

  bool _emitted = false;

  @override
  State get state => _state;

  @override
  Stream<State> get stream => _stateController.stream;

  /// Whether the bloc is closed.
  ///
  /// A bloc is considered closed once [close] is called.
  /// Subsequent state changes cannot occur within a closed bloc.
  @override
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
  @visibleForTesting
  @override
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
  @protected
  @mustCallSuper
  void onChange(Change<State> change) {
    // ignore: invalid_use_of_protected_member
    _blocObserver.onChange(this, change);
  }

  /// Reports an [error] which triggers [onError] with an optional [StackTrace].
  @protected
  @mustCallSuper
  @override
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
    _blocObserver.onError(this, error, stackTrace);
  }

  /// Closes the instance.
  /// This method should be called when the instance is no longer needed.
  /// Once [close] is called, the instance can no longer be used.
  @mustCallSuper
  @override
  Future<void> close() async {
    // ignore: invalid_use_of_protected_member
    _blocObserver.onClose(this);
    await _stateController.close();
  }
}

part of 'bloc.dart';

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

  /// Subscribes to the provided [stream] and invokes the [onData] callback
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
  }) {
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
      '''


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
      '''


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
    for (final disposable in _disposables) {
      disposable.call();
    }
    _disposables.clear();
    if (!_completer.isCompleted) _completer.complete();
  }

  Future<void> get future => _completer.future;
}

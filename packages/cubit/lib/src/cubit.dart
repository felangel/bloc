import 'dart:async';

import 'package:meta/meta.dart';

/// {@template cubit}
/// `Stream` which exposes a `state` and
/// can conditionally emit new states asynchronously.
/// {@endtemplate}
abstract class Cubit<T> extends Stream<T> {
  /// {@macro cubit}
  Cubit() {
    _state = initialState;
  }

  /// The initial [state] of the cubit.
  T get initialState;

  /// The current [state] of the cubit
  T get state => _state;

  final _controller = StreamController<T>.broadcast();

  T _state;

  /// Returns a `Future` which will completes when the cubit's
  /// [state] has successfully been updated to the provided [state].
  @protected
  Future<void> emit(T state) async {
    if (_controller.isClosed) return;
    // Wait one tick before updating the internal state.
    // This ensures that the initial state has propagated.
    return Future.delayed(Duration.zero, () {
      _state = state;
      _controller.add(state);
    });
  }

  /// Adds a subscription to the `Stream<T>`.
  /// Returns a [StreamSubscription] which handles events from
  /// the `Stream<T>` using the provided [onData], [onError] and [onDone]
  /// handlers.
  @override
  StreamSubscription<T> listen(
    void Function(T) onData, {
    Function onError,
    void Function() onDone,
    bool cancelOnError,
  }) {
    return _stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  /// Returns whether the `Stream<T>` is a broadcast stream.
  @override
  bool get isBroadcast => _stream.isBroadcast;

  /// Closes the stream
  @mustCallSuper
  Future<void> close() => _controller.close();

  Stream<T> get _stream async* {
    yield state;
    yield* _controller.stream;
  }
}

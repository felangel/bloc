import 'dart:async';

import 'package:meta/meta.dart';

import 'cubit.dart';

/// {@template cubit_stream}
/// A `Stream` which retains the latest `state` and
/// can update its `state` by calling `emit` with a new `state`.
///
/// In most cases, [CubitStream] should only be extended when building
/// functionality that is otherwise incompatible with `Cubit`.
///
/// Every [CubitStream] requires an initial state which will be the
/// state of the [CubitStream] before `emit` has been called.
///
/// See also:
///
/// * [Cubit], a type of [CubitStream] which exposes useful methods
/// for intercepting state changes.
/// {@endtemplate}
abstract class CubitStream<State> extends Stream<State> {
  /// {@macro cubit_stream}
  CubitStream(this._state);

  /// The current [state].
  State get state => _state;

  final _controller = StreamController<State>.broadcast();

  State _state;

  /// {@template emit}
  /// Updates the [state] to the provided [state].
  /// [emit] does nothing if the [CubitStream] has been closed or if the
  /// [state] being emitted is equal to the current [state].
  /// {@endtemplate}
  @protected
  void emit(State state) {
    if (state == _state || _controller.isClosed) return;
    _state = state;
    _controller.add(_state);
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
    return _stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  /// Returns whether the `Stream<State>` is a broadcast stream.
  /// Every [CubitStream] is a broadcast stream.
  @override
  bool get isBroadcast => _controller.stream.isBroadcast;

  /// Closes the [CubitStream].
  /// When close is called, new states can no longer be emitted.
  /// All data on the stream is discarded and a `Future` is returned
  /// which resolves when it is done or an error occurred.
  @mustCallSuper
  Future<void> close() async {
    await _controller.close();
    await _controller.stream.drain<State>();
  }

  Stream<State> get _stream async* {
    yield state;
    yield* _controller.stream;
  }
}

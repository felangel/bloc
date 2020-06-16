import 'dart:async';

import 'package:meta/meta.dart';

/// {@template cubit}
/// A `cubit` is a reimagined [bloc](https://pub.dev/packages/bloc)
/// which removes events and relies on methods to emit new states instead.
///
/// ```dart
/// class CounterCubit extends Cubit<int> {
///   CounterCubit() : super(initialState: 0);
///
///   void increment() => emit(state + 1);
/// }
/// ```
/// {@endtemplate}
abstract class Cubit<T> extends Stream<T> {
  /// {@macro cubit}
  Cubit({@required T initialState}) : _state = initialState;

  /// The current [state] of the cubit.
  T get state => _state;

  final _controller = StreamController<T>.broadcast();

  T _state;

  /// Updates the [state] of the `cubit` to the provided [state].
  /// [emit] does nothing if the `cubit` has been closed.
  @protected
  void emit(T state) async {
    if (state == _state || _controller.isClosed) return;
    _state = state;
    _controller.add(state);
  }

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

  @override
  bool get isBroadcast => _controller.stream.isBroadcast;

  /// Closes the `cubit`.
  @mustCallSuper
  Future<void> close() async {
    await _controller.close();
    await _controller.stream.drain<T>();
  }

  Stream<T> get _stream async* {
    yield state;
    yield* _controller.stream;
  }
}

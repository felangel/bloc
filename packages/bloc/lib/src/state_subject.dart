import 'dart:async';

/// A special StreamController that captures the latest item that has been
/// added to the controller, and emits that as the first item to any new
/// listener.
///
/// It is lightweight analog of BehaviorSubject from RxDart library.
class StateSubject<T> extends Stream<T> implements StreamController<T> {
  _Wrapper<T> _currentValue;
  StreamController<T> _controller;

  StateSubject._(this. _controller, this._currentValue);

  /// Constructs a [StateSubject].
  ///
  /// [seedValue] becomes the current [currentState] and is emitted immediately.
  ///
  /// See also [StreamController.broadcast]
  factory StateSubject.seeded(T seedValue) => StateSubject<T>
      ._(StreamController<T>.broadcast(), _Wrapper.value(seedValue));

  /// Get the latest value emitted by the [StateSubject]
  T get value => _currentValue.value;

  @override
  void add(T event) {
    _currentValue = _Wrapper.value(event);
    _controller.sink.add(event);
  }

  @override
  void addError(Object error, [StackTrace stackTrace]) {
    _currentValue = _Wrapper.error(error, stackTrace);
    _controller.addError(error, stackTrace);
  }

  @override
  Stream<T> get stream => _controller.stream
      .transform(_StartWithStreamTransformer(_currentValue));

  @override
  StreamSubscription<T> listen(void onData(T event),
      {Function onError, void onDone(), bool cancelOnError}) {
    return stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  @override
  Future get done => _controller.done;

  @override
  StreamSink<T> get sink => _controller.sink;

  @override
  bool get isBroadcast => _controller.stream.isBroadcast;

  @override
  bool get isClosed => _controller.isClosed;

  @override
  bool get isPaused => _controller.isPaused;

  @override
  bool get hasListener => _controller.hasListener;

  @override
  ControllerCallback get onListen => _controller.onListen;

  @override
  set onListen(void onListenHandler()) {
    _controller.onListen = onListenHandler;
  }

  @override
  ControllerCancelCallback get onCancel => _controller.onCancel;

  @override
  set onCancel(void Function() onCancelHandler) {
    _controller.onCancel = onCancelHandler;
  }

  @override
  Future close() => _controller.close();

  @override
  ControllerCallback get onPause =>
      throw UnsupportedError('StateSubjects do not support pause callbacks');

  @override
  set onPause(void onPauseHandler()) =>
      throw UnsupportedError('StateSubjects do not support pause callbacks');

  @override
  ControllerCallback get onResume =>
      throw UnsupportedError('StateSubjects do not support resume callbacks');

  @override
  set onResume(void onResumeHandler()) =>
      throw UnsupportedError('StateSubjects do not support resume callbacks');

  @override
  Future addStream(Stream<T> source, {bool cancelOnError}) =>
      throw UnsupportedError('StateSubjects do not support addStream method');
}

class _StartWithStreamTransformer<T> extends StreamTransformerBase<T, T> {
  final StreamTransformer<T, T> _transformer;

  /// Constructs a [StreamTransformer] which prepends the source [Stream]
  /// with [startValue].
  _StartWithStreamTransformer(_Wrapper<T> startValue)
      : _transformer = _buildTransformer(startValue);

  @override
  Stream<T> bind(Stream<T> stream) => _transformer.bind(stream);

  static StreamTransformer<T, T> _buildTransformer<T>(_Wrapper<T> startValue) {
    return StreamTransformer<T, T>((input, cancelOnError) {
      StreamController<T> controller;
      StreamSubscription<T> subscription;

      controller = StreamController<T>(
          sync: true,
          onListen: () {
            try {
              if (startValue.isError) {
                controller.addError(startValue.error, startValue.stackTrace);
              } else {
                controller.add(startValue.value);
              }
            } on dynamic catch (e, s) {
              controller.addError(e, s);
            }

            subscription = input.listen(
                controller.add,
                onError: controller.addError,
                onDone: controller.close,
                cancelOnError: cancelOnError
            );
          },
          onPause: ([resumeSignal]) => subscription.pause(resumeSignal),
          onResume: () => subscription.resume(),
          onCancel: () => subscription.cancel()
      );

      return controller.stream.listen(null);
    });
  }
}

class _Wrapper<T> {
  final bool isError;

  final T value;
  final Object error;
  final StackTrace stackTrace;

  _Wrapper._(this.isError, this.value, this.error, this.stackTrace);

  factory _Wrapper.value(value) => _Wrapper._(false, value, null, null);

  factory _Wrapper.error(error, stackTrace) =>
      _Wrapper._(true, null, error, stackTrace);
}

import 'dart:async';

import 'package:bloc/bloc.dart';

/// {@macro debounce}
EventTransformer<E> debounce<E>([
  Duration duration = const Duration(milliseconds: 300),
]) {
  return (events, mapper) {
    return events.transform(Debounce(mapper, duration));
  };
}

/// {@template debounce_first}
/// Debounces incoming events.
///
/// When an event is received, a "window" is set
/// for the specified [duration]. If any events are emitted
/// during this window, they will be debounced. Once the
/// window expires, the last event received will be processed.
///
/// **Note**: debounced events never trigger the event handler.
/// {@endtemplate}
class Debounce<T> extends StreamTransformerBase<T, T> {
  /// {@macro debounce}
  const Debounce(
    this.mapper, [
    this.duration = const Duration(milliseconds: 300),
  ]);

  /// The [EventMapper] used to map events.
  final EventMapper<T> mapper;

  /// The [Duration] to wait before emitting the last event.
  final Duration duration;

  @override
  Stream<T> bind(Stream<T> stream) {
    final controller = StreamController<Stream<T>>();
    Timer? timer;

    final subscription = stream.listen((event) {
      timer?.cancel();

      timer = Timer(duration, () {
        controller.add(mapper(event));
      });
    });

    controller.onCancel = () {
      subscription.cancel();
      timer?.cancel();
      controller.close();
    };

    return controller.stream.asyncExpand((stream) => stream);
  }

  @override
  StreamTransformer<RS, RT> cast<RS, RT>() {
    throw UnimplementedError();
  }
}

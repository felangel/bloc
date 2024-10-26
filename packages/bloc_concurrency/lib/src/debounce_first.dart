import 'dart:async';

import 'package:bloc/bloc.dart';

/// {@macro debounce_first}
EventTransformer<E> debounceFirst<E>([
  Duration duration = const Duration(milliseconds: 300),
]) {
  return (events, mapper) {
    return events.transform(_DebounceFirst(mapper, duration));
  };
}

/// {@template debounce_first}
/// Debounces the events after the first event.
///
/// The first event is processed immediately,
/// and subsequent events are debounced.
///
/// Once the first event is process, a "window" is set
/// for the specified [duration]. If any events are emitted
/// during this window, they will be debounced. Once the
/// window expires, the last event received will be processed.
///
/// **Note**: debounced events never trigger the event handler.
/// {@endtemplate}
class _DebounceFirst<T> extends StreamTransformerBase<T, T> {
  const _DebounceFirst(
    this.mapper, [
    this.duration = const Duration(milliseconds: 300),
  ]);

  final EventMapper<T> mapper;

  @override
  Stream<T> bind(Stream<T> stream) {
    final controller = StreamController<Stream<T>>();
    var hasEmitFirstEvent = false;
    Timer? timer;

    final subscription = stream.listen((event) {
      timer?.cancel();

      if (!hasEmitFirstEvent) {
        controller.add(mapper(event));
        hasEmitFirstEvent = true;
        timer = Timer(duration, () {
          hasEmitFirstEvent = false;
        });
        return;
      }

      timer = Timer(duration, () {
        controller.add(mapper(event));
        hasEmitFirstEvent = false;
      });
    });

    controller.onCancel = () {
      subscription.cancel();
      timer?.cancel();
      controller.close();
    };

    return controller.stream.asyncExpand((stream) => stream);
  }

  final Duration duration;

  @override
  StreamTransformer<RS, RT> cast<RS, RT>() {
    throw UnimplementedError();
  }
}

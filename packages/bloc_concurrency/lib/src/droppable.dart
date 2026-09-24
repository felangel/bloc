import 'dart:async';

import 'package:bloc/bloc.dart';

/// Process only one event and ignore (drop) any new events
/// until the current event is done.
///
/// **Note**: dropped events never trigger the event handler.
EventTransformer<Event> droppable<Event>() {
  return (events, mapper) {
    return events.transform(_ExhaustMapStreamTransformer(mapper));
  };
}

class _ExhaustMapStreamTransformer<T> extends StreamTransformerBase<T, T> {
  _ExhaustMapStreamTransformer(this.mapper);

  final EventMapper<T> mapper;

  @override
  Stream<T> bind(Stream<T> stream) {
    late StreamSubscription<T> subscription;
    StreamSubscription<T>? mappedSubscription;
    var isSourceDone = false;

    final controller = StreamController<T>(
      onCancel: () async {
        await mappedSubscription?.cancel();
        return subscription.cancel();
      },
      sync: true,
    );

    // Close the output stream once the source has completed and there is no
    // event currently in flight.
    void maybeClose() {
      if (isSourceDone && mappedSubscription == null) controller.close();
    }

    subscription = stream.listen(
      (data) {
        if (mappedSubscription != null) return;
        final Stream<T> mappedStream;

        mappedStream = mapper(data);
        mappedSubscription = mappedStream.listen(
          controller.add,
          onError: controller.addError,
          onDone: () {
            mappedSubscription = null;
            maybeClose();
          },
        );
      },
      onError: controller.addError,
      onDone: () {
        isSourceDone = true;
        maybeClose();
      },
    );

    return controller.stream;
  }
}

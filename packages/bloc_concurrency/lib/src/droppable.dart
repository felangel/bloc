import 'dart:async';

import 'package:bloc/bloc.dart';

/// Process only one event and ignore (drop) any new events
/// until the current event is done.
///
/// **Note**: dropped events never trigger the event handler.
///
/// This transformer applies only to its registered handler. Different handlers
/// registered on the same [Bloc] operate on independent stream pipelines and do
/// not affect each other.
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
    StreamSubscription<T>? subscription;
    StreamSubscription<T>? mappedSubscription;

    final controller = StreamController<T>(
      onCancel: () => Future.wait<void>([
        if (mappedSubscription != null) mappedSubscription!.cancel(),
        if (subscription != null) subscription.cancel(),
      ]),
      sync: true,
    );

    var isDone = false;
    void onSubscriptionDone() {
      isDone = true;
      if (mappedSubscription == null) controller.close();
    }

    void onMappedSubscriptionDone() {
      mappedSubscription = null;
      if (isDone) controller.close();
    }

    try {
      subscription = stream.listen(
        (data) {
          if (mappedSubscription != null) return;
          try {
            final mappedStream = mapper(data);
            mappedSubscription = mappedStream.listen(
              controller.add,
              onError: controller.addError,
              onDone: onMappedSubscriptionDone,
            );
          } catch (error, stackTrace) {
            controller.addError(error, stackTrace);
          }
        },
        onError: controller.addError,
        onDone: onSubscriptionDone,
      );
    } catch (error, stackTrace) {
      controller
        ..addError(error, stackTrace)
        ..close();
    }

    return controller.stream;
  }
}

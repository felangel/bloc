import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

/// Combination of [sequential] and [droppable].
///
/// This will drop any events that match the types provided in the
/// [droppableEvents] list if an event of the same type is already
/// being processed.
EventTransformer<Event> sequentialDroppable<Event>({
  required List<Type> droppableEvents,
}) {
  return (events, mapper) {
    return events.transform(
      _SequentialAndDroppable(
        mapper,
        droppableTypes: droppableEvents,
      ),
    );
  };
}

class _SequentialAndDroppable<Event>
    extends StreamTransformerBase<Event, Event> {
  _SequentialAndDroppable(
    this.mapper, {
    required List<Type> droppableTypes,
  })  : assert(droppableTypes.isNotEmpty, 'droppableTypes should not be empty'),
        _droppableTypes = Set.unmodifiable(droppableTypes);

  final EventMapper<Event> mapper;
  final Set<Type> _droppableTypes;

  @override
  Stream<Event> bind(Stream<Event> stream) {
    final controller = stream.isBroadcast
        ? StreamController<Event>.broadcast(sync: true)
        : StreamController<Event>(sync: true);
    Completer<void>? completer;
    Type? activeDroppableEventType;

    final subscription = stream.listen(
      null,
      onError: controller.addError,
      onDone: () {
        controller.close();
        completer = null;
      },
    );

    Future<void> freeze() async {
      subscription.pause();
      await completer!.future;
      subscription.resume();
    }

    void disposeDroppable() {
      completer!.complete();
      completer = null;
      activeDroppableEventType = null;
    }

    controller.onListen = () {
      subscription.onData((Event event) async {
        final isDroppable = _droppableTypes.contains(event.runtimeType);

        if (!isDroppable) {
          if (completer != null) await freeze();

          final mappedStream = _mapEventToStream(event, controller);

          if (mappedStream == null) return;

          subscription.pause();
          await controller
              .addStream(mappedStream)
              .whenComplete(subscription.resume);

          return;
        }

        final isDifferentDroppableEventInProgress =
            completer != null && activeDroppableEventType != event.runtimeType;

        if (isDifferentDroppableEventInProgress) await freeze();

        final shouldDrop =
            completer != null && activeDroppableEventType == event.runtimeType;

        if (shouldDrop) return;

        activeDroppableEventType = event.runtimeType;
        completer = Completer<void>();

        final mappedStream = _mapEventToStream(event, controller);

        if (mappedStream == null) return;

        await controller.addStream(mappedStream).whenComplete(disposeDroppable);
      });

      controller.onCancel = subscription.cancel;
      if (!stream.isBroadcast) {
        controller
          ..onPause = subscription.pause
          ..onResume = subscription.resume;
      }
    };

    return controller.stream;
  }

  Stream<Event>? _mapEventToStream(
    Event event,
    StreamController<Event> controller,
  ) {
    try {
      return mapper(event);
    } catch (e, s) {
      controller.addError(e, s);
      return null;
    }
  }
}

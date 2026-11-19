import 'package:bloc/bloc.dart';
import 'package:stream_transform/stream_transform.dart';

/// Process only one event by cancelling any pending events and
/// processing the new event immediately.
///
/// Avoid using [restartable] if you expect an event to have
/// immediate results -- it should only be used with asynchronous APIs.
///
/// **Note**: a new event cancels the previous invocation of the handler:
/// its later `emit` calls are ignored and its `emit.forEach`/`emit.onEach`
/// subscriptions are cancelled, but a [Future] or I/O operation it already
/// started keeps running.
/// Check `emit.isDone` after `await` points and explicitly cancel expensive
/// underlying work when the API supports cancellation.
EventTransformer<Event> restartable<Event>() {
  return (events, mapper) => events.switchMap(mapper);
}

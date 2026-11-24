import 'package:bloc/bloc.dart';
import 'package:stream_transform/stream_transform.dart';

/// Process only one event by cancelling any pending events and
/// processing the new event immediately.
///
/// Avoid using [restartable] if you expect an event to have
/// immediate results -- it should only be used with asynchronous APIs.
///
/// **Note**: there is no overlap between invocations of the same handler and
/// any currently running handler will be cancelled if a new event is added
/// before it completes. When a pending event handler is canceled, all
/// subsequent `emit` calls are ignored and any `emit.onEach`/`emit.forEach`
/// subscriptions are canceled but any pending [Future] or I/O operations will
/// continue running to completion. It is recommended to always check
/// `emit.isDone` across any async gap to avoid scheduling/performing expensive
/// computations.
///
/// This transformer applies only to its registered handler. Different handlers
/// registered on the same [Bloc] operate on independent stream pipelines and do
/// not affect each other.
EventTransformer<Event> restartable<Event>() {
  return (events, mapper) => events.switchMap(mapper);
}

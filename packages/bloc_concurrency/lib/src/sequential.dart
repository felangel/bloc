import 'package:bloc/bloc.dart';

/// Process events one at a time by maintaining a queue of added events
/// and processing the events sequentially.
///
/// **Note**: there is no overlap between invocations of the same handler and
/// every event of this type is guaranteed to be handled in the order it was
/// received. In addition, a burst of incoming events can grow the pending
/// event queue causing a "back up" especially with async event handlers.
///
/// This transformer applies only to its registered handler. Different handlers
/// registered on the same [Bloc] operate on independent stream pipelines and do
/// not affect each other.
EventTransformer<Event> sequential<Event>() {
  return (events, mapper) => events.asyncExpand(mapper);
}

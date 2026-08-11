import 'package:bloc/bloc.dart';

/// Process events one at a time by maintaining a queue of added events
/// and processing the events sequentially.
///
/// **Note**: there is no overlap between invocations of the same handler
/// and every event of this type is guaranteed to be handled in the order
/// it was received.
///
/// This guarantee applies only to the specific handler using this
/// transformer. Different handlers registered on the same [Bloc] operate
/// on independent stream pipelines and do not affect each other.
EventTransformer<Event> sequential<Event>() {
  return (events, mapper) => events.asyncExpand(mapper);
}

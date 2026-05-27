import 'package:bloc/bloc.dart';
import 'package:stream_transform/stream_transform.dart';

/// Process events concurrently.
///
/// **Note**: there may be overlap between invocations of the same handler
/// and state changes will occur as soon as they are emitted. This means that
/// states may be emitted in an order that does not match the order in which
/// the corresponding events were added.
///
/// This guarantee applies only to the specific handler using this
/// transformer. Different handlers registered on the same [Bloc] operate
/// on independent stream pipelines and do not affect each other.
EventTransformer<Event> concurrent<Event>() {
  return (events, mapper) => events.concurrentAsyncExpand(mapper);
}

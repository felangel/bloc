import 'package:bloc/bloc.dart';
import 'package:stream_transform/stream_transform.dart';

/// Process events concurrently.
///
/// **Note**: there may be overlap between invocations of the same handler
/// and state changes will occur as soon as they are emitted. This means that
/// states may be emitted in an order that does not match the order in which
/// the corresponding events were added. In addition, there is no built-in limit
/// on in-flight invocations, which can increase memory and I/O use under load.
///
/// This transformer applies only to its registered handler. Different handlers
/// registered on the same [Bloc] operate on independent stream pipelines and do
/// not affect each other.
EventTransformer<Event> concurrent<Event>() {
  return (events, mapper) => events.concurrentAsyncExpand(mapper);
}

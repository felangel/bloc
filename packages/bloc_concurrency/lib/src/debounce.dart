import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/src/concurrent.dart';
import 'package:stream_transform/stream_transform.dart';

/// Returns an [EventTransformer] that applies a
/// debounce to the incoming events.
///
/// Debouncing ensures that events are emitted only if there is a pause in their
/// occurrence for a specified [duration]. This is useful for limiting the rate
/// of events, for example, handling user input to avoid excessive processing.
///
/// The [duration] parameter specifies the debounce period during which incoming
/// events will be ignored until the specified time has elapsed.
///
/// The [leading] parameter determines whether the first event in a sequence
/// should be emitted immediately. By default, [leading] is set to `false`.
///
/// The [trailing] parameter determines whether the last event in a sequence
/// should be emitted after the [duration] expires.
/// By default, [trailing] is set to `true`.
///
/// **Note**: debounced events never trigger the event handler.
EventTransformer<E> debounce<E>({
  required Duration duration,
  bool leading = false,
  bool trailing = true,
}) {
  assert(duration >= Duration.zero, 'duration cannot be negative');
  assert(leading || trailing, 'leading or trailing must be true');

  return (events, mapper) {
    return concurrent<E>().call(
      events.debounce(
        duration,
        leading: leading,
        trailing: trailing,
      ),
      mapper,
    );
  };
}

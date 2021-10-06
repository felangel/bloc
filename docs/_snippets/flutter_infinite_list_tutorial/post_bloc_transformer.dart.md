```dart
const _throttleDuration = Duration(milliseconds: 500);

EventTransformer<Event> throttle<Event>(Duration duration) {
  return (events, mapper) => events.throttleTime(duration).flatMap(mapper);
}

PostBloc({required this.httpClient}) : super(const PostState()) {
    on<PostFetched>(_onPostFetched, transformer: throttle(_throttleDuration));
  }
```
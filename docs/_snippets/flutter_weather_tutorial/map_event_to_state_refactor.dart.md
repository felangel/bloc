```dart
@override
Stream<WeatherState> mapEventToState(WeatherEvent event) async* {
  if (event is WeatherRequested) {
    yield* _mapWeatherRequestedToState(event);
  } else if (event is WeatherRefreshRequested) {
    yield* _mapWeatherRefreshRequestedToState(event);
  }
}

Stream<WeatherState> _mapWeatherRequestedToState(WeatherRequested event) async* {
  yield WeatherLoadInProgress();
  try {
    final Weather weather = await weatherRepository.getWeather(event.city);
    yield WeatherLoadSuccess(weather: weather);
  } catch (_) {
    yield WeatherLoadFailure();
  }
}

Stream<WeatherState> _mapWeatherRefreshRequestedToState(WeatherRefreshRequested event) async* {
  try {
    final Weather weather = await weatherRepository.getWeather(event.city);
    yield WeatherLoadSuccess(weather: weather);
  } catch (_) {
    yield state;
  }
}
```

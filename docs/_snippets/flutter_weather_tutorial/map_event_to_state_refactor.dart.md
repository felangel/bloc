```dart
@override
Stream<WeatherState> mapEventToState(WeatherEvent event) async* {
  if (event is FetchWeather) {
    yield* _mapFetchWeatherToState(event);
  } else if (event is RefreshWeather) {
    yield* _mapRefreshWeatherToState(event);
  }
}

Stream<WeatherState> _mapFetchWeatherToState(FetchWeather event) async* {
  yield WeatherLoading();
  try {
    final Weather weather = await weatherRepository.getWeather(event.city);
    yield WeatherLoaded(weather: weather);
  } catch (_) {
    yield WeatherError();
  }
}

Stream<WeatherState> _mapRefreshWeatherToState(RefreshWeather event) async* {
  try {
    final Weather weather = await weatherRepository.getWeather(event.city);
    yield WeatherLoaded(weather: weather);
  } catch (_) {
    yield state;
  }
}
```

```dart
if (event is WeatherRefreshRequested) {
  try {
    final Weather weather = await weatherRepository.getWeather(event.city);
    yield WeatherLoadSuccess(weather: weather);
  } catch (_) {
    yield state;
  }
}
```

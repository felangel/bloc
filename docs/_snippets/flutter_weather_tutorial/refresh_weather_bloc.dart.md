```dart
if (event is RefreshWeather) {
  try {
    final Weather weather = await weatherRepository.getWeather(event.city);
    yield WeatherLoaded(weather: weather);
  } catch (_) {
    yield state;
  }
}
```

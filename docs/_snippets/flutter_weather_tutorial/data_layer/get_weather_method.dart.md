```dart
/// Fetches [Weather] for a given [locationId].
Future<Weather> getWeather(int locationId) async {
  final weatherRequest = Uri.https(_baseUrl, '/api/location/$locationId');
  final weatherResponse = await _httpClient.get(weatherRequest);

  if (weatherResponse.statusCode != 200) {
    throw WeatherRequestFailure();
  }

  final weatherJson = jsonDecode(
    weatherResponse.body,
  )['consolidated_weather'] as List;

  if (weatherJson.isEmpty) {
    throw WeatherRequestFailure();
  }

  return Weather.fromJson(weatherJson.first as Map<String, dynamic>);
}
```
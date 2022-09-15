```dart
/// Fetches [Weather] for a given [latitude] and [longitude].
Future<Weather> getWeather({
  required double latitude,
  required double longitude,
}) async {
  final weatherRequest = Uri.https(_baseUrlWeather, 'v1/forecast', {
    'latitude': '$latitude',
    'longitude': '$longitude',
    'current_weather': 'true'
  });

  final weatherResponse = await _httpClient.get(weatherRequest);

  if (weatherResponse.statusCode != 200) {
    throw WeatherRequestFailure();
  }

  final bodyJson = jsonDecode(weatherResponse.body) as Map<String, dynamic>;

  if (!bodyJson.containsKey('current_weather')) {
    throw WeatherNotFoundFailure();
  }

  final weatherJson = bodyJson['current_weather'] as Map<String, dynamic>;

  return Weather.fromJson(weatherJson);
}
```
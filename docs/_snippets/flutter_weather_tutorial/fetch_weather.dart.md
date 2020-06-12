```dart
Future<Weather> fetchWeather(int locationId) async {
  final weatherUrl = '$baseUrl/api/location/$locationId';
  final weatherResponse = await this.httpClient.get(weatherUrl);

  if (weatherResponse.statusCode != 200) {
    throw Exception('error getting weather for location');
  }

  final weatherJson = jsonDecode(weatherResponse.body);
  return Weather.fromJson(weatherJson);
}
```

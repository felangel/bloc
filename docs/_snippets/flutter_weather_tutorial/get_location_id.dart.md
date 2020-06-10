```dart
Future<int> getLocationId(String city) async {
  final locationUrl = '$baseUrl/api/location/search/?query=$city';
  final locationResponse = await this.httpClient.get(locationUrl);
  if (locationResponse.statusCode != 200) {
    throw Exception('error getting locationId for city');
  }

  final locationJson = jsonDecode(locationResponse.body) as List;
  return (locationJson.first)['woeid'];
}
```

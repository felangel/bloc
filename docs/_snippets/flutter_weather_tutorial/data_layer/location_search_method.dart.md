```dart
/// Finds a [Location] `/api/location/search/?query=(query)`.
Future<Location> locationSearch(String query) async {
  final locationRequest = Uri.https(
    _baseUrl,
    '/api/location/search',
    <String, String>{'query': query},
  );
  final locationResponse = await _httpClient.get(locationRequest);

  if (locationResponse.statusCode != 200) {
    throw LocationIdRequestFailure();
  }

  final locationJson = jsonDecode(
    locationResponse.body,
  ) as List;

  if (locationJson.isEmpty) {
    throw LocationIdRequestFailure();
  }

  return Location.fromJson(locationJson.first as Map<String, dynamic>);
}
```
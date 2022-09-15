```dart
/// Finds a [Location] `/v1/search/?name=(query)`.
Future<Location> locationSearch(String query) async {
  final locationRequest = Uri.https(
    _baseUrlGeocoding,
    '/v1/search',
    {'name': query, 'count': '1'},
  );

  final locationResponse = await _httpClient.get(locationRequest);

  if (locationResponse.statusCode != 200) {
    throw LocationRequestFailure();
  }

  final locationJson = jsonDecode(locationResponse.body) as Map;

  if (!locationJson.containsKey('results')) throw LocationNotFoundFailure();

  final results = locationJson['results'] as List;

  if (results.isEmpty) throw LocationNotFoundFailure();

  return Location.fromJson(results.first as Map<String, dynamic>);
}
```
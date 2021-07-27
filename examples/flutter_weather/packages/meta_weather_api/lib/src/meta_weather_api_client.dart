import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:meta_weather_api/meta_weather_api.dart';

/// Exception thrown when locationSearch fails.
class LocationIdRequestFailure implements Exception {}

/// Exception thrown when the provided location is not found.
class LocationNotFoundFailure implements Exception {}

/// Exception thrown when getWeather fails.
class WeatherRequestFailure implements Exception {}

/// Exception thrown when weather for provided location is not found.
class WeatherNotFoundFailure implements Exception {}

/// {@template meta_weather_api_client}
/// Dart API Client which wraps the [MetaWeather API](https://www.metaweather.com/api/).
/// {@endtemplate}
class MetaWeatherApiClient {
  /// {@macro meta_weather_api_client}
  MetaWeatherApiClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  static const _baseUrl = 'www.metaweather.com';
  final http.Client _httpClient;

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
      throw LocationNotFoundFailure();
    }

    return Location.fromJson(locationJson.first as Map<String, dynamic>);
  }

  /// Fetches [Weather] for a given [locationId].
  Future<Weather> getWeather(int locationId) async {
    final weatherRequest = Uri.https(_baseUrl, '/api/location/$locationId');
    final weatherResponse = await _httpClient.get(weatherRequest);

    if (weatherResponse.statusCode != 200) {
      throw WeatherRequestFailure();
    }

    final bodyJson = jsonDecode(weatherResponse.body) as Map<String, dynamic>;

    if (bodyJson.isEmpty) {
      throw WeatherNotFoundFailure();
    }

    final weatherJson = bodyJson['consolidated_weather'] as List;

    if (weatherJson.isEmpty) {
      throw WeatherNotFoundFailure();
    }

    return Weather.fromJson(weatherJson.first as Map<String, dynamic>);
  }
}

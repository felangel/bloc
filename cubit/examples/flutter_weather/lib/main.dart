import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_weather/api/api.dart';
import 'package:flutter_weather/app/app.dart';
import 'package:flutter_weather/service/service.dart';

void main() {
  final httpClient = http.Client();
  final weatherApiClient = MetaWeatherApiClient(httpClient: httpClient);
  final weatherService = WeatherService(weatherApiClient: weatherApiClient);
  runApp(WeatherApp(weatherService: weatherService));
}

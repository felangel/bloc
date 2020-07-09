import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:flutter_weather/api/api.dart' as api;
import 'package:flutter_weather/service/service.dart';

class WeatherService {
  const WeatherService({@required api.MetaWeatherApiClient weatherApiClient})
      : assert(weatherApiClient != null),
        _weatherApiClient = weatherApiClient;

  final api.MetaWeatherApiClient _weatherApiClient;

  Future<Weather> getWeather(String city) async {
    final location = await _weatherApiClient.locationSearch(city);
    final weather = await _weatherApiClient.getWeather(location.woeid);
    return Weather(
      temperature: weather.theTemp,
      location: location.title,
      condition: weather.weatherStateAbbr.toCondition,
    );
  }
}

extension on api.WeatherState {
  WeatherCondition get toCondition {
    switch (this) {
      case api.WeatherState.clear:
        return WeatherCondition.clear;
      case api.WeatherState.snow:
      case api.WeatherState.sleet:
      case api.WeatherState.hail:
        return WeatherCondition.snowy;
      case api.WeatherState.thunderstorm:
      case api.WeatherState.heavyRain:
      case api.WeatherState.lightRain:
      case api.WeatherState.showers:
        return WeatherCondition.rainy;
      case api.WeatherState.heavyCloud:
      case api.WeatherState.lightCloud:
        return WeatherCondition.cloudy;
      default:
        return WeatherCondition.unknown;
    }
  }
}

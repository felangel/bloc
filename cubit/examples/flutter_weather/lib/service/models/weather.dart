import 'package:flutter/foundation.dart';

enum WeatherCondition {
  clear,
  rainy,
  cloudy,
  snowy,
  unknown,
}

class Weather {
  const Weather({
    @required this.location,
    @required this.temperature,
    @required this.condition,
  });

  final String location;
  final double temperature;
  final WeatherCondition condition;
}

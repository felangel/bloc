```dart
import 'package:flutter/material.dart';
import 'package:flutter_weather/app.dart';
import 'package:weather_repository/weather_repository.dart';

void main() {
  runApp(WeatherApp(weatherRepository: WeatherRepository()));
}
```
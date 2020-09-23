import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_weather/app.dart';
import 'package:flutter_weather/weather_bloc_observer.dart';
import 'package:weather_repository/weather_repository.dart';

void main() {
  EquatableConfig.stringify = kDebugMode;
  Bloc.observer = WeatherBlocObserver();
  runApp(WeatherApp(weatherRepository: WeatherRepository()));
}

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:weather_repository/weather_repository.dart';

class ThemeCubit extends Cubit<Color> {
  ThemeCubit() : super(null);

  void updateTheme(Weather weather) => emit(weather.toColor);
}

extension on Weather {
  Color get toColor {
    switch (condition) {
      case WeatherCondition.clear:
        return Colors.orangeAccent;
      case WeatherCondition.snowy:
        return Colors.lightBlueAccent;
      case WeatherCondition.cloudy:
        return Colors.blueGrey;
      case WeatherCondition.rainy:
        return Colors.indigoAccent;
      case WeatherCondition.unknown:
      default:
        return null;
    }
  }
}

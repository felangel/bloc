import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:weather_repository/weather_repository.dart' hide Weather;
import 'package:weather_repository/weather_repository.dart'
    as weather_repository;

part 'weather.g.dart';

enum TemperatureUnits { fahrenheit, celsius }

@JsonSerializable()
class Temperature extends Equatable {
  const Temperature({@required this.units, @required this.value});

  factory Temperature.fromJson(Map<String, dynamic> json) =>
      _$TemperatureFromJson(json);

  final TemperatureUnits units;
  final double value;

  Map<String, dynamic> toJson() => _$TemperatureToJson(this);

  @override
  List<Object> get props => [units, value];
}

@JsonSerializable()
class Weather extends Equatable {
  const Weather({
    @required this.condition,
    @required this.location,
    @required this.temperature,
  });

  factory Weather.fromJson(Map<String, dynamic> json) =>
      _$WeatherFromJson(json);

  factory Weather.fromRepository(weather_repository.Weather weather) {
    return Weather(
      condition: weather.condition,
      location: weather.location,
      temperature: Temperature(
        units: TemperatureUnits.celsius,
        value: weather.temperature,
      ),
    );
  }

  final WeatherCondition condition;
  final String location;
  final Temperature temperature;

  @override
  List<Object> get props => [condition, location, temperature];

  Map<String, dynamic> toJson() => _$WeatherToJson(this);

  Weather copyWith({
    WeatherCondition condition,
    String location,
    Temperature temperature,
  }) {
    return Weather(
      condition: condition ?? this.condition,
      location: location ?? this.location,
      temperature: temperature ?? this.temperature,
    );
  }
}

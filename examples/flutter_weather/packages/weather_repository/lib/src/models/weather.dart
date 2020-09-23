import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

enum WeatherCondition {
  clear,
  rainy,
  cloudy,
  snowy,
  unknown,
}

class Weather extends Equatable {
  const Weather({
    @required this.location,
    @required this.temperature,
    @required this.condition,
  });

  final String location;
  final double temperature;
  final WeatherCondition condition;

  @override
  List<Object> get props => [location, temperature, condition];
}

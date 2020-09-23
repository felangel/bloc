part of 'weather_cubit.dart';

@immutable
abstract class WeatherState extends Equatable {
  @override
  List<Object> get props => [];
}

class WeatherInitial extends WeatherState {}

class WeatherLoadInProgress extends WeatherState {}

class WeatherLoadSuccess extends WeatherState {
  WeatherLoadSuccess(this.weather);

  final Weather weather;

  @override
  List<Object> get props => [weather];
}

class WeatherLoadFailure extends WeatherState {}

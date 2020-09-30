part of 'weather_cubit.dart';

enum WeatherStatus { initial, loading, success, failure }

@JsonSerializable()
class WeatherState extends Equatable {
  const WeatherState({
    this.status = WeatherStatus.initial,
    this.temperatureUnits = TemperatureUnits.celsius,
    this.weather,
  });

  factory WeatherState.fromJson(Map<String, dynamic> json) =>
      _$WeatherStateFromJson(json);

  final WeatherStatus status;
  final Weather weather;
  final TemperatureUnits temperatureUnits;

  WeatherState copyWith({
    WeatherStatus status,
    TemperatureUnits temperatureUnits,
    Weather weather,
  }) {
    return WeatherState(
      status: status ?? this.status,
      temperatureUnits: temperatureUnits ?? this.temperatureUnits,
      weather: weather ?? this.weather,
    );
  }

  Map<String, dynamic> toJson() => _$WeatherStateToJson(this);

  @override
  List<Object> get props => [status, temperatureUnits, weather];
}

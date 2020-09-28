part of 'weather_cubit.dart';

enum TemperatureUnits { fahrenheit, celsius }
enum WeatherStatus { initial, loading, success, failure }

@JsonSerializable()
class WeatherState extends Equatable {
  const WeatherState({
    this.status = WeatherStatus.initial,
    this.weather,
    this.units = TemperatureUnits.fahrenheit,
  });

  factory WeatherState.fromJson(Map<String, dynamic> json) =>
      _$WeatherStateFromJson(json);

  final WeatherStatus status;
  final Weather weather;
  final TemperatureUnits units;

  WeatherState copyWith({
    WeatherStatus status,
    Weather weather,
    TemperatureUnits units,
  }) {
    return WeatherState(
      status: status ?? this.status,
      weather: weather ?? this.weather,
      units: units ?? this.units,
    );
  }

  Map<String, dynamic> toJson() => _$WeatherStateToJson(this);

  @override
  List<Object> get props => [status, weather, units];
}

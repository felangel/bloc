part of 'weather_cubit.dart';

@immutable
abstract class WeatherState extends Equatable {
  const WeatherState();

  @override
  List<Object> get props => [];
}

class WeatherInitial extends WeatherState {
  const WeatherInitial();
}

class WeatherLoadInProgress extends WeatherState {
  const WeatherLoadInProgress();
}

@JsonSerializable()
class WeatherLoadSuccess extends WeatherState {
  const WeatherLoadSuccess(this.weather);

  factory WeatherLoadSuccess.fromJson(Map<String, dynamic> json) =>
      _$WeatherLoadSuccessFromJson(json);

  final Weather weather;

  Map<String, dynamic> toJson() => _$WeatherLoadSuccessToJson(this);

  @override
  List<Object> get props => [weather];
}

class WeatherLoadFailure extends WeatherState {
  const WeatherLoadFailure();
}

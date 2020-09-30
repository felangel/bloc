import 'package:equatable/equatable.dart';
import 'package:flutter_weather/weather/weather.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:weather_repository/weather_repository.dart'
    show WeatherRepository;

part 'weather_cubit.g.dart';
part 'weather_state.dart';

class WeatherCubit extends HydratedCubit<WeatherState> {
  WeatherCubit(this._weatherRepository) : super(const WeatherState());

  final WeatherRepository _weatherRepository;

  Future<void> fetchWeather(String city) async {
    if (city == null || city.isEmpty) return;

    emit(state.copyWith(status: WeatherStatus.loading));

    try {
      final weather = Weather.fromRepository(
        await _weatherRepository.getWeather(city),
      );
      final units = state.temperatureUnits;
      final value = units == TemperatureUnits.fahrenheit
          ? weather.temperature.value.toFahrenheit()
          : weather.temperature.value;

      emit(
        state.copyWith(
          status: WeatherStatus.success,
          temperatureUnits: units,
          weather: weather.copyWith(
            temperature: Temperature(units: units, value: value),
          ),
        ),
      );
    } on Exception {
      emit(state.copyWith(status: WeatherStatus.failure));
    }
  }

  void toggleUnits() {
    final units = state.temperatureUnits == TemperatureUnits.fahrenheit
        ? TemperatureUnits.celsius
        : TemperatureUnits.fahrenheit;

    if (state.status != WeatherStatus.success) {
      emit(state.copyWith(temperatureUnits: units));
      return;
    }

    final temperature = state.weather.temperature;
    final value = units == TemperatureUnits.celsius
        ? temperature.value.toCelsius()
        : temperature.value.toFahrenheit();

    emit(
      state.copyWith(
        temperatureUnits: units,
        weather: state.weather.copyWith(
          temperature: Temperature(units: units, value: value),
        ),
      ),
    );
  }

  @override
  WeatherState fromJson(Map<String, dynamic> json) =>
      WeatherState.fromJson(json);

  @override
  Map<String, dynamic> toJson(WeatherState state) => state.toJson();
}

extension on double {
  double toFahrenheit() => ((this * 9 / 5) + 32);
  double toCelsius() => ((this - 32) * 5 / 9);
}

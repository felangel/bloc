import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:weather_repository/weather_repository.dart';

part 'weather_cubit.g.dart';
part 'weather_state.dart';

class WeatherCubit extends HydratedCubit<WeatherState> {
  WeatherCubit(this._weatherRepository) : super(const WeatherState());

  final WeatherRepository _weatherRepository;

  Future<void> fetchWeather(String city) async {
    if (city == null || city.isEmpty) return;
    emit(state.copyWith(status: WeatherStatus.loading));
    try {
      final weather = await _weatherRepository.getWeather(city);
      emit(state.copyWith(status: WeatherStatus.success, weather: weather));
    } on Exception {
      emit(state.copyWith(status: WeatherStatus.failure));
    }
  }

  void toggleUnits() {
    emit(
      state.copyWith(
        units: state.units == TemperatureUnits.fahrenheit
            ? TemperatureUnits.celsius
            : TemperatureUnits.fahrenheit,
      ),
    );
  }

  @override
  WeatherState fromJson(Map<String, dynamic> json) =>
      WeatherState.fromJson(json);

  @override
  Map<String, dynamic> toJson(WeatherState state) => state.toJson();
}

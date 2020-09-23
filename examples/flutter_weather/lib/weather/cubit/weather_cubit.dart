import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:weather_repository/weather_repository.dart';

part 'weather_cubit.g.dart';
part 'weather_state.dart';

class WeatherCubit extends HydratedCubit<WeatherState> {
  WeatherCubit(this._weatherRepository) : super(const WeatherInitial());

  final WeatherRepository _weatherRepository;

  Future<void> fetchWeather(String city) async {
    if (city == null || city.isEmpty) return;
    emit(const WeatherLoadInProgress());
    try {
      final weather = await _weatherRepository.getWeather(city);
      emit(WeatherLoadSuccess(weather));
    } on Exception {
      emit(const WeatherLoadFailure());
    }
  }

  @override
  WeatherState fromJson(Map<String, dynamic> json) {
    return WeatherLoadSuccess.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(WeatherState state) {
    return state is WeatherLoadSuccess ? state.toJson() : null;
  }
}

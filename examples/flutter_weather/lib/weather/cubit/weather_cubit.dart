import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:weather_repository/weather_repository.dart';

part 'weather_state.dart';

class WeatherCubit extends Cubit<WeatherState> {
  WeatherCubit(this._weatherRepository) : super(WeatherInitial());

  final WeatherRepository _weatherRepository;

  Future<void> fetchWeather(String city) async {
    emit(WeatherLoadInProgress());
    try {
      final weather = await _weatherRepository.getWeather(city);
      emit(WeatherLoadSuccess(weather));
    } on Exception {
      emit(WeatherLoadFailure());
    }
  }
}

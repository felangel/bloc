import 'package:cubit/cubit.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter_weather/service/service.dart';

@immutable
abstract class WeatherState {}

class WeatherInitial extends WeatherState {}

class WeatherLoadInProgress extends WeatherState {}

class WeatherLoadSuccess extends WeatherState {
  WeatherLoadSuccess(this.weather);

  final Weather weather;
}

class WeatherLoadFailure extends WeatherState {}

class WeatherCubit extends Cubit<WeatherState> {
  WeatherCubit(this._weatherService);

  final WeatherService _weatherService;

  @override
  WeatherState get initialState => WeatherInitial();

  Future<void> getWeather({@required String city}) async {
    if (city == null || city.isEmpty) return;
    await emit(WeatherLoadInProgress());
    try {
      final weather = await _weatherService.getWeather(city);
      return emit(WeatherLoadSuccess(weather));
    } catch (_) {
      return emit(WeatherLoadFailure());
    }
  }
}

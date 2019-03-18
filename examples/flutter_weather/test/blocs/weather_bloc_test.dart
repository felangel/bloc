import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_weather/repositories/weather_repository.dart';
import 'package:flutter_weather/models/weather.dart';
import 'package:flutter_weather/blocs/weather_bloc.dart';

class MockWeatherRepository extends Mock implements WeatherRepository {}

main() {
  group('WeatherBloc', () {
    MockWeatherRepository weatherRepository;
    WeatherBloc weatherBloc;

    setUp(() {
      weatherRepository = MockWeatherRepository();
      weatherBloc = WeatherBloc(weatherRepository: weatherRepository);
    });

    test('has a correct initialState', () {
      expect(weatherBloc.initialState, WeatherEmpty());
    });

    group('FetchWeather', () {
      test(
          'emits [WeatherEmpty, WeatherLoading, WeatherLoaded] when weather repository returns weather',
          () {
        final Weather weather = Weather(
          condition: WeatherCondition.clear,
          formattedCondition: 'Clear',
          minTemp: 15,
          maxTemp: 20,
          locationId: 0,
          location: 'Chicago',
          lastUpdated: DateTime(2019),
        );
        when(weatherRepository.getWeather('chicago')).thenAnswer(
          (_) => Future.value(weather),
        );
        expectLater(
          weatherBloc.state,
          emitsInOrder([
            WeatherEmpty(),
            WeatherLoading(),
            WeatherLoaded(weather: weather),
          ]),
        );
        weatherBloc.dispatch(FetchWeather(city: 'chicago'));
      });

      test(
          'emits [WeatherEmpty, WeatherLoading, WeatherError] when weather repository throws error',
          () {
        when(weatherRepository.getWeather('chicago'))
            .thenThrow('Weather Error');
        expectLater(
          weatherBloc.state,
          emitsInOrder([
            WeatherEmpty(),
            WeatherLoading(),
            WeatherError(),
          ]),
        );
        weatherBloc.dispatch(FetchWeather(city: 'chicago'));
      });
    });

    group('RefreshWeather', () {
      test(
          'emits [WeatherEmpty, WeatherLoaded] when weather repository returns weather',
          () {
        final Weather weather = Weather(
          condition: WeatherCondition.clear,
          formattedCondition: 'Clear',
          minTemp: 15,
          maxTemp: 20,
          locationId: 0,
          location: 'Chicago',
          lastUpdated: DateTime(2019),
        );
        when(weatherRepository.getWeather('chicago')).thenAnswer(
          (_) => Future.value(weather),
        );
        expectLater(
          weatherBloc.state,
          emitsInOrder([
            WeatherEmpty(),
            WeatherLoaded(weather: weather),
          ]),
        );
        weatherBloc.dispatch(RefreshWeather(city: 'chicago'));
      });

      test('emits [WeatherEmpty] when weather repository throws error', () {
        when(weatherRepository.getWeather('chicago'))
            .thenThrow('Weather Error');
        expectLater(
          weatherBloc.state,
          emitsInOrder([WeatherEmpty()]),
        );
        weatherBloc.dispatch(RefreshWeather(city: 'chicago'));
      });
    });
  });
}

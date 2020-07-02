import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_weather/repositories/weather_repository.dart';
import 'package:flutter_weather/models/weather.dart';
import 'package:flutter_weather/blocs/weather_bloc.dart';

class MockWeatherRepository extends Mock implements WeatherRepository {}

void main() {
  final Weather weather = Weather(
    condition: WeatherCondition.clear,
    formattedCondition: 'Clear',
    minTemp: 15,
    maxTemp: 20,
    locationId: 0,
    location: 'Chicago',
    lastUpdated: DateTime(2019),
  );
  group('WeatherBloc', () {
    MockWeatherRepository weatherRepository;
    WeatherBloc weatherBloc;

    setUp(() {
      weatherRepository = MockWeatherRepository();
      weatherBloc = WeatherBloc(weatherRepository: weatherRepository);
    });

    tearDown(() {
      weatherBloc?.close();
    });

    test('throws AssertionError when weatherRepository is null', () {
      expect(() => WeatherBloc(weatherRepository: null), throwsAssertionError);
    });

    test('has a correct initial state', () {
      expect(weatherBloc.state, WeatherInitial());
    });

    group('WeatherRequested', () {
      blocTest(
        'emits [WeatherLoadInProgress, WeatherLoadSuccess] when weather repository returns weather',
        build: () async {
          when(weatherRepository.getWeather('chicago')).thenAnswer(
            (_) => Future.value(weather),
          );
          return weatherBloc;
        },
        act: (bloc) => bloc.add(WeatherRequested(city: 'chicago')),
        expect: [
          WeatherLoadInProgress(),
          WeatherLoadSuccess(weather: weather),
        ],
      );

      blocTest(
        'emits [WeatherLoadInProgress, WeatherLoadFailure] when weather repository throws error',
        build: () async {
          when(weatherRepository.getWeather('chicago'))
              .thenThrow('Weather Error');
          return weatherBloc;
        },
        act: (bloc) => bloc.add(WeatherRequested(city: 'chicago')),
        expect: [
          WeatherLoadInProgress(),
          WeatherLoadFailure(),
        ],
      );
    });

    group('WeatherRefreshRequested', () {
      blocTest(
        'emits [WeatherLoadSuccess] when weather repository returns weather',
        build: () async {
          when(weatherRepository.getWeather('chicago')).thenAnswer(
            (_) => Future.value(weather),
          );
          return weatherBloc;
        },
        act: (bloc) => bloc.add(WeatherRefreshRequested(city: 'chicago')),
        expect: [
          WeatherLoadSuccess(weather: weather),
        ],
      );

      blocTest(
        'emits [] when weather repository throws error',
        build: () async {
          when(weatherRepository.getWeather('chicago'))
              .thenThrow('Weather Error');
          return weatherBloc;
        },
        act: (bloc) => bloc.add(WeatherRefreshRequested(city: 'chicago')),
        expect: [],
      );
    });
  });
}

import 'package:cubit_test/cubit_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_weather/app/weather/weather_cubit.dart';
import 'package:flutter_weather/service/service.dart';
import 'package:matcher/matcher.dart';
import 'package:mockito/mockito.dart';

class MockWeatherService extends Mock implements WeatherService {}

class MockWeather extends Mock implements Weather {}

void main() {
  group('WeatherCubit', () {
    test('initial state is WeatherInitial', () {
      expect(WeatherCubit(MockWeatherService()).state, isA<WeatherInitial>());
    });

    group('getWeather', () {
      final weather = MockWeather();
      WeatherService weatherService;

      setUp(() {
        weatherService = MockWeatherService();
      });

      test('calls weatherService.getWeather', () async {
        final cubit = WeatherCubit(weatherService);
        await cubit.getWeather(city: 'Chicago');
        verify(weatherService.getWeather('Chicago')).called(1);
        await cubit.close();
      });

      cubitTest<WeatherCubit, WeatherState>(
        'emits [WeatherLoadInProgress, WeatherLoadSuccess] '
        'when getWeather succeeds',
        build: () async {
          when(weatherService.getWeather(any)).thenAnswer((_) async => weather);
          return WeatherCubit(weatherService);
        },
        act: (cubit) async => cubit.getWeather(city: 'Chicago'),
        expect: <Matcher>[
          isA<WeatherLoadInProgress>(),
          const TypeMatcher<WeatherLoadSuccess>()
            ..having((s) => s.weather, 'weather', weather)
        ],
      );

      cubitTest<WeatherCubit, WeatherState>(
        'emits [WeatherLoadInProgress, WeatherLoadFailure] '
        'when getWeather throws',
        build: () async {
          when(weatherService.getWeather(any)).thenThrow(Exception('oops'));
          return WeatherCubit(weatherService);
        },
        act: (cubit) async => cubit.getWeather(city: 'Chicago'),
        expect: <Matcher>[
          isA<WeatherLoadInProgress>(),
          isA<WeatherLoadFailure>(),
        ],
      );
    });
  });
}

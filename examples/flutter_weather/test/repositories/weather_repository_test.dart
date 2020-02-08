import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_weather/models/models.dart';
import 'package:flutter_weather/repositories/repositories.dart';
import 'package:mockito/mockito.dart';

class MockWeatherApiClient extends Mock implements WeatherApiClient {}

// ignore: must_be_immutable
class MockWeather extends Mock implements Weather {}

void main() {
  group('WeatherRepository', () {
    WeatherApiClient weatherApiClient;
    WeatherRepository weatherRepository;

    setUp(() {
      weatherApiClient = MockWeatherApiClient();
      weatherRepository = WeatherRepository(weatherApiClient: weatherApiClient);
    });

    test('throws AssertionError when weatherApiClient is null', () {
      expect(
        () => WeatherRepository(weatherApiClient: null),
        throwsAssertionError,
      );
    });

    group('getWeather', () {
      test('throws when weatherApiClient.getLocationId throws', () async {
        when(weatherApiClient.getLocationId('chicago')).thenThrow('oops');
        try {
          await weatherRepository.getWeather('chicago');
          throw ('should throw');
        } catch (error) {
          expect(error, 'oops');
        }
      });

      test('throws when weatherApiClient.fetchWeather throws', () async {
        when(weatherApiClient.getLocationId('chicago'))
            .thenAnswer((_) => Future.value(100));
        when(weatherApiClient.fetchWeather(100)).thenThrow('oops');
        try {
          await weatherRepository.getWeather('chicago');
          throw ('should throw');
        } catch (error) {
          expect(error, 'oops');
        }
      });

      test('returns weather when weatherApi calls succeed', () async {
        final expected = MockWeather();
        when(weatherApiClient.getLocationId('chicago'))
            .thenAnswer((_) => Future.value(100));
        when(weatherApiClient.fetchWeather(100))
            .thenAnswer((_) => Future.value(expected));

        final actual = await weatherRepository.getWeather('chicago');
        expect(actual, expected);
      });
    });
  });
}

// ignore_for_file: prefer_const_constructors
import 'package:meta_weather_api/meta_weather_api.dart' as meta_weather_api;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:weather_repository/weather_repository.dart';

class MockMetaWeatherApiClient extends Mock
    implements meta_weather_api.MetaWeatherApiClient {}

class MockLocation extends Mock implements meta_weather_api.Location {}

class MockWeather extends Mock implements meta_weather_api.Weather {}

void main() {
  group('WeatherRepository', () {
    late meta_weather_api.MetaWeatherApiClient metaWeatherApiClient;
    late WeatherRepository weatherRepository;

    setUp(() {
      metaWeatherApiClient = MockMetaWeatherApiClient();
      weatherRepository = WeatherRepository(
        weatherApiClient: metaWeatherApiClient,
      );
    });

    group('constructor', () {
      test('instantiates internal MetaWeatherApiClient when not injected', () {
        expect(WeatherRepository(), isNotNull);
      });
    });

    group('getWeather', () {
      const city = 'london';
      const woeid = 44418;

      test('calls locationSearch with correct city', () async {
        try {
          await weatherRepository.getWeather(city);
        } catch (_) {}
        verify(() => metaWeatherApiClient.locationSearch(city)).called(1);
      });

      test('throws when locationSearch fails', () async {
        final exception = Exception('oops');
        when(() => metaWeatherApiClient.locationSearch(any()))
            .thenThrow(exception);
        expect(
          () async => await weatherRepository.getWeather(city),
          throwsA(exception),
        );
      });

      test('calls getWeather with correct woeid', () async {
        final location = MockLocation();
        when(() => location.woeid).thenReturn(woeid);
        when(() => metaWeatherApiClient.locationSearch(any())).thenAnswer(
          (_) async => location,
        );
        try {
          await weatherRepository.getWeather(city);
        } catch (_) {}
        verify(() => metaWeatherApiClient.getWeather(woeid)).called(1);
      });

      test('throws when getWeather fails', () async {
        final exception = Exception('oops');
        final location = MockLocation();
        when(() => location.woeid).thenReturn(woeid);
        when(() => metaWeatherApiClient.locationSearch(any())).thenAnswer(
          (_) async => location,
        );
        when(() => metaWeatherApiClient.getWeather(any())).thenThrow(exception);
        expect(
          () async => await weatherRepository.getWeather(city),
          throwsA(exception),
        );
      });

      test('returns correct weather on success (showers)', () async {
        final location = MockLocation();
        final weather = MockWeather();
        when(() => location.woeid).thenReturn(woeid);
        when(() => location.title).thenReturn('London');
        when(() => weather.weatherStateAbbr).thenReturn(
          meta_weather_api.WeatherState.showers,
        );
        when(() => weather.theTemp).thenReturn(42.42);
        when(() => metaWeatherApiClient.locationSearch(any())).thenAnswer(
          (_) async => location,
        );
        when(() => metaWeatherApiClient.getWeather(any())).thenAnswer(
          (_) async => weather,
        );
        final actual = await weatherRepository.getWeather(city);
        expect(
          actual,
          Weather(
            temperature: 42.42,
            location: 'London',
            condition: WeatherCondition.rainy,
          ),
        );
      });

      test('returns correct weather on success (heavy cloud)', () async {
        final location = MockLocation();
        final weather = MockWeather();
        when(() => location.woeid).thenReturn(woeid);
        when(() => location.title).thenReturn('London');
        when(() => weather.weatherStateAbbr).thenReturn(
          meta_weather_api.WeatherState.heavyCloud,
        );
        when(() => weather.theTemp).thenReturn(42.42);
        when(() => metaWeatherApiClient.locationSearch(any())).thenAnswer(
          (_) async => location,
        );
        when(() => metaWeatherApiClient.getWeather(any())).thenAnswer(
          (_) async => weather,
        );
        final actual = await weatherRepository.getWeather(city);
        expect(
          actual,
          Weather(
            temperature: 42.42,
            location: 'London',
            condition: WeatherCondition.cloudy,
          ),
        );
      });

      test('returns correct weather on success (light cloud)', () async {
        final location = MockLocation();
        final weather = MockWeather();
        when(() => location.woeid).thenReturn(woeid);
        when(() => location.title).thenReturn('London');
        when(() => weather.weatherStateAbbr).thenReturn(
          meta_weather_api.WeatherState.lightCloud,
        );
        when(() => weather.theTemp).thenReturn(42.42);
        when(() => metaWeatherApiClient.locationSearch(any())).thenAnswer(
          (_) async => location,
        );
        when(() => metaWeatherApiClient.getWeather(any())).thenAnswer(
          (_) async => weather,
        );
        final actual = await weatherRepository.getWeather(city);
        expect(
          actual,
          Weather(
            temperature: 42.42,
            location: 'London',
            condition: WeatherCondition.cloudy,
          ),
        );
      });
    });
  });
}

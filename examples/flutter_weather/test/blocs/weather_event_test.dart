import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_weather/blocs/weather_bloc.dart';

void main() {
  group('WeatherEvent', () {
    group('FetchWeather', () {
      test('props are [city]', () {
        expect(FetchWeather(city: 'city').props, ['city']);
      });
    });

    group('RefreshWeather', () {
      test('props are [city]', () {
        expect(RefreshWeather(city: 'city').props, ['city']);
      });
    });
  });
}

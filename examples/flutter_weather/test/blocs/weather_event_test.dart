import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_weather/blocs/weather_bloc.dart';

void main() {
  group('WeatherEvent', () {
    group('WeatherRequested', () {
      test('props are [city]', () {
        expect(WeatherRequested(city: 'city').props, ['city']);
      });
    });

    group('WeatherRefreshRequested', () {
      test('props are [city]', () {
        expect(WeatherRefreshRequested(city: 'city').props, ['city']);
      });
    });
  });
}

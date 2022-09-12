// ignore_for_file: prefer_const_constructors

import 'package:test/test.dart';
import 'package:weather_repository/weather_repository.dart';

void main() {
  group('Weather', () {
    test('can be (de)serialized', () {
      final weather = Weather(
        condition: WeatherCondition.cloudy,
        temperature: 10.2,
        location: 'Chicago',
      );
      expect(Weather.fromJson(weather.toJson()), equals(weather));
    });
  });
}

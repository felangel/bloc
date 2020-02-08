import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_weather/models/models.dart';

void main() {
  group('Weather', () {
    final weather = Weather(
      condition: WeatherCondition.clear,
      formattedCondition: 'Clear',
      minTemp: 15,
      maxTemp: 20,
      locationId: 0,
      location: 'Chicago',
      lastUpdated: DateTime(2019),
    );
    test('props are correct', () {
      expect(
        weather.props,
        [
          WeatherCondition.clear,
          'Clear',
          15,
          null,
          20,
          0,
          null,
          DateTime(2019),
          'Chicago',
        ],
      );
    });

    test('fromJson returns correct Weather', () {
      final json = {
        "consolidated_weather": [
          {
            "weather_state_name": "Clear",
            "created": "2019-02-10T19:55:02.434940Z",
            "min_temp": 3.75,
            "max_temp": 6.883333333333333,
          },
        ],
        "woeid": 0,
      };

      final actual = Weather.fromJson(json);
      expect(actual.locationId, 0);
      expect(actual.formattedCondition, 'Clear');
      expect(actual.minTemp, 3.75);
      expect(actual.maxTemp, 6.883333333333333);
    });
  });
}

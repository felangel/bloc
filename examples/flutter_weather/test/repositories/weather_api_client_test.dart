import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_weather/repositories/repositories.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';

class MockHttpClient extends Mock implements http.Client {}

class MockResponse extends Mock implements http.Response {}

void main() {
  group('WeatherApiClient', () {
    http.Client httpClient;
    WeatherApiClient weatherApiClient;

    setUp(() {
      httpClient = MockHttpClient();
      weatherApiClient = WeatherApiClient(httpClient: httpClient);
    });

    test('throws AssertionError when httpClient is null', () {
      expect(() => WeatherApiClient(httpClient: null), throwsAssertionError);
    });

    group('getLocationId', () {
      test('throws Exception when httpClient returns non-200 response',
          () async {
        final response = MockResponse();
        when(response.statusCode).thenReturn(500);
        when(
          httpClient.get(
            'https://www.metaweather.com/api/location/search/?query=chicago',
          ),
        ).thenAnswer((_) => Future.value(response));

        try {
          await weatherApiClient.getLocationId('chicago');
          fail('should throw');
        } catch (error) {
          expect(
            error.toString(),
            'Exception: error getting locationId for city',
          );
        }
      });

      test('returns locationId when httpClient returns 200', () async {
        final json = '''
        [
          {"woeid": 100}
        ]
        ''';
        final response = MockResponse();
        when(response.statusCode).thenReturn(200);
        when(response.body).thenReturn(json);
        when(
          httpClient.get(
            'https://www.metaweather.com/api/location/search/?query=chicago',
          ),
        ).thenAnswer((_) => Future.value(response));

        final locationId = await weatherApiClient.getLocationId('chicago');
        expect(locationId, 100);
      });
    });

    group('fetchWeather', () {
      test('throws Exception when httpClient returns non-200 response',
          () async {
        final response = MockResponse();
        when(response.statusCode).thenReturn(500);
        when(
          httpClient.get('https://www.metaweather.com/api/location/100'),
        ).thenAnswer((_) => Future.value(response));

        try {
          await weatherApiClient.fetchWeather(100);
          fail('should throw');
        } catch (error) {
          expect(
            error.toString(),
            'Exception: error getting weather for location',
          );
        }
      });

      test('returns Weather when httpClient returns 200', () async {
        final json = '''
        {
          "consolidated_weather": [
            {
              "weather_state_name": "Clear",
              "created": "2019-02-10T19:55:02.434940Z",
              "min_temp": 3.75,
              "max_temp": 6.883333333333333
            }
          ],
          "woeid": 100
        }
        ''';
        final response = MockResponse();
        when(response.statusCode).thenReturn(200);
        when(response.body).thenReturn(json);
        when(
          httpClient.get('https://www.metaweather.com/api/location/100'),
        ).thenAnswer((_) => Future.value(response));

        final weather = await weatherApiClient.fetchWeather(100);
        expect(weather.locationId, 100);
        expect(weather.formattedCondition, 'Clear');
        expect(weather.minTemp, 3.75);
        expect(weather.maxTemp, 6.883333333333333);
      });
    });
  });
}

# Flutter Weather Tutorial

![advanced](https://img.shields.io/badge/level-advanced-red.svg)

## Tutorial Goals

> In this tutorial, we're going to build a Weather app in Flutter which demonstrates how to manage multiple blocs to implement dynamic theming, pull-to-refresh, and much more. Our weather app will pull real data from an API and demonstrate how to separate our application into three layers (data, business logic, and presentation).

![demo](./assets/gifs/flutter_weather.gif)

### Project Requirements

- User can search for cities on the search page
- App displays weather information returned by [MetaWeather API](https://www.metaweather.com/api/)
- App theme changes depending on weather of the city
- Settings page which allows users to change units
- Persist state across sessions ([HydratedBloc](https://github.com/felangel/bloc/tree/master/packages/hydrated_bloc))

## Key Concepts

- Observe state changes with [BlocObserver](/coreconcepts?id=blocobserver).
- [BlocProvider](/flutterbloccoreconcepts?id=blocprovider), Flutter widget that provides a bloc to its children.
- [BlocBuilder](/flutterbloccoreconcepts?id=blocbuilder), Flutter widget that handles building the widget in response to new states.
- Prevent unnecessary rebuilds with [Equatable](/faqs?id=when-to-use-equatable).
- [RepositoryProvider](/flutterbloccoreconcepts?id=repositoryprovider), a Flutter widget that provides a repository to its children.
- [BlocListener](/flutterbloccoreconcepts?id=bloclistener), a Flutter widget that invokes the listener code in response to state changes in the bloc.
- [MultiBlocProvider](/flutterbloccoreconcepts?id=multiblocprovider), a Flutter widget that merges multiple BlocProvider widgets into one.
- [BlocConsumer](/flutterbloccoreconcepts?id=blocconsumer), a Flutter widget that exposes a builder and listener in order to react to new states.
- [HydratedBloc](https://github.com/felangel/bloc/tree/master/packages/hydrated_bloc) to manage and persist state

## Setup

To begin, create a new flutter project

[script](_snippets/flutter_weather_tutorial/flutter_create.sh.md ":include")

### Project Structure

> Our app will consist of isolated features in corresponding directories. This enables us to scale as the number of features increases and allows developers to work on different features in parallel.

Our app can be broken down into four main features: **search, settings, theme, weather**. Let's create those directories.

```
flutter_weather
|-- lib/
  |-- search/
  |-- settings/
  |-- theme/
  |-- weather/
  |-- main.dart
|-- test/
```

### Architecture

> Following the [bloc architecture](https://bloclibrary.dev/#/architecture) guidelines, our application will consist of several layers.

- **Data**: retrieve raw weather data from the API
- **Repository**: abstract the data layer and expose domain models for the application to consume
- **Business Logic**: manage the state of each feature (unit information, city details, themes, etc.)
- **Presentation**: display weather information and collect input from users (settings page, search page etc.)

## Data Layer

For this application we'll be hitting the [metaweather API](https://www.metaweather.com).

We'll be focusing on two endpoints:

- `/api/location/search/?query=$city` to get a locationId for a given city name
- `/api/location/$locationId` to get the weather for a given locationId

Open [https://www.metaweather.com/api/location/search/?query=london](https://www.metaweather.com/api/location/search/?query=london) in your browser to see the response for the city of London. We will use the `woeid` (where-on-earth-id) in the return dictionary to hit the location endpoint.

For example, the `woeid` for London is `44418`. Navigate to [https://www.metaweather.com/api/location/44418](https://www.metaweather.com/api/location/44418) in your browser and you'll see the response for weather in London which contains all the data we will need for our app.

### MetaWeather API Client

> Since the API client interacting MetaWeather is independent of the rest of our app, we can create it as a subpackage (or even publish it on [pub.dev](https://pub.dev)). We can then import the package in our `pubspec.yaml`.

Create a new directory on the project level called `packages`. This directory will store all of our internal packages.

Within this directory, run the built-in `flutter create` command to create a new package called `meta_weather_api` for our api client.

```bash
flutter create --template=package meta_weather_api
```

```
flutter_weather
|-- lib/
|-- test/
|-- packages/
  |-- meta_weather_api/
    |-- lib/
    |-- test/
```

### Weather Data Model

Next, let's create `location.dart` and `weather.dart` which will contain the models for the `location` and `weather` API endpoint responses.

```
flutter_weather
|-- lib/
|-- test/
|-- packages/
  |-- meta_weather_api/
    |-- lib/
      |-- src/
        |-- models/
          |-- location.dart
          |-- weather.dart
    |-- test/
```

#### Location Model

Let's work out of `location.dart`. Our location model should store data returned by the location API, which looks like the following:

```json
{
  "title": "London",
  "location_type": "City",
  "woeid": 44418,
  "latt_long": "51.506321,-0.12714"
}
```

Here's the in-progress `location.dart` file which stores the above response:

```dart
// packages/meta_weather_api/lib/src/models/location.dart (in progress)

enum LocationType {
  city,
  region,
  state,
  province,
  country,
  continent
}

class Location {
  const Location({
    required this.title,
    required this.locationType,
    required this.latLng,
    required this.woeid,
  });

  final String title;
  final LocationType locationType;
  final LatLng latLng;
  final int woeid;
}

class LatLng {
  const LatLng({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}

```

#### Weather Model

Next, let's work on `weather.dart`. Our weather model should store data returned by the weather API, which looks like the following:

```json
{
  "id": 5037922198749184,
  "weather_state_name": "Heavy Cloud",
  "weather_state_abbr": "hc",
  "wind_direction_compass": "SSE",
  "created": "2021-05-28T15:32:01.902125Z",
  "applicable_date": "2021-05-28",
  "min_temp": 9.61,
  "max_temp": 19.375,
  "the_temp": 18.54,
  "wind_speed": 3.0192401717198227,
  "wind_direction": 148.63313166521016,
  "air_pressure": 1023.0,
  "humidity": 57,
  "visibility": 10.56983466555317,
  "predictability": 71
}
```

Here's the in-progress `weather.dart` file which stores the above response:

```dart
// packages/meta_weather_api/lib/src/models/weather.dart (in progress)

enum WeatherState {
  snow,
  sleet,
  hail,
  thunderstorm,
  heavyRain,
  lightRain,
  showers,
  heavyCloud,
  lightCloud,
  clear,
  unknown
}

enum WindDirectionCompass {
  north,
  northEast,
  east,
  southEast,
  south,
  southWest,
  west,
  northWest,
  unknown
}

class Weather {
  const Weather({
    required this.id,
    required this.weatherStateName,
    required this.weatherStateAbbr,
    required this.windDirectionCompass,
    required this.created,
    required this.applicableDate,
    required this.minTemp,
    required this.maxTemp,
    required this.theTemp,
    required this.windSpeed,
    required this.windDirection,
    required this.airPressure,
    required this.humidity,
    required this.visibility,
    required this.predictability,
  });

  final int id;
  final String weatherStateName;
  final WeatherState weatherStateAbbr;
  final WindDirectionCompass windDirectionCompass;
  final DateTime created;
  final DateTime applicableDate;
  final double minTemp;
  final double maxTemp;
  final double theTemp;
  final double windSpeed;
  final double windDirection;
  final double airPressure;
  final int humidity;
  final double visibility;
  final int predictability;
}
```

### Barrel Files

While we're here, let's quickly create a [barrel file](https://adrianfaciu.dev/posts/barrel-files/) to clean up some of our imports down the road.

Create a `models.dart` barrel file

```
flutter_weather
|-- lib/
|-- test/
|-- packages/
  |-- meta_weather_api/
    |-- lib/
      |-- src/
        |-- models/
          |-- location.dart
          |-- weather.dart
          |-- models.dart
    |-- test/
```

In the file, export the two models

```dart
// packages/meta_weather_api/lib/src/models/models.dart (done)

export 'location.dart';
export 'weather.dart';
```

Let's also create a package level barrel file, `meta_weather_api.dart`

```
flutter_weather
|-- lib/
|-- test/
|-- packages/
  |-- meta_weather_api/
    |-- lib/
      |-- src/
        |-- models/
          |-- location.dart
          |-- weather.dart
          |-- models.dart
      |-- meta_weather_api.dart
    |-- test/
```

In the file, export what we've completed thus far:

```dart
// packages/meta_weather_api/lib/meta_weather_api.dart (in progress)

library meta_weather_api;

export 'src/models/models.dart';
```

### (De)Serialization

> In order for `HydratedBloc` to persist state across sessions, we need to be able to [serialize and deserialize](https://en.wikipedia.org/wiki/Serialization) our models. To do this, we will add `toJson` and `fromJson` methods to our models.

?> **Note**: For more information, see this [Medium article](https://medium.com/flutter-community/generate-the-code-to-parse-your-json-in-flutter-c68aa89a81d9).

We will be using the [json_annotation](https://pub.dev/package/json_annotation), [json_serializable](https://pub.dev/package/json_serializable), [build_runner](https://pub.dev/package/build_runner) packages to generate the `toJson` and `fromJson` implementations for us.

First, let's add these dependencies to the `pubspec.yaml`.

```yaml
# packages/meta_weather_api/pubspec.yaml (in progress)
name: meta_weather_api
description: A Dart API Client for the MetaWeather API.
version: 1.0.0+1

environment:
  sdk: ">=2.12.0 <3.0.0"

dependencies:
  json_annotation: ^4.0.0

dev_dependencies:
  build_runner: ^1.10.0
  json_serializable: ^4.0.0
```

?> **Note**: Remember to run `flutter packages get` after adding the dependencies.

In order for code generation to work, we need to annotate our code using the following:

- `@JsonSerializable` to label classes which can be serialized
- `@JsonKey` to provide string representations of field names
- `@JsonValue` to provide string representations of field values
- Implement `JSONConverter` to convert object representations into JSON representations

For each file we also need to:

- Import `json_annotation`
- Include the generated code using the [part](https://stackoverflow.com/questions/27763378/when-to-use-part-part-of-versus-import-export-in-dart/36433664) keyword
- Include `fromJson` methods for deserialization

#### Location Model

Here is our complete `location.dart` model file:

```dart
// packages/meta_weather_api/lib/models/location.dart (done)

import 'package:json_annotation/json_annotation.dart';

part 'location.g.dart';

enum LocationType {
  @JsonValue('City')
  city,
  @JsonValue('Region')
  region,
  @JsonValue('State')
  state,
  @JsonValue('Province')
  province,
  @JsonValue('Country')
  country,
  @JsonValue('Continent')
  continent
}

@JsonSerializable()
class Location {
  const Location({
    required this.title,
    required this.locationType,
    required this.latLng,
    required this.woeid,
  });

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);

  final String title;

  final LocationType locationType;

  @JsonKey(name: 'latt_long')
  @LatLngConverter()
  final LatLng latLng;

  final int woeid;
}

class LatLng {
  const LatLng({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}

class LatLngConverter implements JsonConverter<LatLng, String> {
  const LatLngConverter();

  @override
  String toJson(LatLng latLng) {
    return '${latLng.latitude},${latLng.longitude}';
  }

  @override
  LatLng fromJson(String jsonString) {
    final parts = jsonString.split(',');
    return LatLng(
      latitude: double.tryParse(parts[0]) ?? 0,
      longitude: double.tryParse(parts[1]) ?? 0,
    );
  }
}
```

#### Weather Model

Here is our complete `weather.dart` model file:

```dart
// packages/meta_weather_api/lib/models/weather.dart (done)

import 'package:json_annotation/json_annotation.dart';

part 'weather.g.dart';

enum WeatherState {
  @JsonValue('sn')
  snow,
  @JsonValue('sl')
  sleet,
  @JsonValue('h')
  hail,
  @JsonValue('t')
  thunderstorm,
  @JsonValue('hr')
  heavyRain,
  @JsonValue('lr')
  lightRain,
  @JsonValue('s')
  showers,
  @JsonValue('hc')
  heavyCloud,
  @JsonValue('lc')
  lightCloud,
  @JsonValue('c')
  clear,
  unknown
}

extension WeatherStateX on WeatherState {
  String? get abbr => _$WeatherStateEnumMap[this];
}

enum WindDirectionCompass {
  @JsonValue('N')
  north,
  @JsonValue('NE')
  northEast,
  @JsonValue('E')
  east,
  @JsonValue('SE')
  southEast,
  @JsonValue('S')
  south,
  @JsonValue('SW')
  southWest,
  @JsonValue('W')
  west,
  @JsonValue('NW')
  northWest,
  unknown,
}

@JsonSerializable()
class Weather {
  const Weather({
    required this.id,
    required this.weatherStateName,
    required this.weatherStateAbbr,
    required this.windDirectionCompass,
    required this.created,
    required this.applicableDate,
    required this.minTemp,
    required this.maxTemp,
    required this.theTemp,
    required this.windSpeed,
    required this.windDirection,
    required this.airPressure,
    required this.humidity,
    required this.visibility,
    required this.predictability,
  });

  factory Weather.fromJson(Map<String, dynamic> json) =>
      _$WeatherFromJson(json);

  final int id;

  final String weatherStateName;

  @JsonKey(unknownEnumValue: WeatherState.unknown)
  final WeatherState weatherStateAbbr;

  @JsonKey(unknownEnumValue: WindDirectionCompass.unknown)
  final WindDirectionCompass windDirectionCompass;

  final DateTime created;

  final DateTime applicableDate;

  final double minTemp;

  final double maxTemp;

  final double theTemp;

  final double windSpeed;

  final double windDirection;

  final double airPressure;

  final int humidity;

  final double visibility;

  final int predictability;
}
```

#### Code Generation

Let's use `build_runner` to generate the code.

```bash
flutter packages pub run build_runner build
```

`build_runner` should generate the `location.g.dart` and `weather.g.dart` files. Your directory should now look like this:

```
flutter_weather
|-- lib/
|-- test/
|-- packages/
  |-- meta_weather_api/
    |-- lib/
      |-- src/
        |-- models/
          |-- location.dart
          |-- location.g.dart
          |-- weather.dart
          |-- weather.g.dart
          |-- models.dart
      |-- meta_weather_api.dart
    |-- test/
```

### MetaWeather API Client

Let's create our API client in the file `meta_weather_api_client.dart`. Our project structure should now look like this:

```
flutter_weather
|-- lib/
|-- test/
|-- packages/
  |-- meta_weather_api/
    |-- lib/
      |-- src/
        |-- models/
          |-- location.dart
          |-- location.g.dart
          |-- weather.dart
          |-- weather.g.dart
          |-- models.dart
        |-- meta_weather_api_client.dart
      |-- meta_weather_api.dart
    |-- test/
```

We will also need to import the [http](https://pub.dev/packages/http) package. In your `packages/meta_weather_api/pubspec.yaml` file, add `http` to your list of dependencies. Your updated file should look like this:

```yaml
# packages/meta_weather_api/pubspec.yaml (in progress)
name: meta_weather_api
description: A Dart API Client for the MetaWeather API.
version: 1.0.0+1

environment:
  sdk: ">=2.12.0 <3.0.0"

dependencies:
  http: ^0.13.0
  json_annotation: ^4.0.0

dev_dependencies:
  coverage: ^0.14.1
  build_runner: ^1.10.0
  json_serializable: ^4.0.0
```

?> **Note**: Make sure to run `flutter pub get` after saving the file.

Our API client will expose two methods:

- `locationSearch` which returns a `Future<Location>`
- `getWeather` which returns a `Future<Weather>`

```dart
// packages/meta_weather_api/lib/src/meta_weather_api_client.dart (in progress)
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:meta_weather_api/meta_weather_api.dart';

/// Exception thrown when locationSearch fails.
class LocationIdRequestFailure implements Exception {}

/// Exception thrown when getWeather fails.
class WeatherRequestFailure implements Exception {}

/// {@template meta_weather_api_client}
/// Dart API Client which wraps the [MetaWeather API](https://www.metaweather.com/api/).
/// {@endtemplate}
class MetaWeatherApiClient {
  /// {@macro meta_weather_api_client}
  MetaWeatherApiClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  static const _baseUrl = 'www.metaweather.com';
  final http.Client _httpClient;

  /// Finds a [Location] `/api/location/search/?query=(query)`.
  Future<Location> locationSearch(String query) async {
    // TODO
  }

  /// Fetches [Weather] for a given [locationId].
  Future<Weather> getWeather(int locationId) async {
    // TODO
  }
}
```

#### Location Search

The `locationSearch` method hits the location API and throws `LocationIdRequestFailiure` errors as applicable. The completed method looks as follows:

```dart
/// Finds a [Location] `/api/location/search/?query=(query)`.
Future<Location> locationSearch(String query) async {
  final locationRequest = Uri.https(
    _baseUrl,
    '/api/location/search',
    <String, String>{'query': query},
  );
  final locationResponse = await _httpClient.get(locationRequest);

  if (locationResponse.statusCode != 200) {
    throw LocationIdRequestFailure();
  }

  final locationJson = jsonDecode(
    locationResponse.body,
  ) as List;

  if (locationJson.isEmpty) {
    throw LocationIdRequestFailure();
  }

  return Location.fromJson(locationJson.first as Map<String, dynamic>);
}
```

#### Get Weather

Similarly, the `getWeather` method hits the weather API and throws `WeatherRequestFailiure` errors as applicable. The completed method looks as follows:

```dart
/// Fetches [Weather] for a given [locationId].
Future<Weather> getWeather(int locationId) async {
  final weatherRequest = Uri.https(_baseUrl, '/api/location/$locationId');
  final weatherResponse = await _httpClient.get(weatherRequest);

  if (weatherResponse.statusCode != 200) {
    throw WeatherRequestFailure();
  }

  final weatherJson = jsonDecode(
    weatherResponse.body,
  )['consolidated_weather'] as List;

  if (weatherJson.isEmpty) {
    throw WeatherRequestFailure();
  }

  return Weather.fromJson(weatherJson.first as Map<String, dynamic>);
}
```

The completed file looks like this:

```dart
// packages/meta_weather_api/lib/src/meta_weather_api_client.dart (done)

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:meta_weather_api/meta_weather_api.dart';

/// Exception thrown when locationSearch fails.
class LocationIdRequestFailure implements Exception {}

/// Exception thrown when getWeather fails.
class WeatherRequestFailure implements Exception {}

/// {@template meta_weather_api_client}
/// Dart API Client which wraps the [MetaWeather API](https://www.metaweather.com/api/).
/// {@endtemplate}
class MetaWeatherApiClient {
  /// {@macro meta_weather_api_client}
  MetaWeatherApiClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  static const _baseUrl = 'www.metaweather.com';
  final http.Client _httpClient;

  /// Finds a [Location] `/api/location/search/?query=(query)`.
  Future<Location> locationSearch(String query) async {
    final locationRequest = Uri.https(
      _baseUrl,
      '/api/location/search',
      <String, String>{'query': query},
    );
    final locationResponse = await _httpClient.get(locationRequest);

    if (locationResponse.statusCode != 200) {
      throw LocationIdRequestFailure();
    }

    final locationJson = jsonDecode(
      locationResponse.body,
    ) as List;

    if (locationJson.isEmpty) {
      throw LocationIdRequestFailure();
    }

    return Location.fromJson(locationJson.first as Map<String, dynamic>);
  }

  /// Fetches [Weather] for a given [locationId].
  Future<Weather> getWeather(int locationId) async {
    final weatherRequest = Uri.https(_baseUrl, '/api/location/$locationId');
    final weatherResponse = await _httpClient.get(weatherRequest);

    if (weatherResponse.statusCode != 200) {
      throw WeatherRequestFailure();
    }

    final weatherJson = jsonDecode(
      weatherResponse.body,
    )['consolidated_weather'] as List;

    if (weatherJson.isEmpty) {
      throw WeatherRequestFailure();
    }

    return Weather.fromJson(weatherJson.first as Map<String, dynamic>);
  }
}
```

#### Barrel File Updates

Let's wrap up this package by adding our API client to the barrel file.

```dart
// packages/meta_weather_api/lib/meta_weather_api.dart (done)

library meta_weather_api;

export 'src/meta_weather_api_client.dart';
export 'src/models/models.dart';
```

### Unit Tests

> Let's unit test our data models, `location` and `weather`. We should focus on ensuring that they can represent our data, translate to and from json, and handle edge cases.

#### Setup

Add the [test](https://pub.dev/packages/test) package to the `pubspec.yaml` and run `flutter pub get`.

```yaml
# packages/meta_weather_api/pubspec.yaml (in progress)
name: meta_weather_api
description: A Dart API Client for the MetaWeather API.
version: 1.0.0+1

environment:
  sdk: ">=2.12.0 <3.0.0"

dependencies:
  json_annotation: ^4.0.0

dev_dependencies:
  build_runner: ^1.10.0
  json_serializable: ^4.0.0
  test: ^1.16.4
```

```
flutter_weather
|-- lib/
|-- test/
|-- packages/
  |-- meta_weather_api/
    |-- lib/
      |-- src/
        |-- models/
          |-- location.dart
          |-- location.g.dart
          |-- weather.dart
          |-- weather.g.dart
          |-- models.dart
        |-- meta_weather_api_client.dart
      |-- meta_weather_api.dart
    |-- test/
      |-- location_test.dart
      |-- weather_test.dart
```

#### Location Tests

```dart
// packages/meta_weather_api/test/location_test.dart (done)

import 'package:json_annotation/json_annotation.dart';
import 'package:meta_weather_api/meta_weather_api.dart';
import 'package:test/test.dart';

void main() {
  group('Location', () {
    group('fromJson', () {
      test('throws CheckedFromJsonException when enum is unknown', () {
        expect(
          () => Location.fromJson(<String, dynamic>{
            'title': 'mock-title',
            'location_type': 'Unknown',
            'latt_long': '-34.75,83.28',
            'woeid': 42
          }),
          throwsA(isA<CheckedFromJsonException>()),
        );
      });
    });
  });
}
```

#### Weather Tests

```dart
// packages/meta_weather_api/test/weather_test.dart (done)

import 'package:meta_weather_api/meta_weather_api.dart';
import 'package:test/test.dart';

void main() {
  group('Weather', () {
    group('fromJson', () {
      test(
          'returns WeatherState.unknown '
          'for unsupported weather_state_abbr', () {
        expect(
          Weather.fromJson(<String, dynamic>{
            'id': 4907479830888448,
            'weather_state_name': 'UNKNOWN',
            'weather_state_abbr': '-',
            'wind_direction_compass': 'UNKNOWN',
            'created': '2020-10-26T00:20:01.840132Z',
            'applicable_date': '2020-10-26',
            'min_temp': 7.9399999999999995,
            'max_temp': 13.239999999999998,
            'the_temp': 12.825,
            'wind_speed': 7.876886316914553,
            'wind_direction': 246.17046093256732,
            'air_pressure': 997.0,
            'humidity': 73,
            'visibility': 11.037727173307882,
            'predictability': 73
          }),
          isA<Weather>().having(
            (w) => w.weatherStateAbbr,
            'abbr',
            WeatherState.unknown,
          ),
        );
      });
    });

    group('WeatherStateX', () {
      const weatherState = WeatherState.showers;
      test('abbr returns correct string abbreviation', () {
        expect(weatherState.abbr, 's');
      });
    });
  });
}
```

#### API Client Tests

Next, let's test our API client. We should test to ensure that our API client handles both API calls correctly, including edge cases.

?> **Note**: We don't want our tests to make real API calls since our goal is to test the API client logic (including all edge cases) and not the API itself. In order to have a consistent, controlled test environment, we will use [mocktail](https://github.com/felangel/mocktail) to mock the `http` client.

##### Setup

```yaml
# packages/meta_weather_api/pubspec.yaml (in progress)
name: meta_weather_api
description: A Dart API Client for the MetaWeather API.
version: 1.0.0+1

environment:
  sdk: ">=2.12.0 <3.0.0"

dependencies:
  json_annotation: ^4.0.0

dev_dependencies:
  build_runner: ^1.10.0
  json_serializable: ^4.0.0
  mocktail: ^0.1.0
  test: ^1.16.4
```

```
flutter_weather
|-- lib/
|-- test/
|-- packages/
  |-- meta_weather_api/
    |-- lib/
      |-- src/
        |-- models/
          |-- location.dart
          |-- location.g.dart
          |-- weather.dart
          |-- weather.g.dart
          |-- models.dart
        |-- meta_weather_api_client.dart
      |-- meta_weather_api.dart
    |-- test/
      |-- location_test.dart
      |-- weather_test.dart
      |-- meta_weather_api_client_test.dart
```

##### Tests

```dart
// packages/meta_weather_api/test/meta_weather_api_client_test.dart (done)
import 'package:http/http.dart' as http;
import 'package:meta_weather_api/meta_weather_api.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockHttpClient extends Mock implements http.Client {}

class MockResponse extends Mock implements http.Response {}

class FakeUri extends Fake implements Uri {}

void main() {
  group('MetaWeatherApiClient', () {
    late http.Client httpClient;
    late MetaWeatherApiClient metaWeatherApiClient;

    setUpAll(() {
      registerFallbackValue<Uri>(FakeUri());
    });

    setUp(() {
      httpClient = MockHttpClient();
      metaWeatherApiClient = MetaWeatherApiClient(httpClient: httpClient);
    });

    group('constructor', () {
      test('does not require an httpClient', () {
        expect(MetaWeatherApiClient(), isNotNull);
      });
    });

    group('locationSearch', () {
      const query = 'mock-query';
      test('makes correct http request', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn('[]');
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        await metaWeatherApiClient.locationSearch(query);
        verify(
          () => httpClient.get(
            Uri.https(
              'www.metaweather.com',
              '/api/location/search',
              <String, String>{'query': query},
            ),
          ),
        ).called(1);
      });

      test('throws LocationIdRequestFailure on non-200 response', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(400);
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        expect(
          () async => await metaWeatherApiClient.locationSearch(query),
          throwsA(isA<LocationIdRequestFailure>()),
        );
      });

      test('returns null on empty response', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn('[]');
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        final actual = await metaWeatherApiClient.locationSearch(query);
        expect(actual, isNull);
      });

      test('returns Location on valid response', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn(
          '''[{
            "title": "mock-title",
            "location_type": "City",
            "latt_long": "-34.75,83.28",
            "woeid": 42
          }]''',
        );
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        final actual = await metaWeatherApiClient.locationSearch(query);
        expect(
          actual,
          isA<Location>()
              .having((l) => l.title, 'title', 'mock-title')
              .having((l) => l.locationType, 'type', LocationType.city)
              .having(
                (l) => l.latLng,
                'latLng',
                isA<LatLng>()
                    .having((c) => c.latitude, 'latitude', -34.75)
                    .having((c) => c.longitude, 'longitude', 83.28),
              )
              .having((l) => l.woeid, 'woeid', 42),
        );
      });
    });

    group('getWeather', () {
      const locationId = 42;

      test('makes correct http request', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn('{}');
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        await metaWeatherApiClient.getWeather(locationId);
        verify(
          () => httpClient.get(
            Uri.https('www.metaweather.com', '/api/location/$locationId'),
          ),
        ).called(1);
      });

      test('throws WeatherRequestFailure on non-200 response', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(400);
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        expect(
          () async => await metaWeatherApiClient.getWeather(locationId),
          throwsA(isA<WeatherRequestFailure>()),
        );
      });

      test('returns weather on valid respponse', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn('''
          {"consolidated_weather":[{
            "id":4907479830888448,
            "weather_state_name":"Showers",
            "weather_state_abbr":"s",
            "wind_direction_compass":"SW",
            "created":"2020-10-26T00:20:01.840132Z",
            "applicable_date":"2020-10-26",
            "min_temp":7.9399999999999995,
            "max_temp":13.239999999999998,
            "the_temp":12.825,
            "wind_speed":7.876886316914553,
            "wind_direction":246.17046093256732,
            "air_pressure":997.0,
            "humidity":73,
            "visibility":11.037727173307882,
            "predictability":73
          }]}
        ''');
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        final actual = await metaWeatherApiClient.getWeather(locationId);
        expect(
          actual,
          isA<Weather>()
              .having((w) => w.id, 'id', 4907479830888448)
              .having((w) => w.weatherStateName, 'state', 'Showers')
              .having((w) => w.weatherStateAbbr, 'abbr', WeatherState.showers)
              .having((w) => w.windDirectionCompass, 'wind',
                  WindDirectionCompass.southWest)
              .having((w) => w.created, 'created',
                  DateTime.parse('2020-10-26T00:20:01.840132Z'))
              .having((w) => w.applicableDate, 'applicableDate',
                  DateTime.parse('2020-10-26'))
              .having((w) => w.minTemp, 'minTemp', 7.9399999999999995)
              .having((w) => w.maxTemp, 'maxTemp', 13.239999999999998)
              .having((w) => w.theTemp, 'theTemp', 12.825)
              .having((w) => w.windSpeed, 'windSpeed', 7.876886316914553)
              .having(
                  (w) => w.windDirection, 'windDirection', 246.17046093256732)
              .having((w) => w.airPressure, 'airPressure', 997.0)
              .having((w) => w.humidity, 'humidity', 73)
              .having((w) => w.visibility, 'visibility', 11.037727173307882)
              .having((w) => w.predictability, 'predictability', 73),
        );
      });
    });
  });
}
```

##### Test Coverage

Finally, let's gather test coverage to verify that we've covered each line of code with at least one test case.

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage
open coverage/index.html
```

## Repository Layer

> The goal of our repository layer is to abstract our data layer and facilitate communication with the bloc layer. In doing this, the rest of our code base depends only on functions exposed by our repository layer instead of specific data provider implementations. This allows us to change data providers without disrupting any of the application-level code. For example, if we decide to migrate away from metaweather, we should be able to create a new API client and swap it out without having to make changes to the public API of the repository or application layers.

### Setup

Inside the packages directory, run the following command:

```
flutter create --template=package weather_repository
```

The directory structure should look like this:

```
flutter_weather
|-- lib/
|-- test/
|-- packages/
  |-- meta_weather_api/
  |-- weather_repository
    |-- lib/
    |-- test/
```

We will use the same packages as in the `meta_weather_api` package including the `meta_weather_api` package from the last step. Update your `pubspec.yaml` and run `flutter packages get`.

?> **Note**: We're using a `path` to specify the location of the `meta_weather_api` which allows us to treat it just like an external package from `pub.dev`.

```yaml
# packages/weather_repository/pubspec.yaml (done)
name: weather_repository
description: A Dart Repository which manages the weather domain.
version: 1.0.0+1
publish_to: none

environment:
  sdk: ">=2.12.0 <3.0.0"

dependencies:
  equatable: ^2.0.0
  json_annotation: ^4.0.0
  meta_weather_api:
    path: ../meta_weather_api

dev_dependencies:
  coverage: ^0.14.1
  build_runner: ^1.10.0
  json_serializable: ^4.0.0
  mocktail: ^0.1.0
  test: ^1.16.4
```

### Weather Repository Models

> We will be creating a new `weather.dart` file to expose a domain-specific weather model. This model will contain only data relevant to our business cases -- in other words it should be completely decoupled from the API client and raw data format. As usual, we will also create a `models.dart` barrel file.

```
flutter_weather
|-- lib/
|-- test/
|-- packages/
  |-- meta_weather_api/
  |-- weather_repository/
    |-- lib/
      |-- src/
        |-- models/
          |-- models.dart
          |-- weather.dart
    |-- test/
```

This time, our weather model will only store the `location, temperature, condition` properties. We will also continue to annotate our code to allow for serialization and deserialization.

```dart
// packages/weather_repository/lib/src/models/weather.dart (done)
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'weather.g.dart';

enum WeatherCondition {
  clear,
  rainy,
  cloudy,
  snowy,
  unknown,
}

@JsonSerializable()
class Weather extends Equatable {
  const Weather({
    required this.location,
    required this.temperature,
    required this.condition,
  });

  factory Weather.fromJson(Map<String, dynamic> json) =>
      _$WeatherFromJson(json);

  Map<String, dynamic> toJson() => _$WeatherToJson(this);

  final String location;
  final double temperature;
  final WeatherCondition condition;

  @override
  List<Object> get props => [location, temperature, condition];
}
```

```dart
// packages/weather_repository/lib/src/models/models.dart (done)

export 'weather.dart';
```

#### Code Generation

As we have done previously, run the following command to generate the (de)serialization implementation.

```
flutter packages pub run build_runner build
```

#### Barrel File

Let's also create a package-level barrel file to export our models.

```
flutter_weather
|-- lib/
|-- test/
|-- packages/
  |-- meta_weather_api/
  |-- weather_repository/
    |-- lib/
      |-- src/
        |-- models/
          |-- models.dart
          |-- weather.dart
      |-- weather_repository.dart
    |-- test/
```

```dart
// packages/weather_repository/lib/weather_repository.dart (in progress)

library weather_repository;

export 'src/models/models.dart';
```

### Weather Repository

> The main goal of our weather repository is to provide an interface which abstracts the data provider. In this case, the `WeatherRepository` will have a dependency on the `WeatherApiClient` and expose a single public method, `getWeather(String city)`.

?> **Note**: Consumers of the `WeatherRepository` are not privy to the underlying implementation details such as the fact that two network requests are made to the metaweather API. The goal of the `WeatherRepository` is to separate the "what" from the "how" -- in other words, we want to have a way to fetch weather for a given city, but don't care about how or where that data is coming from.

#### Setup

```
flutter_weather
|-- lib/
|-- test/
|-- packages/
  |-- meta_weather_api/
  |-- weather_repository/
    |-- lib/
      |-- src/
        |-- models/
          |-- models.dart
          |-- weather.dart
        |-- weather_repository.dart
      |-- weather_repository.dart
    |-- test/
```

Create another `weather_repository.dart` file within the source code folder of our package.

```dart
// packages/weather_repository/lib/src/weather_repository.dart (in progress)
import 'dart:async';

import 'package:meta_weather_api/meta_weather_api.dart' hide Weather;
import 'package:weather_repository/weather_repository.dart';

class WeatherFailure implements Exception {}

class WeatherRepository {
  WeatherRepository({MetaWeatherApiClient? weatherApiClient})
      : _weatherApiClient = weatherApiClient ?? MetaWeatherApiClient();

  final MetaWeatherApiClient _weatherApiClient;

  Future<Weather> getWeather(String city) async {
    // TODO
  }
}

extension on WeatherState {
  WeatherCondition get toCondition {
    switch (this) {
      case WeatherState.clear:
        return WeatherCondition.clear;
      case WeatherState.snow:
      case WeatherState.sleet:
      case WeatherState.hail:
        return WeatherCondition.snowy;
      case WeatherState.thunderstorm:
      case WeatherState.heavyRain:
      case WeatherState.lightRain:
      case WeatherState.showers:
        return WeatherCondition.rainy;
      case WeatherState.heavyCloud:
      case WeatherState.lightCloud:
        return WeatherCondition.cloudy;
      default:
        return WeatherCondition.unknown;
    }
  }
}
```

The main method we will focus on is `getWeather(String city)`. We can implement it using two calls to the API client as follows:

```dart
Future<Weather> getWeather(String city) async {
  final location = await _weatherApiClient.locationSearch(city);
  final woeid = location.woeid;
  final weather = await _weatherApiClient.getWeather(woeid);
  return Weather(
    temperature: weather.theTemp,
    location: location.title,
    condition: weather.weatherStateAbbr.toCondition,
  );
}
```

The completed file looks like this:

```dart
// packages/weather_repository/lib/src/weather_repository.dart (done)
import 'dart:async';

import 'package:meta_weather_api/meta_weather_api.dart' hide Weather;
import 'package:weather_repository/weather_repository.dart';

class WeatherFailure implements Exception {}

class WeatherRepository {
  WeatherRepository({MetaWeatherApiClient? weatherApiClient})
      : _weatherApiClient = weatherApiClient ?? MetaWeatherApiClient();

  final MetaWeatherApiClient _weatherApiClient;

  Future<Weather> getWeather(String city) async {
    final location = await _weatherApiClient.locationSearch(city);
    final woeid = location.woeid;
    final weather = await _weatherApiClient.getWeather(woeid);
    return Weather(
      temperature: weather.theTemp,
      location: location.title,
      condition: weather.weatherStateAbbr.toCondition,
    );
  }
}

extension on WeatherState {
  WeatherCondition get toCondition {
    switch (this) {
      case WeatherState.clear:
        return WeatherCondition.clear;
      case WeatherState.snow:
      case WeatherState.sleet:
      case WeatherState.hail:
        return WeatherCondition.snowy;
      case WeatherState.thunderstorm:
      case WeatherState.heavyRain:
      case WeatherState.lightRain:
      case WeatherState.showers:
        return WeatherCondition.rainy;
      case WeatherState.heavyCloud:
      case WeatherState.lightCloud:
        return WeatherCondition.cloudy;
      default:
        return WeatherCondition.unknown;
    }
  }
}
```

#### Barrel File

Update the barrel file we created previously.

```dart
// packages/weather_repository/lib/weather_repository.dart (done)

library weather_repository;

export 'src/models/models.dart';
export 'src/weather_repository.dart';
```

### Unit Tests

> To test our `WeatherRepository`, we will use the [mocktail](https://github.com/felangel/mocktail) library. We will mock the underlying api client in order to unit test the `WeatherRepository` logic in an isolated, controlled environment.

Here is an example test suite:

```dart
// packages/weather_repository/test/weather_repository.dart
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
```

## Business Logic Layer

> In the business logic layer, we will be consuming the weather domain model from the `WeatherRepository` and exposing a feature-level model which will be surfaced to the user via the UI.

?> **Note**: We have implemented three different types of weather models. In the API client, our weather model contained all the info returned by the API. In the repository layer, our weather model contained only the abstracted model based on our business case. In this layer, our weather model will contain relevant information needed specifically for the current feature set.

### Setup

Let's update our project-level dependencies.

```yaml
# pubspec.yaml (in progress)
name: flutter_weather
description: A new Flutter project.
version: 1.0.0+1
publish_to: none

environment:
  sdk: ">=2.12.0 <3.0.0"

dependencies:
  flutter:
    sdk: flutter
  equatable: ^2.0.0
  json_annotation: ^4.0.0
  weather_repository:
    path: packages/weather_repository

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^1.10.0
  json_serializable: ^4.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/
```

We will be working in the main flutter application within the `weather` feature (directory).

```
flutter_weather
|-- lib/
  |-- weather/
    |-- models/
      |-- models.dart
      |-- weather.dart
```

### Weather Model

The goal of our weather model is to keep track of weather data displayed by our app, as well as temperature settings (Celsius or Fahrenheit).

```dart
// lib/weather/models/weather.dart (in progress)

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:weather_repository/weather_repository.dart' hide Weather;
import 'package:weather_repository/weather_repository.dart'
    as weather_repository;

part 'weather.g.dart';

enum TemperatureUnits { fahrenheit, celsius }

extension TemperatureUnitsX on TemperatureUnits {
  bool get isFahrenheit => this == TemperatureUnits.fahrenheit;
  bool get isCelsius => this == TemperatureUnits.celsius;
}

@JsonSerializable()
class Temperature extends Equatable {
  const Temperature({required this.value});

  factory Temperature.fromJson(Map<String, dynamic> json) =>
      _$TemperatureFromJson(json);

  final double value;

  Map<String, dynamic> toJson() => _$TemperatureToJson(this);

  @override
  List<Object> get props => [value];
}
```

Next, implement the weather model to incorporate this temperature model.

```dart
// lib/weather/models/weather.dart (done)
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:weather_repository/weather_repository.dart' hide Weather;
import 'package:weather_repository/weather_repository.dart'
    as weather_repository;

part 'weather.g.dart';

enum TemperatureUnits { fahrenheit, celsius }

extension TemperatureUnitsX on TemperatureUnits {
  bool get isFahrenheit => this == TemperatureUnits.fahrenheit;
  bool get isCelsius => this == TemperatureUnits.celsius;
}

@JsonSerializable()
class Temperature extends Equatable {
  const Temperature({required this.value});

  factory Temperature.fromJson(Map<String, dynamic> json) =>
      _$TemperatureFromJson(json);

  final double value;

  Map<String, dynamic> toJson() => _$TemperatureToJson(this);

  @override
  List<Object> get props => [value];
}

@JsonSerializable()
class Weather extends Equatable {
  const Weather({
    required this.condition,
    required this.lastUpdated,
    required this.location,
    required this.temperature,
  });

  factory Weather.fromJson(Map<String, dynamic> json) =>
      _$WeatherFromJson(json);

  factory Weather.fromRepository(weather_repository.Weather weather) {
    return Weather(
      condition: weather.condition,
      lastUpdated: DateTime.now(),
      location: weather.location,
      temperature: Temperature(value: weather.temperature),
    );
  }

  static final empty = Weather(
    condition: WeatherCondition.unknown,
    lastUpdated: DateTime(0),
    temperature: const Temperature(value: 0),
    location: '--',
  );

  final WeatherCondition condition;
  final DateTime lastUpdated;
  final String location;
  final Temperature temperature;

  @override
  List<Object> get props => [condition, lastUpdated, location, temperature];

  Map<String, dynamic> toJson() => _$WeatherToJson(this);

  Weather copyWith({
    WeatherCondition? condition,
    DateTime? lastUpdated,
    String? location,
    Temperature? temperature,
  }) {
    return Weather(
      condition: condition ?? this.condition,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      location: location ?? this.location,
      temperature: temperature ?? this.temperature,
    );
  }
}
```

### Code Generation

Run `build_runner` to generate the (de)serialization implementations.

```bash
flutter packages pub run build_runner build
```

### Barrel File

Let's export our models from the barrel file:

```dart
// lib/weather/models/models.dart (done)
export 'weather.dart';
```

### Weather

We will use `HydratedCubit` to manage the weather state.

?> **Note**: `HydratedCubit` is an extension of `Cubit` which handles persisting and restoring state across sessions.

#### Weather State

Using the [Bloc VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc) or [Bloc IntelliJ](https://plugins.jetbrains.com/plugin/12129-bloc) extension, right click on the `weather` directory and create a new cubit called `Weather`. The project structure should look like this:

```
flutter_weather
|-- lib/
  |-- weather/
    |-- cubit/
      |-- weather_cubit.dart
      |-- weather_state.dart
```

There are four states our weather app can be in:

- `initial` (before anything loads)
- `loading` (during the API call)
- `success` (if the API call is successful)
- `failure` (if the API call is unsuccessful)

The `WeatherStatus` enum will represent the above.

The complete weather state should look like this:

```dart
// lib/weather/cubit/weather_state.dart (done)
part of 'weather_cubit.dart';

enum WeatherStatus { initial, loading, success, failure }

extension WeatherStatusX on WeatherStatus {
  bool get isInitial => this == WeatherStatus.initial;
  bool get isLoading => this == WeatherStatus.loading;
  bool get isSuccess => this == WeatherStatus.success;
  bool get isFailure => this == WeatherStatus.failure;
}

@JsonSerializable()
class WeatherState extends Equatable {
  WeatherState({
    this.status = WeatherStatus.initial,
    this.temperatureUnits = TemperatureUnits.celsius,
    Weather? weather,
  }) : weather = weather ?? Weather.empty;

  factory WeatherState.fromJson(Map<String, dynamic> json) =>
      _$WeatherStateFromJson(json);

  final WeatherStatus status;
  final Weather weather;
  final TemperatureUnits temperatureUnits;

  WeatherState copyWith({
    WeatherStatus? status,
    TemperatureUnits? temperatureUnits,
    Weather? weather,
  }) {
    return WeatherState(
      status: status ?? this.status,
      temperatureUnits: temperatureUnits ?? this.temperatureUnits,
      weather: weather ?? this.weather,
    );
  }

  Map<String, dynamic> toJson() => _$WeatherStateToJson(this);

  @override
  List<Object?> get props => [status, temperatureUnits, weather];
}
```

#### Weather Cubit

Now that we've defined the `WeatherState`, let's write the `WeatherCubit` which will expose the following methods:

- `fetchWeather(String? city)` uses our weather repository to try and retrieve a weather object for the given city
- `refreshWeather()` retrieves a new weather object using the weather repository given the current weather state
- `toggleUnits()` toggles the state between Celsius and Fahrenheit
- `fromJson(Map<String, dynamic> json)`, `toJson(WeatherState state)` used for persistence

```dart
// lib/weather/cubit/weather_cubit.dart (done)

import 'package:equatable/equatable.dart';
import 'package:flutter_weather/weather/weather.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:weather_repository/weather_repository.dart'
    show WeatherRepository;

part 'weather_cubit.g.dart';
part 'weather_state.dart';

class WeatherCubit extends HydratedCubit<WeatherState> {
  WeatherCubit(this._weatherRepository) : super(WeatherState());

  final WeatherRepository _weatherRepository;

  Future<void> fetchWeather(String? city) async {
    if (city == null || city.isEmpty) return;

    emit(state.copyWith(status: WeatherStatus.loading));

    try {
      final weather = Weather.fromRepository(
        await _weatherRepository.getWeather(city),
      );
      final units = state.temperatureUnits;
      final value = units.isFahrenheit
          ? weather.temperature.value.toFahrenheit()
          : weather.temperature.value;

      emit(
        state.copyWith(
          status: WeatherStatus.success,
          temperatureUnits: units,
          weather: weather.copyWith(temperature: Temperature(value: value)),
        ),
      );
    } on Exception {
      emit(state.copyWith(status: WeatherStatus.failure));
    }
  }

  Future<void> refreshWeather() async {
    if (!state.status.isSuccess) return;
    if (state.weather == Weather.empty) return;
    try {
      final weather = Weather.fromRepository(
        await _weatherRepository.getWeather(state.weather.location),
      );
      final units = state.temperatureUnits;
      final value = units.isFahrenheit
          ? weather.temperature.value.toFahrenheit()
          : weather.temperature.value;

      emit(
        state.copyWith(
          status: WeatherStatus.success,
          temperatureUnits: units,
          weather: weather.copyWith(temperature: Temperature(value: value)),
        ),
      );
    } on Exception {
      emit(state);
    }
  }

  void toggleUnits() {
    final units = state.temperatureUnits.isFahrenheit
        ? TemperatureUnits.celsius
        : TemperatureUnits.fahrenheit;

    if (!state.status.isSuccess) {
      emit(state.copyWith(temperatureUnits: units));
      return;
    }

    final weather = state.weather;
    if (weather != Weather.empty) {
      final temperature = weather.temperature;
      final value = units.isCelsius
          ? temperature.value.toCelsius()
          : temperature.value.toFahrenheit();
      emit(
        state.copyWith(
          temperatureUnits: units,
          weather: weather.copyWith(temperature: Temperature(value: value)),
        ),
      );
    }
  }

  @override
  WeatherState fromJson(Map<String, dynamic> json) =>
      WeatherState.fromJson(json);

  @override
  Map<String, dynamic> toJson(WeatherState state) => state.toJson();
}

extension on double {
  double toFahrenheit() => ((this * 9 / 5) + 32);
  double toCelsius() => ((this - 32) * 5 / 9);
}
```

?> **Note**: Remember to generate the (de)serialization code via `flutter packages pub run build_runner build`

### Theme

Next, we'll implement the business logic for the dynamic theming.

#### Theme Cubit

Let's create a `ThemeCubit` to manage the theme of our app. The theme will change based on the current weather conditions.

```
flutter_weather
|-- lib/
  |-- weather/
    |-- theme/
      |-- cubit/
        |-- theme_cubit.dart
```

We will expose an `updateTheme` method to update the theme depending on the weather condition.

```dart
// lib/theme/cubit/theme_cubit.dart (done)

import 'package:flutter/material.dart';
import 'package:flutter_weather/weather/weather.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class ThemeCubit extends HydratedCubit<Color> {
  ThemeCubit() : super(defaultColor);

  static const defaultColor = Color(0xFF2196F3);

  void updateTheme(Weather? weather) {
    if (weather != null) emit(weather.toColor);
  }

  @override
  Color fromJson(Map<String, dynamic> json) {
    return Color(int.parse(json['color'] as String));
  }

  @override
  Map<String, dynamic> toJson(Color state) {
    return <String, String>{'color': '${state.value}'};
  }
}

extension on Weather {
  Color get toColor {
    switch (condition) {
      case WeatherCondition.clear:
        return Colors.orangeAccent;
      case WeatherCondition.snowy:
        return Colors.lightBlueAccent;
      case WeatherCondition.cloudy:
        return Colors.blueGrey;
      case WeatherCondition.rainy:
        return Colors.indigoAccent;
      case WeatherCondition.unknown:
      default:
        return ThemeCubit.defaultColor;
    }
  }
}

```

### Unit Tests

There are a few things we should test

- If our weather states return correct `WeatherStatusX` values (see [completed test file](https://github.com/felangel/bloc/blob/master/examples/flutter_weather/test/weather/cubit/weather_state_test.dart))
- If our HydratedCubits respond to events properly and are able to convert fromJson and toJson

In addition to using the standard testing library and `mocktail` for mocking, we recommend using the [bloc_test](https://pub.dev/packages/bloc_test) library. `bloc_test` allows us to easily prepare our blocs for testing, handle state changes, and check results.

[Here](https://github.com/felangel/bloc/blob/master/examples/flutter_weather/test/weather/cubit/weather_cubit_test.dart) is an example weather cubit testing file and [here](https://github.com/felangel/bloc/blob/master/examples/flutter_weather/test/theme/cubit/theme_cubit_test.dart) is an example theme cubit testing file

## Presentation Layer

### Weather Page

> With the core logic of our app put together, it's time to put together the UI! 

We will start with the weather page which uses `dependency injection` in order to provide cubits to widgets. This is accomplished using `BlocProvider` and `BlocConsumer`. These objects inject Cubits whenever widgets are (re)rendered.

```dart
// lib/weather/view/weather_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_weather/search/search.dart';
import 'package:flutter_weather/settings/settings.dart';
import 'package:flutter_weather/theme/theme.dart';
import 'package:flutter_weather/weather/weather.dart';
import 'package:pedantic/pedantic.dart';
import 'package:weather_repository/weather_repository.dart';

class WeatherPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WeatherCubit(context.read<WeatherRepository>()),
      child: WeatherView(),
    );
  }
}

class WeatherView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Weather'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push<void>(SettingsPage.route(
                context.read<WeatherCubit>(),
              ));
            },
          ),
        ],
      ),
      body: Center(
        child: BlocConsumer<WeatherCubit, WeatherState>(
          listener: (context, state) {
            if (state.status.isSuccess) {
              context.read<ThemeCubit>().updateTheme(state.weather);
            }
          },
          builder: (context, state) {
            switch (state.status) {
              case WeatherStatus.initial:
                return const WeatherEmpty();
              case WeatherStatus.loading:
                return const WeatherLoading();
              case WeatherStatus.success:
                return WeatherPopulated(
                  weather: state.weather,
                  units: state.temperatureUnits,
                  onRefresh: () {
                    return context.read<WeatherCubit>().refreshWeather();
                  },
                );
              case WeatherStatus.failure:
              default:
                return const WeatherError();
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.search),
        onPressed: () async {
          final city = await Navigator.of(context).push(SearchPage.route());
          unawaited(context.read<WeatherCubit>().fetchWeather(city));
        },
      ),
    );
  }
}
```

You'll notice that page depends on `SettingsPage, SearchPage` widgets, which we will create next.

### SettingsPage

TODO: The Settings Page does this...

```dart
// lib/settings/view/settings_page.dart (done)
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_weather/weather/weather.dart';

class SettingsPage extends StatelessWidget {
  static Route route(WeatherCubit weatherCubit) {
    return MaterialPageRoute<void>(
      builder: (_) => BlocProvider.value(
        value: weatherCubit,
        child: SettingsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: <Widget>[
          BlocBuilder<WeatherCubit, WeatherState>(
            buildWhen: (previous, current) =>
                previous.temperatureUnits != current.temperatureUnits,
            builder: (context, state) {
              return ListTile(
                title: const Text('Temperature Units'),
                isThreeLine: true,
                subtitle: const Text(
                  'Use metric measurements for temperature units.',
                ),
                trailing: Switch(
                  value: state.temperatureUnits.isCelsius,
                  onChanged: (_) => context.read<WeatherCubit>().toggleUnits(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
```

### SearchPage

TODO: The Search Page does this...

```dart
// lib/settings/view/search_page.dart (done)
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  SearchPage._({Key? key}) : super(key: key);

  static Route<String> route() {
    return MaterialPageRoute(builder: (_) => SearchPage._());
  }

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _textController = TextEditingController();

  String get _text => _textController.text;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('City Search')),
      body: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  labelText: 'City',
                  hintText: 'Chicago',
                ),
              ),
            ),
          ),
          IconButton(
            key: const Key('searchPage_search_iconButton'),
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.of(context).pop(_text),
          )
        ],
      ),
    );
  }
}
```

### Weather Widgets

The app will display different screens depending on the four possible states.

#### WeatherEmpty

This screen will show when there is no data to display because the user has not yet selected a city.

```dart
// lib/weather/widgets/weather_empty.dart (done)

import 'package:flutter/material.dart';

class WeatherEmpty extends StatelessWidget {
  const WeatherEmpty({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('🏙️', style: TextStyle(fontSize: 64)),
        Text(
          'Please Select a City!',
          style: theme.textTheme.headline5,
        ),
      ],
    );
  }
}
```

#### WeatherError

This screen will display if there is an error.

```dart
// lib/weather/widgets/weather_error.dart (done)

import 'package:flutter/material.dart';

class WeatherError extends StatelessWidget {
  const WeatherError({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('🙈', style: TextStyle(fontSize: 64)),
        Text(
          'Something went wrong!',
          style: theme.textTheme.headline5,
        ),
      ],
    );
  }
}
```

#### WeatherLoading

This screen will display as the application fetches the data.

```dart
// lib/weather/widgets/weather_loading.dart (done)

import 'package:flutter/material.dart';

class WeatherLoading extends StatelessWidget {
  const WeatherLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('⛅', style: TextStyle(fontSize: 64)),
        Text(
          'Loading Weather',
          style: theme.textTheme.headline5,
        ),
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      ],
    );
  }
}
```

#### WeatherPopulated

This screen will display after the user has selected a city and we have retrieved the data.

```dart
// lib/weather/widgets/weather_populated.dart
import 'package:flutter/material.dart';
import 'package:flutter_weather/weather/weather.dart';
import 'package:weather_repository/weather_repository.dart'
    show WeatherCondition;

class WeatherPopulated extends StatelessWidget {
  const WeatherPopulated({
    Key? key,
    required this.weather,
    required this.units,
    required this.onRefresh,
  }) : super(key: key);

  final Weather weather;
  final TemperatureUnits units;
  final ValueGetter<Future<void>> onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        _WeatherBackground(),
        RefreshIndicator(
          onRefresh: onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            clipBehavior: Clip.none,
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 48),
                  _WeatherIcon(condition: weather.condition),
                  Text(
                    weather.location,
                    style: theme.textTheme.headline2?.copyWith(
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                  Text(
                    weather.formattedTemperature(units),
                    style: theme.textTheme.headline3?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '''Last Updated at ${TimeOfDay.fromDateTime(weather.lastUpdated).format(context)}''',
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WeatherIcon extends StatelessWidget {
  const _WeatherIcon({Key? key, required this.condition}) : super(key: key);

  static const _iconSize = 100.0;

  final WeatherCondition condition;

  @override
  Widget build(BuildContext context) {
    return Text(
      condition.toEmoji,
      style: const TextStyle(fontSize: _iconSize),
    );
  }
}

extension on WeatherCondition {
  String get toEmoji {
    switch (this) {
      case WeatherCondition.clear:
        return '☀️';
      case WeatherCondition.rainy:
        return '🌧️';
      case WeatherCondition.cloudy:
        return '☁️';
      case WeatherCondition.snowy:
        return '🌨️';
      case WeatherCondition.unknown:
      default:
        return '❓';
    }
  }
}

class _WeatherBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).primaryColor;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.25, 0.75, 0.90, 1.0],
          colors: [
            color,
            color.brighten(10),
            color.brighten(33),
            color.brighten(50),
          ],
        ),
      ),
    );
  }
}

extension on Color {
  Color brighten([int percent = 10]) {
    assert(1 <= percent && percent <= 100);
    final p = percent / 100;
    return Color.fromARGB(
      alpha,
      red + ((255 - red) * p).round(),
      green + ((255 - green) * p).round(),
      blue + ((255 - blue) * p).round(),
    );
  }
}

extension on Weather {
  String formattedTemperature(TemperatureUnits units) {
    return '''${temperature.value.toStringAsPrecision(2)}°${units.isCelsius ? 'C' : 'F'}''';
  }
}
```

### Barrel File

Let's add these states to a barrel file to clean up our imports.

```dart
// lib/weather/widgets/widgets.dart (done)

export 'weather_empty.dart';
export 'weather_error.dart';
export 'weather_loading.dart';
export 'weather_populated.dart';
```

## Weather Views

> Let's put all of the piece of our app together!

Our `main.dart` file should initialize our `WeatherApp` and `BlocObserver` (for debugging purposes), as well as setup our `HydratedStorage` to persist state across sessions.

```dart
// lib/main.dart (done)

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_weather/app.dart';
import 'package:flutter_weather/weather_bloc_observer.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:weather_repository/weather_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  EquatableConfig.stringify = kDebugMode;
  Bloc.observer = WeatherBlocObserver();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorage.webStorageDirectory
        : await getTemporaryDirectory(),
  );
  runApp(WeatherApp(weatherRepository: WeatherRepository()));
}
```

Our `app.dart` widget will handle building the `WeatherPage` view we previously created and use `BlocProvider` to inject our `ThemeCubit` which handles theme data.

```dart
// lib/app.dart (done)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_weather/theme/theme.dart';
import 'package:flutter_weather/weather/weather.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_repository/weather_repository.dart';

class WeatherApp extends StatelessWidget {
  const WeatherApp({Key? key, required WeatherRepository weatherRepository})
      : _weatherRepository = weatherRepository,
        super(key: key);

  final WeatherRepository _weatherRepository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: _weatherRepository,
      child: BlocProvider(
        create: (_) => ThemeCubit(),
        child: WeatherAppView(),
      ),
    );
  }
}

class WeatherAppView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return BlocBuilder<ThemeCubit, Color>(
      builder: (context, color) {
        return MaterialApp(
          theme: ThemeData(
            primaryColor: color,
            textTheme: GoogleFonts.rajdhaniTextTheme(),
            appBarTheme: AppBarTheme(
              textTheme: GoogleFonts.rajdhaniTextTheme(textTheme).apply(
                bodyColor: Colors.white,
              ),
            ),
          ),
          home: WeatherPage(),
        );
      },
    );
  }
}
```

## Tests

We also recommend using the `bloc_test` library for testing our widgets and views. `MockBlocs` and `MockCubits` make it easy to test UI based on particular states and events.

Here is an [example test suite](https://github.com/felangel/bloc/tree/master/examples/flutter_weather/test) with tests for widgets, cubits, and views.

## Final Step

> Yay, we have completed the tutorial! 🎉 

As a final step, we can test to make sure the app works as intended by using the `flutter run` command.

For reference, here is the [full source code](https://github.com/felangel/bloc/tree/master/examples/flutter_weather). 

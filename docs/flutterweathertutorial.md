# Flutter Weather Tutorial

![advanced](https://img.shields.io/badge/level-advanced-red.svg)

## Tutorial Goals

> The goal of this tutorial is to demonstrate best practices for design and testing when using the Bloc Library for a complex app. Specifically, we will use Hydrated Cubits to make a weather app.

![demo](./assets/gifs/flutter_weather.gif)

### Project Requirements:
- User can search for US cities on the search page
- App displays weather information returned by [MetaWeather API](https://www.metaweather.com/api/)
- App theme changes depending on weather of the city (Dynamic Theming)
- Settings page which allows for unit conversions
- Persist state across sessions (Hydrated Cubits)

## Key Concepts
- Observe state changes with [BlocObserver](/coreconcepts?id=blocobserver).
- [BlocProvider](/flutterbloccoreconcepts?id=blocprovider), Flutter widget which provides a bloc to its children.
- [BlocBuilder](/flutterbloccoreconcepts?id=blocbuilder), Flutter widget that handles building the widget in response to new states.
- Prevent unnecessary rebuilds with [Equatable](/faqs?id=when-to-use-equatable).
- [RepositoryProvider](/flutterbloccoreconcepts?id=repositoryprovider), a Flutter widget which provides a repository to its children.
- [BlocListener](/flutterbloccoreconcepts?id=bloclistener), a Flutter widget which invokes the listener code in response to state changes in the bloc.
- [MultiBlocProvider](/flutterbloccoreconcepts?id=multiblocprovider), a Flutter widget that merges multiple BlocProvider widgets into one.
- [BlocConsumer](/flutterbloccoreconcepts?id=blocconsumer), exposes a builder and listener in order to react to new states.
- [Hydrated Cubits](https://github.com/felangel/bloc/tree/master/packages/hydrated_bloc) to manage and mutate state, in response to user interactions
- [Hydrated Storage](https://github.com/felangel/bloc/tree/master/packages/hydrated_bloc) to persist state


## Setup/Project Structure

To begin, create a new flutter project
```bash
flutter create flutter_weather
```

### Project Structure: Feature Driven
> Each package (directory) within our app contains an isolated feature. This allows for scalability as the number of features increases and also allows for developers to work on isolated parts of the codebase. 

Our app can be broken down into 4 main features: **search, settings, theme, weather**. Create those directories.
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

### Architecture Layers
> Following the [bloc architecture](https://bloclibrary.dev/#/architecture) guidelines, each feature will be implemented in layers. 
- Data Layer: retrieving weather data from API
- Repository: wrapping the data layer and compiling the data into a useful state for our application
- Business Logic Layer: keep track and change state based on user input (unit information, city details, themes, etc.)
- Presentation Layer: display weather information and collect input from users (settings page, search page etc.)


## Data Layer

For this application we'll be hitting the [metaweather API](https://www.metaweather.com).

We'll be focusing on two endpoints:

- `/api/location/search/?query=$city` to get a locationId for a given city name
- `/api/location/$locationId` to get the weather for a given locationId

Open [https://www.metaweather.com/api/location/search/?query=london](https://www.metaweather.com/api/location/search/?query=london) in your browser to see the response for the city of London. We will use the `woeid` (where-on-earth-id) in the return dictionary to hit the location endpoint.

The `woeid` for London is 44418. Navigate to [https://www.metaweather.com/api/location/44418](https://www.metaweather.com/api/location/44418) in your browser and you'll see the response for weather in London. This contains all the data we will need for our app.

### Creating Our MetaWeather API Client Subpackage

> Since our API client interacting MetaWeather should be independent of the rest of our app, we can create it as a subpackage. We can then import our package in our `pubspec.yaml`

Create a new directory on the project level called `packages`. This directory will store all of our custom made subpackages.

Within this directory, run the built in flutter create command to create a new subpackage called `meta_weather_api` for our api client

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

### Creating Our MetaWeather API Data Model

> Next, let's create `location.dart` and `weather.dart` models to store response data from the location and weather API endpoints.

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

> First, let's work out of `location.dart`. Our location model should store data returned by the location API, which looks like the following: 

```json
{
    "title": "London",
    "location_type": "City",
    "woeid": 44418,
    "latt_long": "51.506321,-0.12714"
}
```

> Here's the **in-progress** `location.dart` file which stores the above response:

```dart
// packages/meta_weather_api/lib/src/models/location.dart (in progress)

enum LocationType {
    city, region, state, province, country, continent
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

> Next, let's work out of `weather.dart`. Our weather model should store data returned by the weather API, which looks like the following:

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

> Here's the **in-progress** `weather.dart` file which stores the above response:

```dart
// packages/meta_weather_api/lib/src/models/weather.dart (in progress)

enum WeatherState {
    snow, sleet, hail, thunderstorm, heavyRain, lightRain, showers, heavyCloud, lightCloud, clear, unknown
}

enum WindDirectionCompass {
    north, northEast, east, southEast, south, southWest, west, northWest, unknown
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

> While we're here, let's quickly create a [barrel file](https://adrianfaciu.dev/posts/barrel-files/) to clean up some of our imports down the road. 

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

In the file, export the models

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

In the file, export what we've completed thus far

```dart
// packages/meta_weather_api/lib/meta_weather_api.dart (in progress)

library meta_weather_api;

export 'src/models/models.dart';
```


### Adding serialization and deserialization to our data models

> In order for HydratedCubit to persist state across sessions, we need to be able to [serialize and deserialize](https://en.wikipedia.org/wiki/Serialization) our models. To do this, we will tell Dart how to convert our data objects into `json` format to store in local storage. 

Here is a useful [Medium article](https://medium.com/flutter-community/generate-the-code-to-parse-your-json-in-flutter-c68aa89a81d9) which goes in depth on the subject. Essentially, we will be using the **json_annotation, json_serializable, build_runner** packages to generate models and factory methods which support serialization and deserialization from our annotated data models. 

First, let's add these packages to packages/meta_weather_api/pubspec.yaml

```yaml
# packages/meta_weather_api/pubspec.yaml (in progress)
name: meta_weather_api
description: A Dart API Client for the MetaWeather API.
version: 1.0.0+1

environment:
  sdk: ">=2.12.0-0 <3.0.0"

dependencies:
  json_annotation: ^4.0.0

dev_dependencies:
  build_runner: ^1.10.0
  json_serializable: ^4.0.0
```

```bash
flutter packages get
```

> In order for us to create auto-generated code, we're going to need to label our code. 
- @JsonSerializable to label classes which can be serialized
- @JsonKey to provide string representations of field names
- @JsonValue to provide string representations of field values
- Implement JSONConverter to convert object representations into JSON representations

> For each file we are also going to have to
- Import json_annotation
- Include auto-generated code using the [part](https://stackoverflow.com/questions/27763378/when-to-use-part-part-of-versus-import-export-in-dart/36433664) keyword
- Include fromJson methods for deserialization purposes

Here is our **finalized** `location.dart` model file

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

Here is our **finalized** `weather.dart` model file

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

Lastly, let's use `build_runner` to create the auto-generated files.

```bash
flutter packages pub run build_runner build
```

`build_runner` should have auto-generated the `location.g.dart` and `weather.g.dart` files. Your directory should now look as follows:

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

### Using the data models to create the API Client

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

We will also need to import the `http` package. In your `packages/meta_weather_api/pubspec.yaml` file, add `http` to your list of dependencies. Your updated file should look like this: 

```yaml
# packages/meta_weather_api/pubspec.yaml (in progress)
name: meta_weather_api
description: A Dart API Client for the MetaWeather API.
version: 1.0.0+1

environment:
  sdk: ">=2.12.0-0 <3.0.0"

dependencies:
  http: ^0.13.0
  json_annotation: ^4.0.0

dev_dependencies:
  coverage: ^0.14.1
  build_runner: ^1.10.0
  json_serializable: ^4.0.0
```

Makes sure to run `flutter pub get` after saving the file. 

Our API client has two main responsibilities:
- Expose a `locationSearch` method which returns a `location` future
- Expose a `getWeather` method which returns a `weather` future

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

The locationSearch method hits the location API and throws `LocationIdRequestFailiure` errors as applicable. The completed method looks as follows:

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

Similarly, the getWeather method hits the weather API and throws `WeatherRequestFailiure` errors as applicable. The completed method looks as follows:

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

The completed file, put together, looks like this

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

Lastly, let's wrap up this package by adding our API client to the barrel file.

```dart
// packages/meta_weather_api/lib/meta_weather_api.dart (done)

library meta_weather_api;

export 'src/meta_weather_api_client.dart';
export 'src/models/models.dart';
```

### Unit Testing our Data Layer Models

First, let's unit test our data models, `location` and `weather`. We should focus on insuring that they can represent our data, translate from and to JSON form, and handle edge cases.

First, add the Dart testing library to our `pubspec.yaml` and run `flutter pub get`.

```yaml
# packages/meta_weather_api/pubspec.yaml (in progress)
name: meta_weather_api
description: A Dart API Client for the MetaWeather API.
version: 1.0.0+1

environment:
  sdk: ">=2.12.0-0 <3.0.0"

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

### Unit Testing Our Data Layer Client using Mocktail

Next, let's test our API client. We should test to ensure that our API client handles both endpoints properly, including edge cases. 

Note that we do not want our test cases to make legitimate API calls since our goal is to test our API client, not the API itself. In order to standardize the API response and make sure that our client handles the response properly, we will use [Mocktail](https://github.com/felangel/mocktail), a Dart mocking library.

```yaml
# packages/meta_weather_api/pubspec.yaml (in progress)
name: meta_weather_api
description: A Dart API Client for the MetaWeather API.
version: 1.0.0+1

environment:
  sdk: ">=2.12.0-0 <3.0.0"

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

Finally, let's install the `coverage` package to run our tests with coverage and ensure that our tests pass

```yaml
# packages/meta_weather_api/pubspec.yaml (done)
name: meta_weather_api
description: A Dart API Client for the MetaWeather API.
version: 1.0.0+1

environment:
  sdk: ">=2.12.0-0 <3.0.0"

dependencies:
  http: ^0.13.0
  json_annotation: ^4.0.0

dev_dependencies:
  coverage: ^0.14.1
  build_runner: ^1.10.0
  json_serializable: ^4.0.0
  mocktail: ^0.1.0
  test: ^1.16.4
```

```bash
flutter test --coverage
```

## Repository Layer

The goal of our repository layer is to create a wrapper for our data layer, and facilitate communication with the Bloc layer. In doing this, the rest of our code base depends only on functions exposed by our repository layer, instead of specific data provider implementations. This makes it easier for data providers to be switched out in the long run, and even converted into Flutter plugins/packages.

### Creating Our Weather Repository Package

Inside the packages directory, run the following command

```
flutter create --template=package weather_repository
```

Your directory structure should look like this:

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

Next, we will be use the same packages as in the `meta_weather_api` package. In addition, we will also use the `meta_weather_api` package which we just created. Update your `pubspec.yaml` to look like the following and run `flutter packages get`

```yaml
# packages/weather_repository/pubspec.yaml (done)
name: weather_repository
description: A Dart Repository which manages the weather domain.
version: 1.0.0+1
publish_to: none

environment:
  sdk: ">=2.12.0-0 <3.0.0"

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

### Creating Our Weather Repository Models

Update your directory structure to look like this. We will be creating a new `weather.dart` models file to contain only data we want to store, and another `models.dart` barrel file.

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

As we did in the previous section, run the following command to use `build_runner` to create our auto-generated models and factory methods.

```
flutter packages pub run build_runner build
```

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

### Implementing Our Weather Repository

The main goal of our weather repository is to provide a wrapper for our data provider to interact with our Bloc layer. We have a dependency on our `WeatherApiClient` and expose a single public method, `getWeather(String city)`. No one needs to know that under the hood we need to make two API calls because no one really cares. All we care about is getting the `Weather` for a given city.

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

The main method we have to worry about here is the `getWeather(String city)` method we discussed earlier. Implement it using two calls to the API client as follows

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

The completed file looks like this

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

Lastly, update the barrel file we created previously and we are done. 

```dart
// packages/weather_repository/lib/weather_repository.dart (done)

library weather_repository;

export 'src/models/models.dart';
export 'src/weather_repository.dart';
```

### Testing Our Weather Repository

To test our Weather Repository, we will use the [Mocktail](https://github.com/felangel/mocktail) library. Using this library, we will create mocks and insure that our weather repository's `getWeather` method works as it should. This includes testing when the API client fails, and making sure the `Weather` object returned is correct when the API call is successful.

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




## Business Logic Layer: Weather Model

In this section, we're going to implement our third weather model - this time for the weather feature of our main app. Note that we haven't been implementing the exact same model each time. In the API client package, our weather model contained all the info returned by the API. In the repository client package, our weather model contained only the data we wish to display in our app, and in this weather model, we will bake temperature settings into the weather model.

Before we get started, lets update our project level dependencies to import the packages we've created and also the serialization/deserialization dependencies.

```yaml
# pubspec.yaml (in progress)
name: flutter_weather
description: A new Flutter project.
version: 1.0.0+1
publish_to: none

environment:
  sdk: ">=2.12.0-0 <3.0.0"

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

We will be working in the `weather` features app, in our main project library.

```
flutter_weather
|-- lib/
  |-- weather/
    |-- models/
      |-- models.dart
      |-- weather.dart
```

The goal of our weather model is to keep track of weather data displayed by our app and also to keep track of settings. To keep track of settings (celsius, farenheit), create the temperature model in `weather`

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

Lastly, to wrap this section up, run `build_runner` to create the auto generated file and methods, and also export our models in the barrel file

```bash
flutter packages pub run build_runner build
```

```dart
// lib/weather/models/models.dart (done)
export 'weather.dart';
```

## Business Logic Layer: Weather and Theme Cubits

In this tutorial, we will use HydratedCubits for our Bloc layer. HydratedCubits are essentially Cubits that can persist state across sessions when used in conjunction with HydratedStorage. In short, our HydratedCubits will keep track of state and expose methods which can be used to mutate state.

### Weather State

Add the `cubits` directory within the weather app and create the `weather_cubit.dart` and `weather_state.dart` files. Your project structure should look like this:

```
flutter_weather
|-- lib/
  |-- weather/
    |-- cubit/
      |-- weather_cubit.dart
      |-- weather_state.dart
```

There are 4 states our weather app can be in: `initial` (before anything loads), `loading` (during the API call), `success` (if our API call is successful), ``failiure (if our API call is unsuccessful). 

We will keep track of this using the enum `WeatherStatus`

```dart
enum WeatherStatus { initial, loading, success, failure }

extension WeatherStatusX on WeatherStatus {
  bool get isInitial => this == WeatherStatus.initial;
  bool get isLoading => this == WeatherStatus.loading;
  bool get isSuccess => this == WeatherStatus.success;
  bool get isFailure => this == WeatherStatus.failure;
}
```

We will also need to keep track of what units (farenheit or celsius) our app is in. 

Putting this together, we can keep track of everything we need in our finalized `WeatherState`:

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

### Weather Cubits

Finally! It's time to put together our Weather Cubit. Our Weather Cubit will expose the following methods:

- `fetchWeather(String? city)` which uses our weather repository to try and retrieve a weather object for the given city
- `refreshWeather()` which retrieves a new weather object using the weather repository given the current weather state
- `toggleUnits()` switch the state between celsius and farenheit, or vice versa
- `fromJson(Map<String, dynamic> json)`, `toJson(WeatherState state)`, which handles persisting cubit state

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

Again, we will need to create our auto generated file using `build_runner`

```
flutter packages pub run build_runner build
```

### Theme Cubits

Next, let's put together the HydratedCubit we will use to keep track of the theme of our app. The goal is to have the theme changed based on the current weather information.

```
flutter_weather
|-- lib/
  |-- weather/
    |-- theme/
      |-- cubit/
        |-- theme_cubit.dart
```

We will expose an `updateTheme(Weather? weather)` method, which will update the theme cubit depending on the weather condition

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

### Testing: Cubit Tests

There are a few things we should test

- If our weather states return correct `WeatherStatusX` values. [Here](https://github.com/felangel/bloc/blob/master/examples/flutter_weather/test/weather/cubit/weather_state_test.dart) is a completed test file
- If our HydratedCubits respond to events properly and is able to convert fromJson and toJson

In addition to using `Mocktail` for mocking and the standard testing library, it is also reccomended to use [bloc_test](https://pub.dev/packages/bloc_test) library. `bloc_test` allows us to easily prepare our blocs for testing, handle state changes, and check results.

[Here](https://github.com/felangel/bloc/blob/master/examples/flutter_weather/test/weather/cubit/weather_cubit_test.dart) is an example weather cubit testing file and [here](https://github.com/felangel/bloc/blob/master/examples/flutter_weather/test/theme/cubit/theme_cubit_test.dart) is an example theme cubit testing file

## Presentation Layer: Weather Page, Settings Page, Search Page

### Weather Page

With the core logic of our app put together, it's time to put together the UI! We will start with the weather page which uses `dependency injection` in order to provide cubits to widgets. This is accomplished using `BlocProvider` and `BlocConsumer`. These objects essentially inject our Cubits whenever widgets are (re)rendered.

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

This page depends on `SettingsPage, SearchPage` widgets, which we will create next

### SettingsPage

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

## Presentation Layer: Individual Weather Widgets

We will next create the UI for our app. Each individual widget corresponds to a particular state our Cubits can be in.

### WeatherEmpty

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

### WeatherError

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

### WeatherLoading

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

### WeatherPopulated

Next, lets create the UI for when a city has actually been queried for.

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

Lastly, let's add everything to a barrel file to clean up our imports.

```dart
// lib/weather/widgets/widgets.dart (done)

export 'weather_empty.dart';
export 'weather_error.dart';
export 'weather_loading.dart';
export 'weather_populated.dart';
```

## Presentation Layer: Views

Let's glue the rest of our app together!

Our `main.dart` file should initialize our `WeatherApp`, initialize our `BlocObserver` (for debugging purposes), and setup our `HydratedStorage` to persist state across sessions.

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

Next, our `app.dart` widget will handle building the `WeatherPage` view we previously created and also use `BlocProvider` to inject our `ThemeCubit` to handle theme data.

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

## Testing Our Widgets and Views

In order to feel comfortable about our testing coverage, we should also test the widgets and view pages we have created. Again, we also reccomend using the `bloc_test` library for this. 

The `bloc_test` library provides `MockBlocs` and `MockCubits` which make it easy to test UI based on particular states and events.

[Here](https://github.com/felangel/bloc/tree/master/examples/flutter_weather/test) is an example test suite which includes widget tests, cubit tests, and view tests.

## Putting it all together. Visually testing functionality

And that's it! We can test our functionality by using the `flutter run` command. 

The full source can be found [here](https://github.com/felangel/bloc/tree/master/examples/flutter_weather)
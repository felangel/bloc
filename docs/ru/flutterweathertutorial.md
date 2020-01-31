# Flutter погода

![advanced](https://img.shields.io/badge/level-advanced-red.svg)

> В следующем руководстве мы собираемся создать приложение `Weather` во Flutter, которое демонстрирует как управлять несколькими блоками для реализации динамического создания тем, обновления данных и многого другого. Наше приложение погоды будет извлекать реальные данные из API и демонстрировать, как разделить наше приложение на три уровня (данные, бизнес-логика и представление).

![demo](../assets/gifs/flutter_weather.gif)

## Настройка

Мы начнем с создания нового проекта Flutter

```bash
flutter create flutter_weather
```

Сначала нам нужно заменить содержимое файла `pubspec.yaml` на:

```yaml
name: flutter_weather
description: A new Flutter project.

version: 1.0.0+1

environment:
  sdk: '>=2.6.0 <3.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^3.2.0
  http: ^0.12.0
  equatable: ^1.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^4.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/
```

?> **Примечание:** Мы собираемся добавить некоторые ресурсы (значки для типов погоды) в наше приложение, поэтому нам нужно подключить папку ресурсов в `pubspec.yaml`. Пожалуйста, создайте папку _assets_ в корне проекта.

а затем установить все наши зависимости

```bash
flutter packages get
```

## REST API

Для этого приложения мы будем использовать [metaweather API](https://www.metaweather.com).

Мы сосредоточимся на двух конечных ресурсах:

- `/api/location/search/?query=$city` чтобы получить locationId для данного названия города
- `/api/location/$locationId` чтобы узнать погоду для данного местоположения

Открыв [https://www.metaweather.com/api/location/search/?query=london](https://www.metaweather.com/api/location/search/?query=london) в своем браузере, мы увидим следующий ответ:

```json
[
  {
    "title": "London",
    "location_type": "City",
    "woeid": 44418,
    "latt_long": "51.506321,-0.12714"
  }
]
```

Затем мы можем получить идентификатор `where-on-earth-id` (woeid) и использовать его для получения местоположения.

Перейдите на [https://www.metaweather.com/api/location/44418](https://www.metaweather.com/api/location/44418) в своем браузере и вы увидите ответ на погоду в Лондоне. Это должно выглядеть примерно так:

```json
{
  "consolidated_weather": [
    {
      "id": 5565095488782336,
      "weather_state_name": "Showers",
      "weather_state_abbr": "s",
      "wind_direction_compass": "WNW",
      "created": "2019-02-10T19:55:02.434940Z",
      "applicable_date": "2019-02-10",
      "min_temp": 3.75,
      "max_temp": 6.883333333333333,
      "the_temp": 6.885,
      "wind_speed": 10.251177687940428,
      "wind_direction": 288.4087075064449,
      "air_pressure": 998.9649999999999,
      "humidity": 79,
      "visibility": 8.241867493835997,
      "predictability": 73
    },
    {
      "id": 5039805855432704,
      "weather_state_name": "Light Cloud",
      "weather_state_abbr": "lc",
      "wind_direction_compass": "NW",
      "created": "2019-02-10T19:55:02.537745Z",
      "applicable_date": "2019-02-11",
      "min_temp": 1.7699999999999998,
      "max_temp": 8.986666666666666,
      "the_temp": 8.105,
      "wind_speed": 5.198548786091227,
      "wind_direction": 319.24869874195554,
      "air_pressure": 1027.4,
      "humidity": 75,
      "visibility": 11.027785234232084,
      "predictability": 70
    },
    {
      "id": 6214207016009728,
      "weather_state_name": "Heavy Cloud",
      "weather_state_abbr": "hc",
      "wind_direction_compass": "SW",
      "created": "2019-02-10T19:55:02.736577Z",
      "applicable_date": "2019-02-12",
      "min_temp": 3.2699999999999996,
      "max_temp": 11.783333333333333,
      "the_temp": 10.425,
      "wind_speed": 6.291005350509027,
      "wind_direction": 225.7496998927606,
      "air_pressure": 1034.9099999999999,
      "humidity": 77,
      "visibility": 9.639331305177762,
      "predictability": 71
    },
    {
      "id": 6548160117735424,
      "weather_state_name": "Heavy Cloud",
      "weather_state_abbr": "hc",
      "wind_direction_compass": "SSW",
      "created": "2019-02-10T19:55:02.687267Z",
      "applicable_date": "2019-02-13",
      "min_temp": 3.526666666666667,
      "max_temp": 11.476666666666667,
      "the_temp": 10.695,
      "wind_speed": 6.524550068392587,
      "wind_direction": 203.1296143014564,
      "air_pressure": 1035.775,
      "humidity": 76,
      "visibility": 12.940987135130836,
      "predictability": 71
    },
    {
      "id": 4957149578919936,
      "weather_state_name": "Light Cloud",
      "weather_state_abbr": "lc",
      "wind_direction_compass": "SSE",
      "created": "2019-02-10T19:55:03.487370Z",
      "applicable_date": "2019-02-14",
      "min_temp": 3.4500000000000006,
      "max_temp": 12.540000000000001,
      "the_temp": 12.16,
      "wind_speed": 5.990352212916568,
      "wind_direction": 154.1901674720193,
      "air_pressure": 1035.53,
      "humidity": 71,
      "visibility": 13.873665294679075,
      "predictability": 70
    },
    {
      "id": 5277694765826048,
      "weather_state_name": "Light Cloud",
      "weather_state_abbr": "lc",
      "wind_direction_compass": "S",
      "created": "2019-02-10T19:55:04.800837Z",
      "applicable_date": "2019-02-15",
      "min_temp": 3.4,
      "max_temp": 12.986666666666666,
      "the_temp": 12.39,
      "wind_speed": 5.359238182348418,
      "wind_direction": 176.84978678797177,
      "air_pressure": 1030.96,
      "humidity": 77,
      "visibility": 9.997862483098704,
      "predictability": 70
    }
  ],
  "time": "2019-02-10T21:49:37.574260Z",
  "sun_rise": "2019-02-10T07:24:19.235049Z",
  "sun_set": "2019-02-10T17:05:51.151342Z",
  "timezone_name": "LMT",
  "parent": {
    "title": "England",
    "location_type": "Region / State / Province",
    "woeid": 24554868,
    "latt_long": "52.883560,-1.974060"
  },
  "sources": [
    {
      "title": "BBC",
      "slug": "bbc",
      "url": "http://www.bbc.co.uk/weather/",
      "crawl_rate": 180
    },
    {
      "title": "Forecast.io",
      "slug": "forecast-io",
      "url": "http://forecast.io/",
      "crawl_rate": 480
    },
    {
      "title": "HAMweather",
      "slug": "hamweather",
      "url": "http://www.hamweather.com/",
      "crawl_rate": 360
    },
    {
      "title": "Met Office",
      "slug": "met-office",
      "url": "http://www.metoffice.gov.uk/",
      "crawl_rate": 180
    },
    {
      "title": "OpenWeatherMap",
      "slug": "openweathermap",
      "url": "http://openweathermap.org/",
      "crawl_rate": 360
    },
    {
      "title": "Weather Underground",
      "slug": "wunderground",
      "url": "https://www.wunderground.com/?apiref=fc30dc3cd224e19b",
      "crawl_rate": 720
    },
    {
      "title": "World Weather Online",
      "slug": "world-weather-online",
      "url": "http://www.worldweatheronline.com/",
      "crawl_rate": 360
    },
    {
      "title": "Yahoo",
      "slug": "yahoo",
      "url": "http://weather.yahoo.com/",
      "crawl_rate": 180
    }
  ],
  "title": "London",
  "location_type": "City",
  "woeid": 44418,
  "latt_long": "51.506321,-0.12714",
  "timezone": "Europe/London"
}
```

Отлично, теперь, когда мы знаем как будут выглядеть наши данные, давайте создадим необходимые модели данных.

## Создание модели данных

Хотя API возвращает погоду на несколько дней, для простоты мы будем использовать только сегодняшний день.

Давайте начнем с создания папки для наших моделей `lib/models` и создадим там файл с именем `weather.dart`, который будет содержать нашу модель данных для нашего класса `Weather`. Затем внутри `lib/models` создадим файл с именем `models.dart`, который является индексным файлом, из которого мы экспортируем все модели.

### Импорты

Прежде всего нам нужно импортировать наши зависимости для нашего класса. В верхней части `weather.dart` добавьте:

```dart
import 'package:equatable/equatable.dart';
```

- `equatable`: пакет, который позволяет сравнивать объекты без необходимости переопределять оператор `==`

#### Создание WeatherCondition перечисления

Далее нам нужно создать счетчик для всех возможных погодных условий. В следующей строке давайте добавим `enum`.

Эти условия берутся из определения [metaweather API](https://www.metaweather.com/api/)

```dart
enum WeatherCondition {
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
```

#### Создание модели погоды

Далее нам нужно создать класс, который будет нашей моделью данных для объекта погоды, возвращаемого из API. Мы собираемся извлечь подмножество данных из API и создать модель `Weather`. Добавьте следующий код в файл `weather.dart` под перечислением `WeatherCondition`.

```dart
class Weather extends Equatable {
  final WeatherCondition condition;
  final String formattedCondition;
  final double minTemp;
  final double temp;
  final double maxTemp;
  final int locationId;
  final String created;
  final DateTime lastUpdated;
  final String location;

  const Weather({
    this.condition,
    this.formattedCondition,
    this.minTemp,
    this.temp,
    this.maxTemp,
    this.locationId,
    this.created,
    this.lastUpdated,
    this.location,
  });

  @override
  List<Object> get props => [
        condition,
        formattedCondition,
        minTemp,
        temp,
        maxTemp,
        locationId,
        created,
        lastUpdated,
        location,
      ];

  static Weather fromJson(dynamic json) {
    final consolidatedWeather = json['consolidated_weather'][0];
    return Weather(
      condition: _mapStringToWeatherCondition(
          consolidatedWeather['weather_state_abbr']),
      formattedCondition: consolidatedWeather['weather_state_name'],
      minTemp: consolidatedWeather['min_temp'] as double,
      temp: consolidatedWeather['the_temp'] as double,
      maxTemp: consolidatedWeather['max_temp'] as double,
      locationId: json['woeid'] as int,
      created: consolidatedWeather['created'],
      lastUpdated: DateTime.now(),
      location: json['title'],
    );
  }

  static WeatherCondition _mapStringToWeatherCondition(String input) {
    WeatherCondition state;
    switch (input) {
      case 'sn':
        state = WeatherCondition.snow;
        break;
      case 'sl':
        state = WeatherCondition.sleet;
        break;
      case 'h':
        state = WeatherCondition.hail;
        break;
      case 't':
        state = WeatherCondition.thunderstorm;
        break;
      case 'hr':
        state = WeatherCondition.heavyRain;
        break;
      case 'lr':
        state = WeatherCondition.lightRain;
        break;
      case 's':
        state = WeatherCondition.showers;
        break;
      case 'hc':
        state = WeatherCondition.heavyCloud;
        break;
      case 'lc':
        state = WeatherCondition.lightCloud;
        break;
      case 'c':
        state = WeatherCondition.clear;
        break;
      default:
        state = WeatherCondition.unknown;
    }
    return state;
  }
}
```

?> Мы расширяем [`Equatable`](https://pub.dev/packages/equatable), чтобы мы могли сравнивать экземпляры `Weather`. По умолчанию оператор равенства возвращает true если только этот и другие экземпляры являются одинаковыми.

Здесь мало что происходит; мы просто определяем нашу модель данных `Weather` и реализуем метод `fromJson`, чтобы мы могли создать экземпляр `Weather` из тела ответа API и создаем метод, который мапит необработанную строку в `WeatherCondition` в перечислении.

#### Экспорты в индексе

Теперь нам нужно экспортировать этот класс в индексный файл. Откройте `lib/models/models.dart` и добавьте следующую строку кода:

`export 'weather.dart';`

## Поставщик данных

Далее нам нужно создать  `WeatherApiClient`, который будет отвечать за http запросы к API погоды.

> WeatherApiClient - это самый низкий уровень в нашей прикладной архитектуре (поставщик данных). Он отвечает только за получение данных непосредственно из API.

Как мы упоминали ранее, мы собираемся запрашивать даные из двух ресурсов, поэтому нашему WeatherApiClient необходимо предоставить два публичных метода:

- `getLocationId(String city)`
- `fetchWeather(int locationId)`

### Создание клиента API

Этот уровень приложения называется уровнем хранилища, поэтому давайте продолжим и создадим папку для наших хранилищ. Внутри `lib/` создайте папку с именем `repositories`, а затем создайте файл с именем `weather_api_client.dart`.

#### Добавление индекса

Как и в случае с нашими моделями, давайте создадим файл барреля для репозиториев. Внутри `lib/repositories` добавьте файл с именем `repositories.dart` и оставьте его пока пустым.

- `models`: наконец, мы импортируем нашу модель `Weather`, созданную ранее.

#### Создание класса клиента

Давайте создадим класс. Сначала добавим этот код:

```dart
class WeatherApiClient {
  static const baseUrl = 'https://www.metaweather.com';
  final http.Client httpClient;

  WeatherApiClient({
    @required this.httpClient,
  }) : assert(httpClient != null);
}
```

Здесь мы создаем константу для нашего базового URL и http-клиент. Затем мы создаем конструктор и обязательный параметр для внедрения экземпляра `httpClient`. Вы увидите некоторые отсутствующие зависимости. Давайте продолжим и добавим их в начало файла:

```dart
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
```

- `meta`: Defines annotations that can be used by the tools that are shipped with the Dart SDK.
- `http`: A composable, Future-based library for making HTTP requests.

- `meta`: определяет аннотации, которые могут использоваться инструментами, поставляемыми с Dart SDK.
- `http`: композитная, `Future based` библиотека для выполнения HTTP-запросов.

#### Добавление метода getLocationId

Теперь давайте добавим наш первый публичный метод, который получит `locationId` для данного города. Ниже конструктора добавьте:

```dart
Future<int> getLocationId(String city) async {
  final locationUrl = '$baseUrl/api/location/search/?query=$city';
  final locationResponse = await this.httpClient.get(locationUrl);
  if (locationResponse.statusCode != 200) {
    throw Exception('error getting locationId for city');
  }

  final locationJson = jsonDecode(locationResponse.body) as List;
  return (locationJson.first)['woeid'];
}
```

Здесь мы делаем простой HTTP-запрос и затем декодируем ответ в виде списка. Говоря о декодировании, вы увидите, что `jsonDecode` это функция из зависимости, которую мы должны импортировать. Итак, давайте продолжим и сделаем это сейчас. В верхней части файла по другим импортам добавьте:

```dart
import 'dart:convert';
```

- `dart:convert`: кодер/декодер для преобразования между различными представлениями данных, включая JSON и UTF-8.

#### Добавление метода fetchWeather

Далее давайте добавим другой метод по выполнению запросов из `API metaweather`. Он будет получать погоду для города, учитывая его местоположение. Ниже уже реализованного метода `getLocationId` давайте продолжим и добавим:

```dart
Future<Weather> fetchWeather(int locationId) async {
  final weatherUrl = '$baseUrl/api/location/$locationId';
  final weatherResponse = await this.httpClient.get(weatherUrl);

  if (weatherResponse.statusCode != 200) {
    throw Exception('error getting weather for location');
  }

  final weatherJson = jsonDecode(weatherResponse.body);
  return Weather.fromJson(weatherJson);
}
```

Здесь мы снова делаем простой HTTP-запрос и декодируем ответ в JSON. Вы заметите, что нам снова нужно импортировать зависимость, но на этот раз модель `Weather`. В верхней части файла импортируем его так:

```dart
import 'package:flutter_weather/models/models.dart';
```

#### Экспорт WeatherApiClient

Теперь, когда у нас есть класс с двумя методами, давайте продолжим и экспортируем его в файл индекса. Внутри `repositories.dart` добавьте:

`export 'weather_api_client.dart';`

#### Что далее

Мы сделали `DataProvider`, поэтому пришло время перейти на следующий уровень архитектуры нашего приложения: **уровень хранилища**.

## Хранилище

> `WeatherRepository` служит абстракцией между клиентским кодом и поставщиком данных, поэтому разработчик, работающий над функционалом, не должен знать откуда поступают данные. Наш `WeatherRepository` будет зависеть от `WeatherApiClient`, который мы только что создали и предоставит единственный открытый метод, который, как вы уже догадались, называется `getWeather(String city)`. Никто не должен знать что нам нужно сделать два вызова API (один для locationId и один для погоды), потому что на самом деле это никого не волнует. Все, о чем мы заботимся, это получение `Weather` для данного города.

### Создание хранилища

Этот файл может жить в папке хранилища. Итак, создайте файл с именем `weather_repository.dart` и откройте его.

Наш `WeatherRepository` довольно прост и должен выглядеть примерно так:

```dart
import 'dart:async';

import 'package:meta/meta.dart';

import 'package:flutter_weather/repositories/weather_api_client.dart';
import 'package:flutter_weather/models/models.dart';

class WeatherRepository {
  final WeatherApiClient weatherApiClient;

  WeatherRepository({@required this.weatherApiClient})
      : assert(weatherApiClient != null);

  Future<Weather> getWeather(String city) async {
    final int locationId = await weatherApiClient.getLocationId(city);
    return weatherApiClient.fetchWeather(locationId);
  }
}
```

#### Экспорт хранилища в индекс

Сначала откройте `repositories.dart` и сделайте экспорт так:

`export 'weather_repository.dart';`

Потрясающие! Теперь мы готовы перейти на уровень бизнес-логики и приступить к созданию `WeatherBloc`.

## Бизнес логика (Bloc)

> Наш `WeatherBloc` отвечает за получение `WeatherEvents` и преобразование их в `WeatherStates`. Он будет зависеть от `WeatherRepository` чтобы получить `Weather` когда пользователь вводит город по своему выбору.

### Создание первого блока

В этом руководстве мы создадим несколько блоков, поэтому давайте создадим внутри `lib` папку с именем `blocs`. Опять же, поскольку у нас будет несколько блоков, давайте сначала создадим индексный файл с именем `blocs.dart` внутри нашей папки `blocs`.

Прежде чем перейти к блоку, нам нужно определить, какие события будет обрабатывать наш `WeatherBloc`, а также, как мы будем представлять `WeatherState`. Чтобы наши файлы были небольшими мы разделим `event`, `state` и `bloc` на три файла.

#### Weather события

Давайте создадим файл с именем `weather_event.dart` внутри папки `blocs`. Для простоты мы собираемся начать с одного события под названием `FetchWeather`.

Мы можем определить его так:

```dart
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class WeatherEvent extends Equatable {
  const WeatherEvent();
}

class FetchWeather extends WeatherEvent {
  final String city;

  const FetchWeather({@required this.city}) : assert(city != null);

  @override
  List<Object> get props => [city];
}
```

Всякий раз, когда пользователь вводит город, мы `добавляем` событие `FetchWeather` с указанным городом и наш блок будет отвечать за выяснение погоды и возвращать новый `WeatherState`.

Теперь давайте экспортируем класс в наш индексный файл. Внутри `blocs.dart` добавьте:

`export 'weather_event.dart';`

#### Weather состояния

Далее давайте создадим наш файл `state`. Внутри папки `blocs` создайте файл с именем `weather_state.dart` где будет жить наш `WeatherState`.

Для текущего приложения у нас будет 4 возможных состояния:

- `WeatherEmpty` - начальное состояние, в котором не будет данных о погоде, потому что пользователь еще не выбрал город
- `WeatherLoading` - состояние, которое будет происходить пока мы выбираем погоду для данного города
- `WeatherLoaded` - состояние, которое возникнет если мы сможем успешно выбрать погоду для данного города.
- `WeatherError` - состояние, которое возникнет если мы не сможем выбрать погоду для данного города.

Мы можем представить эти состояния так:

```dart
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

import 'package:flutter_weather/models/models.dart';

abstract class WeatherState extends Equatable {
  const WeatherState();

  @override
  List<Object> get props => [];
}

class WeatherEmpty extends WeatherState {}

class WeatherLoading extends WeatherState {}

class WeatherLoaded extends WeatherState {
  final Weather weather;

  const WeatherLoaded({@required this.weather}) : assert(weather != null);

  @override
  List<Object> get props => [weather];
}

class WeatherError extends WeatherState {}
```

Теперь давайте экспортируем этот класс в наш индексный файл. Внутри `blocs.dart` добавьте:

`export 'weather_state.dart';`

Теперь когда у нас определены и реализованы наши `Events` и `States` мы готовы создать наш `WeatherBloc`.

#### Блок погоды

> `WeatherBloc` очень прост. Напомним, что он преобразует `WeatherEvents` в `WeatherStates` и зависит от `WeatherRepository`.

?> **Совет:** Изучите [Расширение Bloc VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc#overview), чтобы воспользоваться фрагментами кода и улучшить вашу эффективность и скорость разработки.

Теперь создайте файл внутри папки `blocs` с именем `weather_bloc.dart` и добавьте следующее:

```dart
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';

import 'package:flutter_weather/repositories/repositories.dart';
import 'package:flutter_weather/models/models.dart';
import 'package:flutter_weather/blocs/blocs.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherRepository weatherRepository;

  WeatherBloc({@required this.weatherRepository})
      : assert(weatherRepository != null);

  @override
  WeatherState get initialState => WeatherEmpty();

  @override
  Stream<WeatherState> mapEventToState(WeatherEvent event) async* {
    if (event is FetchWeather) {
      yield WeatherLoading();
      try {
        final Weather weather = await weatherRepository.getWeather(event.city);
        yield WeatherLoaded(weather: weather);
      } catch (_) {
        yield WeatherError();
      }
    }
  }
}
```

Мы установили для `initialState` значение `WeatherEmpty` поскольку изначально пользователь не выбрал город. Теперь все, что осталось, это реализовать `mapEventToState`.

Поскольку мы обрабатываем только событие `FetchWeather`, все что нам нужно сделать, это выдать (`yield`) наше состояние `WeatherLoading` когда мы получим событие `FetchWeather`, а затем попытаться получить погоду из `WeatherRepository`.

Если мы можем успешно получить погоду, то мы выдаем состояние `WeatherLoaded`, а если мы не можем получить погоду, мы выдаем состояние `WeatherError`.

Теперь экспортируйте этот класс в `blocs.dart`:

`export 'weather_bloc.dart';`

Это все что нужно сделать! Теперь мы готовы перейти к последнему слою: уровню представления.

## Представление

### Настройка

Как вы, вероятно, уже видели в других руководствах, мы собираемся создать `SimpleBlocDelegate`, чтобы мы могли видеть все переходы состояний в нашем приложении. Давайте продолжим, создадим `simple_bloc_delegate.dart` и собственный пользовательский делегат.

```dart
import 'package:bloc/bloc.dart';

class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onEvent(Bloc bloc, Object event) {
    super.onEvent(bloc, event);
    print('onEvent $event');
  }

  @override
  onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print('onTransition $transition');
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
    print('onError $error');
  }
}
```

Теперь мы можем импортировать его в файл `main.dart` и установить наш делегат так:

```dart
import 'package:flutter_weather/simple_bloc_delegate.dart';

void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();
  runApp(App());
}
```

Наконец, нам нужно создать `WeatherRepository` и добавить его в виджет `App` (который мы создадим на следующем шаге).

```dart
import 'package:flutter_weather/repositories/repositories.dart';
import 'package:http/http.dart' as http;

void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();

  final WeatherRepository weatherRepository = WeatherRepository(
    weatherApiClient: WeatherApiClient(
      httpClient: http.Client(),
    ),
  );

  runApp(App(weatherRepository: weatherRepository));
}
```

### Виджет App

Наш виджет `App` будет `StatelessWidget` виджетом, в который внедряется `WeatherRepository` и который создает `MaterialApp` с виджетом `Weather` (который мы создадим на следующем шаге). Мы используем виджет `BlocProvider`, чтобы создать экземпляр `WeatherBloc` и сделать его доступным для виджета `Weather` и его дочерних элементов. Кроме того, `BlocProvider` управляет созданием и закрытием `WeatherBloc`.

```dart
class App extends StatelessWidget {
  final WeatherRepository weatherRepository;

  App({Key key, @required this.weatherRepository})
      : assert(weatherRepository != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Weather',
      home: BlocProvider(
        create: (context) =>
            WeatherBloc(weatherRepository: weatherRepository),
        child: Weather(),
      ),
    );
  }
}
```

### Погода

Теперь нам нужно создать виджет погоды. Создайте папку с именем `widgets` внутри `lib` и создайте индексный файл внутри с именем `widgets.dart`. Затем создайте файл с именем `weather.dart`.

> Виджет `Weather` будет `StatelessWidget` виджетом, отвечающим за отображение различных данных о погоде.

#### Создание Stateless виджета

```dart
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_weather/widgets/widgets.dart';
import 'package:flutter_weather/blocs/blocs.dart';

class Weather extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Weather'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              final city = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CitySelection(),
                ),
              );
              if (city != null) {
                BlocProvider.of<WeatherBloc>(context)
                    .add(FetchWeather(city: city));
              }
            },
          )
        ],
      ),
      body: Center(
        child: BlocBuilder<WeatherBloc, WeatherState>(
          builder: (context, state) {
            if (state is WeatherEmpty) {
              return Center(child: Text('Please Select a Location'));
            }
            if (state is WeatherLoading) {
              return Center(child: CircularProgressIndicator());
            }
            if (state is WeatherLoaded) {
              final weather = state.weather;

              return ListView(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 100.0),
                    child: Center(
                      child: Location(location: weather.location),
                    ),
                  ),
                  Center(
                    child: LastUpdated(dateTime: weather.lastUpdated),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 50.0),
                    child: Center(
                      child: CombinedWeatherTemperature(
                        weather: weather,
                      ),
                    ),
                  ),
                ],
              );
            }
            if (state is WeatherError) {
              return Text(
                'Something went wrong!',
                style: TextStyle(color: Colors.red),
              );
            }
          },
        ),
      ),
    );
  }
}
```

Все, что происходит в этом виджете, это то, что мы используем `BlocBuilder` с нашим `WeatherBloc`, чтобы перестроить наш пользовательский интерфейс на основе изменений состояния нашего `WeatherBloc`.

Экспортируем `Weather` в файл `widgets.dart`.

Вы заметите, что мы ссылаемся на виджет `CitySelection`, `Location`, `LastUpdated` и `CombinedWeatherTemperature`, который мы создадим в следующих разделах.

### Виджет местоположения

Создайте файл с именем `location.dart` внутри папки `widgets`.

> Виджет `Location` прост; он отображает текущее местоположение.

```dart
import 'package:flutter/material.dart';

class Location extends StatelessWidget {
  final String location;

  Location({Key key, @required this.location})
      : assert(location != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      location,
      style: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}
```

Обязательно экспортируйте его в файле `widgets.dart`.

### Последние обновления

Затем создайте файл `last_updated.dart` внутри папки `widgets`.

> Виджет `LastUpdated` также очень прост; он отображает время последнего обновления, чтобы пользователи знали, насколько свежи данные о погоде.

```dart
import 'package:flutter/material.dart';

class LastUpdated extends StatelessWidget {
  final DateTime dateTime;

  LastUpdated({Key key, @required this.dateTime})
      : assert(dateTime != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      'Updated: ${TimeOfDay.fromDateTime(dateTime).format(context)}',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w200,
        color: Colors.white,
      ),
    );
  }
}
```

Обязательно экспортируйте его в файл `widgets.dart`.

?> **Примечание:** Мы используем [`TimeOfDay`](https://docs.flutter.io/flutter/material/TimeOfDay-class.html) для форматирования `DateTime` в более понятный для человека формат.

### Комбинированная температура

Теперь создайте файл `combined_weather_temperature.dart` внутри папки `widgets`.

> Виджет `CombinedWeatherTemperature` - это составной виджет, который отображает текущую погоду вместе с температурой. Мы по-прежнему собираемся создать виджеты `Temperature` и `WeatherConditions` в виде модулей, чтобы их можно было повторно использовать.

```dart
import 'package:flutter/material.dart';

import 'package:flutter_weather/models/models.dart' as model;
import 'package:flutter_weather/widgets/widgets.dart';

class CombinedWeatherTemperature extends StatelessWidget {
  final model.Weather weather;

  CombinedWeatherTemperature({
    Key key,
    @required this.weather,
  })  : assert(weather != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(20.0),
              child: WeatherConditions(condition: weather.condition),
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Temperature(
                temperature: weather.temp,
                high: weather.maxTemp,
                low: weather.minTemp,
              ),
            ),
          ],
        ),
        Center(
          child: Text(
            weather.formattedCondition,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w200,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
```

Обязательно экспортируйте его в файл `widgets.dart`.

?> **Примечание:** Мы используем два еще не реализованных виджета: `WeatherConditions` и `Temperature`, которые мы создадим дальше.

### Погодные условия

Теперь создайте файл `weather_conditions.dart` внутри папки `widgets`.

> Виджет `WeatherConditions` будет отвечать за отображение текущих погодных условий (ясно, ливни, грозы и т.д.) вместе с соответствующим значком.

```dart
import 'package:flutter/material.dart';

import 'package:flutter_weather/models/models.dart';

class WeatherConditions extends StatelessWidget {
  final WeatherCondition condition;

  WeatherConditions({Key key, @required this.condition})
      : assert(condition != null),
        super(key: key);

  @override
  Widget build(BuildContext context) => _mapConditionToImage(condition);

  Image _mapConditionToImage(WeatherCondition condition) {
    Image image;
    switch (condition) {
      case WeatherCondition.clear:
      case WeatherCondition.lightCloud:
        image = Image.asset('assets/clear.png');
        break;
      case WeatherCondition.hail:
      case WeatherCondition.snow:
      case WeatherCondition.sleet:
        image = Image.asset('assets/snow.png');
        break;
      case WeatherCondition.heavyCloud:
        image = Image.asset('assets/cloudy.png');
        break;
      case WeatherCondition.heavyRain:
      case WeatherCondition.lightRain:
      case WeatherCondition.showers:
        image = Image.asset('assets/rainy.png');
        break;
      case WeatherCondition.thunderstorm:
        image = Image.asset('assets/thunderstorm.png');
        break;
      case WeatherCondition.unknown:
        image = Image.asset('assets/clear.png');
        break;
    }
    return image;
  }
}
```

Обязательно экспортируйте его в файл `widgets.dart`.

Здесь вы можете увидеть, что мы используем некоторые ресурсы. Пожалуйста, загрузите их [отсюда](https://github.com/felangel/bloc/tree/master/examples/flutter_weather/assets) и добавьте их в каталог `assets/`, который мы создали в начале проекта.

?> **Совет:** Проверьте [icons8](https://icons8.com/icon/set/weather/office) ресурсы, используемые в этом руководстве.

### Температура

Теперь создайте файл `temperature.dart` внутри папки `widgets`.

> Виджет `Temperature` будет отображать среднюю, минимальную и максимальную температуры.

```dart
import 'package:flutter/material.dart';

class Temperature extends StatelessWidget {
  final double temperature;
  final double low;
  final double high;

  Temperature({
    Key key,
    this.temperature,
    this.low,
    this.high,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.only(right: 20.0),
          child: Text(
            '${_formattedTemperature(temperature)}°',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        Column(
          children: [
            Text(
              'max: ${_formattedTemperature(high)}°',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w100,
                color: Colors.white,
              ),
            ),
            Text(
              'min: ${_formattedTemperature(low)}°',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w100,
                color: Colors.white,
              ),
            )
          ],
        )
      ],
    );
  }

  int _formattedTemperature(double t) => t.round();
}
```

Обязательно экспортируйте его в файл `widgets.dart`.

### Выбор города

Последнее, что нам нужно реализовать для полнофункционального приложения - это виджет `CitySelection`, который позволяет пользователям вводить название города. Создайте файл `city_selection.dart` внутри папки `widgets`.

> Виджет `CitySelection` позволит пользователям вводить название города и передавать выбранный город обратно в виджет `App`.

```dart
import 'package:flutter/material.dart';

class CitySelection extends StatefulWidget {
  @override
  State<CitySelection> createState() => _CitySelectionState();
}

class _CitySelectionState extends State<CitySelection> {
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('City'),
      ),
      body: Form(
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: TextFormField(
                  controller: _textController,
                  decoration: InputDecoration(
                    labelText: 'City',
                    hintText: 'Chicago',
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                Navigator.pop(context, _textController.text);
              },
            )
          ],
        ),
      ),
    );
  }
}
```

Обязательно экспортируйте его в файл `widgets.dart`.

Это должен быть `StatefulWidget`, потому что он должен поддерживать `TextController`.

?> **Примечание:** Когда мы нажимаем кнопку поиска, мы используем `Navigator.pop` и передаем текущий текст из нашего `TextController` обратно в предыдущее представление.

## Запуск приложения

Теперь, когда мы создали все наши виджеты, давайте вернемся к файлу `main.dart`. Вы увидите, что нам нужно импортировать наш виджет `Weather`, поэтому добавьте эту строку вверху.

`import 'package:flutter_weather/widgets/widgets.dart';`

Теперь вы можете запустить приложение и выполнить `flutter run` в терминале. Сначала выберите город и вы заметите, что у него есть несколько проблем:

- Фон белый и текст очень тяжело читать
- У нас нет возможности обновить данные о погоде после получения
- Пользовательский интерфейс очень прост
- Все в градусах Цельсия и у нас нет возможности поменять единицы

Давайте рассмотрим эти проблемы и выведем наше приложение `Weather` на новый уровень!

## Протягивание до обновления

> Чтобы поддерживать функцию `протягивание до обновления` (`pull-to-refresh`), нам нужно обновить `WeatherEvent` для обработки второго события: `RefreshWeather`. Давайте добавим следующий код в `blocs/weather_event.dart`

```dart
class RefreshWeather extends WeatherEvent {
  final String city;

  const RefreshWeather({@required this.city}) : assert(city != null);

  @override
  List<Object> get props => [city];
}
```

Теперь нам нужно обновить наш `mapEventToState` внутри `weather_bloc.dart` для обработки события `RefreshWeather`. Сначала добавьте еще одно выражение `if` ниже существующего.

```dart
if (event is RefreshWeather) {
  try {
    final Weather weather = await weatherRepository.getWeather(event.city);
    yield WeatherLoaded(weather: weather);
  } catch (_) {
    yield state;
  }
}
```

Здесь мы просто создаем новое событие, которое попросит наш `weatherRepository` сделать вызов API, чтобы узнать погоду для города.

Мы можем реорганизовать `mapEventToState` для использования некоторых частных вспомогательных функций, чтобы сохранить код организованным и легким для понимания:

```dart
@override
Stream<WeatherState> mapEventToState(WeatherEvent event) async* {
  if (event is FetchWeather) {
    yield* _mapFetchWeatherToState(event);
  } else if (event is RefreshWeather) {
    yield* _mapRefreshWeatherToState(event);
  }
}

Stream<WeatherState> _mapFetchWeatherToState(FetchWeather event) async* {
  yield WeatherLoading();
  try {
    final Weather weather = await weatherRepository.getWeather(event.city);
    yield WeatherLoaded(weather: weather);
  } catch (_) {
    yield WeatherError();
  }
}

Stream<WeatherState> _mapRefreshWeatherToState(RefreshWeather event) async* {
  try {
    final Weather weather = await weatherRepository.getWeather(event.city);
    yield WeatherLoaded(weather: weather);
  } catch (_) {
    yield state;
  }
}
```

Наконец, нам нужно обновить наш уровень представления, чтобы использовать виджет `RefreshIndicator`. Давайте продолжим и изменим наш виджет `Weather` в `widgets/weather.dart`. Есть несколько вещей, которые нам нужно сделать.

- Импортировать `async` в файл `weather.dart` для обработки `Future`

`import 'dart:async';`

- Добавить `Completer`

```dart
class Weather extends StatefulWidget {
  State<Weather> createState() => _WeatherState();
}

class _WeatherState extends State<Weather> {
  Completer<void> _refreshCompleter;

  @override
  void initState() {
    super.initState();
    _refreshCompleter = Completer<void>();
  }

  @override
  Widget build(BuildContext) {
    ...
  }
```

Поскольку нашему виджету `Weather` нужно будет поддерживать экземпляр `Completer`, нам необходимо изменить его на `StatefulWidget`. Затем мы можем инициализировать `Completer` в `initState`.

- Внутри метода `build` виджета давайте обернем `ListView` в виджет `RefreshIndicator` как показано ниже. Затем вернем `_refreshCompleter.future` когда произойдет обратный вызов `onRefresh`.

```dart
return RefreshIndicator(
  onRefresh: () {
    BlocProvider.of<WeatherBloc>(context).add(
      RefreshWeather(city: state.weather.location),
    );
    return _refreshCompleter.future;
  },
  child: ListView(
    children: <Widget>[
      Padding(
        padding: EdgeInsets.only(top: 100.0),
        child: Center(
          child: Location(location: weather.location),
        ),
      ),
      Center(
        child: LastUpdated(dateTime: weather.lastUpdated),
      ),
      Padding(
        padding: EdgeInsets.symmetric(vertical: 50.0),
        child: Center(
          child: CombinedWeatherTemperature(
            weather: weather,
          ),
        ),
      ),
    ],
  ),
);
```

Чтобы использовать `RefreshIndicator`, нам нужно было создать [`Completer`](https://api.dartlang.org/stable/2.1.0/dart-async/Completer-class.html), который позволяет нам создавать `Future` и мы сделаем это позже.

Это оно! Теперь мы решили проблему N1 и пользователи могут обновить погоду, потянув вниз. Не стесняйтесь снова запустить `flutter run` и попробовать обновить погоду.

Далее давайте займемся простым интерфейсом, создав `ThemeBloc`.

## Динамические темы

> `ThemeBloc` будет отвечать за преобразование `ThemeEvents` в `ThemeStates`.

`ThemeEvents` будут состоять из одного события под названием `WeatherChanged`, которое будет добавляться при изменении погодных условий, которые мы отображаем.

```dart
abstract class ThemeEvent extends Equatable {
  const ThemeEvent();
}

class WeatherChanged extends ThemeEvent {
  final WeatherCondition condition;

  const WeatherChanged({@required this.condition}) : assert(condition != null);

  @override
  List<Object> get props => [condition];
}
```

`ThemeState` будет состоять из `ThemeData` и `MaterialColor`, которые мы будем использовать для улучшения нашего пользовательского интерфейса.

```dart
class ThemeState extends Equatable {
  final ThemeData theme;
  final MaterialColor color;

  const ThemeState({@required this.theme, @required this.color})
      : assert(theme != null),
        assert(color != null);

  @override
  List<Object> get props => [theme, color];
}
```

Теперь мы можем реализовать `ThemeBloc`, который должен выглядеть следующим образом:

```dart
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  @override
  ThemeState get initialState => ThemeState(
        theme: ThemeData.light(),
        color: Colors.lightBlue,
      );

  @override
  Stream<ThemeState> mapEventToState(ThemeEvent event) async* {
    if (event is WeatherChanged) {
      yield _mapWeatherConditionToThemeData(event.condition);
    }
  }

  ThemeState _mapWeatherConditionToThemeData(WeatherCondition condition) {
    ThemeState theme;
    switch (condition) {
      case WeatherCondition.clear:
      case WeatherCondition.lightCloud:
        theme = ThemeState(
          theme: ThemeData(
            primaryColor: Colors.orangeAccent,
          ),
          color: Colors.yellow,
        );
        break;
      case WeatherCondition.hail:
      case WeatherCondition.snow:
      case WeatherCondition.sleet:
        theme = ThemeState(
          theme: ThemeData(
            primaryColor: Colors.lightBlueAccent,
          ),
          color: Colors.lightBlue,
        );
        break;
      case WeatherCondition.heavyCloud:
        theme = ThemeState(
          theme: ThemeData(
            primaryColor: Colors.blueGrey,
          ),
          color: Colors.grey,
        );
        break;
      case WeatherCondition.heavyRain:
      case WeatherCondition.lightRain:
      case WeatherCondition.showers:
        theme = ThemeState(
          theme: ThemeData(
            primaryColor: Colors.indigoAccent,
          ),
          color: Colors.indigo,
        );
        break;
      case WeatherCondition.thunderstorm:
        theme = ThemeState(
          theme: ThemeData(
            primaryColor: Colors.deepPurpleAccent,
          ),
          color: Colors.deepPurple,
        );
        break;
      case WeatherCondition.unknown:
        theme = ThemeState(
          theme: ThemeData.light(),
          color: Colors.lightBlue,
        );
        break;
    }
    return theme;
  }
}
```

Несмотря на то что кода много, единственная вещь здесь - это логика для преобразования условия `WeatherCondition` в новое состояние `ThemeState`.

Теперь мы можем обновить `main`, `ThemeBloc` и предоставить его нашему `App`.

```dart
void main() {
  final WeatherRepository weatherRepository = WeatherRepository(
    weatherApiClient: WeatherApiClient(
      httpClient: http.Client(),
    ),
  );
  BlocSupervisor.delegate = SimpleBlocDelegate();
  runApp(
    BlocProvider<ThemeBloc>(
      create: (context) => ThemeBloc(),
      child: App(weatherRepository: weatherRepository),
    ),
  );
}
```

Виджет `App` может теперь использовать `BlocBuilder`, чтобы реагировать на изменения в `ThemeState`.

```dart
class App extends StatelessWidget {
  final WeatherRepository weatherRepository;

  App({Key key, @required this.weatherRepository})
      : assert(weatherRepository != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return MaterialApp(
          title: 'Flutter Weather',
          theme: themeState.theme,
          home: BlocProvider(
            create: (context) =>
                WeatherBloc(weatherRepository: weatherRepository),
            child: Weather(),
          ),
        );
      },
    );
  }
}
```

?> **Примечание:** Мы используем `BlocProvider`, чтобы сделать `ThemeBloc` глобально доступным, используя `BlocProvider.of<ThemeBloc>(context)`.

Последнее, что нам нужно сделать, это создать классный виджет `GradientContainer`, который будет окрашивать наш фон в соответствии с текущими погодными условиями.

```dart
import 'package:flutter/material.dart';

import 'package:meta/meta.dart';

class GradientContainer extends StatelessWidget {
  final Widget child;
  final MaterialColor color;

  const GradientContainer({
    Key key,
    @required this.color,
    @required this.child,
  })  : assert(color != null, child != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.6, 0.8, 1.0],
          colors: [
            color[700],
            color[500],
            color[300],
          ],
        ),
      ),
      child: child,
    );
  }
}
```

Теперь мы можем использовать `GradientContainer` в виджете `Weather` следующим образом:

```dart
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_weather/widgets/widgets.dart';
import 'package:flutter_weather/repositories/repositories.dart';
import 'package:flutter_weather/blocs/blocs.dart';

class Weather extends StatefulWidget {
  @override
  State<Weather> createState() => _WeatherState();
}

class _WeatherState extends State<Weather> {
  Completer<void> _refreshCompleter;

  @override
  void initState() {
    super.initState();
    _refreshCompleter = Completer<void>();
  }

  @override
  Widget build(BuildContext context) {
    final weatherBloc = BlocProvider.of<WeatherBloc>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Weather'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              final city = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CitySelection(),
                ),
              );
              if (city != null) {
                BlocProvider.of<WeatherBloc>(context)
                    .add(FetchWeather(city: city));
              }
            },
          )
        ],
      ),
      body: Center(
        child: BlocListener<WeatherBloc, WeatherState>(
          listener: (context, state) {
            if (state is WeatherLoaded) {
              BlocProvider.of<ThemeBloc>(context).add(
                WeatherChanged(condition: state.weather.condition),
              );
              _refreshCompleter?.complete();
              _refreshCompleter = Completer();
            }
          },
          child: BlocBuilder<WeatherBloc, WeatherState>(
            builder: (context, state) {
              if (state is WeatherEmpty) {
                return Center(child: Text('Please Select a Location'));
              }
              if (state is WeatherLoading) {
                return Center(child: CircularProgressIndicator());
              }
              if (state is WeatherLoaded) {
                final weather = state.weather;

                return BlocBuilder<ThemeBloc, ThemeState>(
                  builder: (context, themeState) {
                    return GradientContainer(
                      color: themeState.color,
                      child: RefreshIndicator(
                        onRefresh: () {
                          BlocProvider.of<WeatherBloc>(context).add(
                            RefreshWeather(city: weather.location),
                          );
                          return _refreshCompleter.future;
                        },
                        child: ListView(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(top: 100.0),
                              child: Center(
                                child: Location(location: weather.location),
                              ),
                            ),
                            Center(
                              child: LastUpdated(dateTime: weather.lastUpdated),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 50.0),
                              child: Center(
                                child: CombinedWeatherTemperature(
                                  weather: weather,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
              if (state is WeatherError) {
                return Text(
                  'Something went wrong!',
                  style: TextStyle(color: Colors.red),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
```

Поскольку мы хотим "что-то сделать" в ответ на изменения состояния в `WeatherBloc`, мы используем `BlocListener`. В этом случае мы завершаем и сбрасываем `Completer`, а также добавляем событие `WeatherChanged` в `ThemeBloc`.

?> **Совет:** Проверьте [SnackBar Recipe](ru/recipesfluttershowsnackbar.md) для получения дополнительной информации о виджете `BlocListener`.

Мы обращаемся к `ThemeBloc` через `BlocProvider.of<ThemeBloc>(context)` и добавляем событие `WeatherChanged` в каждый `WeatherLoad`.

Мы также обернули виджет `GradientContainer` с помощью `BlocBuilder` из `ThemeBloc`, чтобы мы могли перестроить `GradientContainer` и его дочерние элементы в ответ на изменения `ThemeState`.

Потрясающе! Теперь у нас есть приложение, которое выглядит намного лучше (на мой взгляд: P) и решает проблему N2.

Осталось только перевести единицы в градусы Цельсия и Фаренгейта. Для этого мы создадим виджет `Settings` и `SettingsBloc`.

## Преобразование единиц измерения

Мы начнем с создания нашего `SettingsBloc`, который преобразует `SettingsEvents` в `SettingsStates`.

`SettingsEvents` будут состоять из одного события: `TemperatureUnitsToggled`.

```dart
abstract class SettingsEvent extends Equatable {}

class TemperatureUnitsToggled extends SettingsEvent {
  @override
  List<Object> get props => [];
}
```

`SettingsState` будет просто состоять из текущих `TemperatureUnits`.

```dart
enum TemperatureUnits { fahrenheit, celsius }

class SettingsState extends Equatable {
  final TemperatureUnits temperatureUnits;

  const SettingsState({@required this.temperatureUnits})
      : assert(temperatureUnits != null);

  @override
  List<Object> get props => [temperatureUnits];
}
```

Наконец, нам нужно создать наш `SettingsBloc`:

```dart
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  @override
  SettingsState get initialState =>
      SettingsState(temperatureUnits: TemperatureUnits.celsius);

  @override
  Stream<SettingsState> mapEventToState(SettingsEvent event) async* {
    if (event is TemperatureUnitsToggled) {
      yield SettingsState(
        temperatureUnits: state.temperatureUnits == TemperatureUnits.celsius
            ? TemperatureUnits.fahrenheit
            : TemperatureUnits.celsius,
      );
    }
  }
}
```

Все, что мы делаем, это используем `fahrenheit` если добавляется `TemperatureUnitsToggled` или наоборот - единицы измерения `celsius` в другом случае.

Теперь нам нужно предоставить `SettingsBloc` виджету `App` в `main.dart`.

```dart
void main() {
  final WeatherRepository weatherRepository = WeatherRepository(
    weatherApiClient: WeatherApiClient(
      httpClient: http.Client(),
    ),
  );
  BlocSupervisor.delegate = SimpleBlocDelegate();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>(
          create: (context) => ThemeBloc(),
        ),
        BlocProvider<SettingsBloc>(
          create: (context) => SettingsBloc(),
        ),
      ],
      child: App(weatherRepository: weatherRepository),
    ),
  );
}
```

Опять же, мы делаем `SettingsBloc` глобально доступным, используя `BlocProvider` и мы также закрываем его в обратном вызове `close`. Однако на этот раз, поскольку мы выставляем более одного блока с помощью `BlocProvider` на одном уровне, мы можем устранить некоторую вложенность с помощью виджета `MultiBlocProvider`.

Теперь нам нужно создать виджет `Settings`, в котором пользователи могут переключать единицы измерения.

```dart
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_weather/blocs/blocs.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settingsBloc = BlocProvider.of<SettingsBloc>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        children: <Widget>[
          BlocBuilder<SettingsBloc, SettingsState>(
              builder: (context, state) {
                return ListTile(
                  title: Text(
                    'Temperature Units',
                  ),
                  isThreeLine: true,
                  subtitle:
                      Text('Use metric measurements for temperature units.'),
                  trailing: Switch(
                    value: state.temperatureUnits == TemperatureUnits.celsius,
                    onChanged: (_) => BlocProvider.of<SettingsBloc>(context)
                        .add(TemperatureUnitsToggled()),
                  ),
                );
              }),
        ],
      ),
    );
  }
}
```

Мы используем `BlocProvider` для доступа к `SettingsBloc` через `BuildContext`, а затем с помощью `BlocBuilder` перестраиваем наш пользовательский интерфейс на основе измененного `SettingsState`.

Наш пользовательский интерфейс состоит из `ListView` с одним `ListTile`, который содержит `Switch`, предназначенный для переключения единиц измерения либо в Цельсиях либо в Фаренгейтах.

?> **Примечание:** В методе переключателя `onChanged` мы добавляем событие `TemperatureUnitsToggled`, чтобы уведомить `SettingsBloc` об изменении единиц температуры.

Далее нам нужно разрешить пользователям получать доступ к виджету `Settings` из виджета `Weather`.

Мы можем сделать это, добавив новый `IconButton` в `AppBar`.

```dart
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_weather/widgets/widgets.dart';
import 'package:flutter_weather/repositories/repositories.dart';
import 'package:flutter_weather/blocs/blocs.dart';

class Weather extends StatefulWidget {
  @override
  State<Weather> createState() => _WeatherState();
}

class _WeatherState extends State<Weather> {
  Completer<void> _refreshCompleter;

  @override
  void initState() {
    super.initState();
    _refreshCompleter = Completer<void>();
  }

  @override
  Widget build(BuildContext context) {
    final weatherBloc = BlocProvider.of<WeatherBloc>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Weather'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Settings(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              final city = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CitySelection(),
                ),
              );
              if (city != null) {
                BlocProvider.of<WeatherBloc>(context)
                    .add(FetchWeather(city: city));
              }
            },
          )
        ],
      ),
      body: Center(
        child: BlocListener<WeatherBloc, WeatherState>(
          listener: (context, state) {
            if (state is WeatherLoaded) {
              BlocProvider.of<ThemeBloc>(context).add(
                WeatherChanged(condition: state.weather.condition),
              );
              _refreshCompleter?.complete();
              _refreshCompleter = Completer();
            }
          },
          child: BlocBuilder<WeatherBloc, WeatherState>(
            builder: (context, state) {
              if (state is WeatherEmpty) {
                return Center(child: Text('Please Select a Location'));
              }
              if (state is WeatherLoading) {
                return Center(child: CircularProgressIndicator());
              }
              if (state is WeatherLoaded) {
                final weather = state.weather;

                return BlocBuilder<ThemeBloc, ThemeState>(
                  builder: (context, themeState) {
                    return GradientContainer(
                      color: themeState.color,
                      child: RefreshIndicator(
                        onRefresh: () {
                          BlocProvider.of<WeatherBloc>(context).add(
                            RefreshWeather(city: weather.location),
                          );
                          return _refreshCompleter.future;
                        },
                        child: ListView(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(top: 100.0),
                              child: Center(
                                child: Location(location: weather.location),
                              ),
                            ),
                            Center(
                              child: LastUpdated(dateTime: weather.lastUpdated),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 50.0),
                              child: Center(
                                child: CombinedWeatherTemperature(
                                  weather: weather,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
              if (state is WeatherError) {
                return Text(
                  'Something went wrong!',
                  style: TextStyle(color: Colors.red),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
```

Мы почти закончили! Нам просто нужно обновить виджет `Temperature`, чтобы реагировать на текущие единицы измерения.

```dart
import 'package:flutter/material.dart';

import 'package:flutter_weather/blocs/blocs.dart';

class Temperature extends StatelessWidget {
  final double temperature;
  final double low;
  final double high;
  final TemperatureUnits units;

  Temperature({
    Key key,
    this.temperature,
    this.low,
    this.high,
    this.units,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.only(right: 20.0),
          child: Text(
            '${_formattedTemperature(temperature)}°',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        Column(
          children: [
            Text(
              'max: ${_formattedTemperature(high)}°',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w100,
                color: Colors.white,
              ),
            ),
            Text(
              'min: ${_formattedTemperature(low)}°',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w100,
                color: Colors.white,
              ),
            )
          ],
        )
      ],
    );
  }

  int _toFahrenheit(double celsius) => ((celsius * 9 / 5) + 32).round();

  int _formattedTemperature(double t) =>
      units == TemperatureUnits.fahrenheit ? _toFahrenheit(t) : t.round();
}
```

И наконец, нам нужно добавить `TemperatureUnits` в виджет `Temperature`.

```dart
import 'package:flutter/material.dart';

import 'package:meta/meta.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_weather/blocs/blocs.dart';
import 'package:flutter_weather/models/models.dart' as model;
import 'package:flutter_weather/widgets/widgets.dart';

class CombinedWeatherTemperature extends StatelessWidget {
  final model.Weather weather;

  CombinedWeatherTemperature({
    Key key,
    @required this.weather,
  })  : assert(weather != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(20.0),
              child: WeatherConditions(condition: weather.condition),
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: BlocBuilder<SettingsBloc, SettingsState>(
                builder: (context, state) {
                  return Temperature(
                    temperature: weather.temp,
                    high: weather.maxTemp,
                    low: weather.minTemp,
                    units: state.temperatureUnits,
                  );
                },
              ),
            ),
          ],
        ),
        Center(
          child: Text(
            weather.formattedCondition,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w200,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
```

Вот и все, что нужно сделать! Теперь мы успешно внедрили приложение погоды во Flutter, используя пакеты [bloc](https://pub.dev/packages/bloc) и [flutter_bloc](https://pub.dev/packages/flutter_bloc) и мы успешно отделили наш уровень представления от нашей бизнес логики.

Полный исходный код этого примера можно найти [здесь](https://github.com/felangel/Bloc/tree/master/examples/flutter_weather).

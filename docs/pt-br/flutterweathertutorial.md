# Tutorial Clima Flutter

![avançado](https://img.shields.io/badge/level-advanced-red.svg)

> No tutorial a seguir, criaremos um aplicativo de Clima em Flutter que demonstre como gerenciar vários blocs para implementar temas dinâmicos, pull-to-refresh e muito mais. Nosso aplicativo meteorológico extrai dados reais de uma API e demonstra como separar nosso aplicativo em três camadas (dados, lógica de negócios e apresentação).

![demo](../assets/gifs/flutter_weather.gif)

## Setup

Vamos começar criando um novo projeto Flutter

```bash
flutter create flutter_weather
```

Podemos então avançar e substituir o conteúdo de pubspec.yaml por

```yaml
name: flutter_weather
description: A new Flutter project.

version: 1.0.0+1

environment:
  sdk: ">=2.6.0 <3.0.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^4.0.0
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

?> **Nota:** Vamos adicionar alguns assets (ícones para tipos de clima) em nosso aplicativo, portanto, precisamos incluir a pasta de ativos no pubspec.yaml. Por favor, vá em frente e crie uma pasta _assets_ na raiz do projeto.

e instale todas as nossas dependências

```bash
flutter packages get
```

## REST API

Para esta aplicação, estaremos atingindo o [metaweather API](https://www.metaweather.com).

Vamos nos concentrar em dois pontos de extremidade:

- `/api/location/search/?query=$city` para obter um locationId para um determinado nome de cidade
- `/api/location/$locationId` para obter o clima para um determinado locationId

Abra [https://www.metaweather.com/api/location/search/?query=london](https://www.metaweather.com/api/location/search/?query=london) no seu navegador e você verá a seguinte resposta

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

Podemos então obter o ID da localização na terra (woeid) e usá-lo para acessar a API do local.

Navegue para [https://www.metaweather.com/api/location/44418](https://www.metaweather.com/api/location/44418) no seu navegador e você verá a resposta para o clima em Londres. Deve ser algo como isto:

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

Ótimo, agora que sabemos como serão os nossos dados, vamos criar os modelos de dados necessários.

## Criando Nosso Modelo de dados Climáticos

Embora a API do clima retorne o clima por vários dias, por simplicidade, vamos nos preocupar apenas com o clima de hoje.

Vamos começar criando uma pasta para os nossos modelos `lib/models` e criando um arquivo chamado `weather.dart` que conterá nosso modelo de dados para a classe `Weather`. Em seguida, dentro do `lib/models`, crie um arquivo chamado `models.dart`, que é o nosso arquivo barrel de onde exportamos todos os modelos.

#### Imports

Primeiro, precisamos importar nossas dependências para a nossa classe. No topo do `weather.dart`, vá em frente e adicione:

```dart
import 'package:equatable/equatable.dart';
```

- `equatable`: Pacote que permite comparações entre objetos sem precisar substituir o operador `==`

#### Crie Enum WeatherCondition

Em seguida, criaremos um enumerador para todas as possíveis condições climáticas. Na próxima linha, vamos adicionar a enumeração.

_Estas condições provêm da definição do [metaweather API](https://www.metaweather.com/api/)_

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

#### Crie Modelo Weather

Em seguida, precisamos criar uma classe para ser nosso modelo de dados definido para o objeto climático retornado da API. Vamos extrair um subconjunto dos dados da API e criar um modelo `Weather`. Vá em frente e adicione-o ao arquivo `weather.dart` abaixo da enumeração `WeatherCondition`.

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

?> Nós estendemos [`Equatable`](https://pub.dev/packages/equatable) para que possamos comparar instâncias do `Weather`. Por padrão, o operador de igualdade retorna true se e somente se este e outro forem a mesma instância.

Não há muita coisa acontecendo aqui; estamos apenas definindo nosso modelo de dados `Weather` e implementando um método `fromJson` para que possamos criar uma instância `Weather` a partir do corpo de resposta da API e criando um método que mapeie a cadeia bruta para uma `WeatherCondition` em nossa enumeração.

#### Exporte no arquivo Barrel

Agora precisamos exportar essa classe em nosso arquivo barrel. Abra `lib/models/models.dart` e adicione a seguinte linha de código:

`export 'weather.dart';`

## Provedor de Dados

Em seguida, precisamos criar nosso `WeatherApiClient`, que será responsável por fazer solicitações http para a API do tempo.

> O `WeatherApiClient` é a camada mais baixa da nossa arquitetura de aplicativos (o provedor de dados). A única responsabilidade é buscar dados diretamente da nossa API.

Como mencionamos anteriormente, buscaremos dois pontos endpoints, portanto nosso `WeatherApiClient` precisa expor dois métodos públicos:

- `getLocationId(String city)`
- `fetchWeather(int locationId)`

#### Criando nosso API Client do Clima

Essa camada do nosso aplicativo é chamada de camada de repositório, então vamos em frente e crie uma pasta para nossos repositórios. Dentro de `lib/`, crie uma pasta chamada `repositóries` e, em seguida, crie um arquivo chamado `weather_api_client.dart`.

#### Adicionando a Barrel

Assim como fizemos com nossos modelos, vamos criar um arquivo barrel para nossos repositórios. Dentro do `lib/repositories` vá em frente e adicione um arquivo chamado `repositories.dart` e deixe em branco por enquanto.

- `models`: Por fim, importamos o modelo `Weather` que criamos anteriormente.

#### Crie nossa classe WeatherApiClient

Vamos criar uma classe. Vá em frente e adicione isto:

```dart
class WeatherApiClient {
  static const baseUrl = 'https://www.metaweather.com';
  final http.Client httpClient;

  WeatherApiClient({
    @required this.httpClient,
  }) : assert(httpClient != null);
}
```

Aqui, estamos criando uma constante para nossa URL base e instanciando nosso cliente http. Em seguida, estamos criando nosso Construtor e exigindo que injetemos uma instância do httpClient. Você verá algumas dependências ausentes. Vamos em frente adicioná-las ao topo do arquivo:

```dart
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
```

- `meta`: define anotações que podem ser usadas pelas ferramentas fornecidas com o Dart SDK.
- `http`: Uma biblioteca composível baseada em Future para fazer solicitações HTTP.

#### Adicionar método getLocationId

Agora vamos adicionar nosso primeiro método público, que obterá o locationId para uma determinada cidade. Abaixo do construtor, vá em frente e adicione:

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

Aqui, estamos apenas fazendo uma solicitação HTTP simples e decodificando a resposta como uma lista. Falando em decodificação, você verá que `jsonDecode` é uma função de uma dependência que precisamos importar. Então, vamos em frente e faça isso agora. No topo do arquivo pelas outras importações, vá em frente e adicione:

```dart
import 'dart:convert';
```

- `dart:convert`: Codificador/decodificador para converter entre diferentes representações de dados, incluindo JSON e UTF-8.

#### Adicionar método fetchWeather

Em seguida, vamos adicionar nosso outro método para acessar a API metaweather. Este irá obter o clima para uma cidade, devido à sua localização. Abaixo do método `getLocationId` que acabamos de implementar, vamos em frente e adicione isso:

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

Aqui, novamente, estamos apenas fazendo uma solicitação HTTP simples e decodificando a resposta em JSON. Você notará que novamente precisamos importar uma dependência, desta vez nosso modelo `Weather`. Na parte superior do arquivo, vá em frente e importe-o da seguinte maneira:

```dart
import 'package:flutter_weather/models/models.dart';
```

#### Exporte WeatherApiClient

Agora que criamos nossa classe com nossos dois métodos, vamos em frente e exportamos para o arquivo barrel. Dentro de `repositories.dart` vá em frente e adicione:

`export 'weather_api_client.dart';`

#### Qual o próximo

Concluímos nosso `DataProvider`, então é hora de passar para a próxima camada da arquitetura do nosso aplicativo: a **camada de repositório**.

## Repositório

> O `WeatherRepository` serve como uma abstração entre o código do cliente e o provedor de dados, para que, como desenvolvedor trabalhando em recursos, você não precise saber de onde vêm os dados. Nosso `WeatherRepository` dependerá do `WeatherApiClient` que acabamos de criar e exporá um único método público chamado, você adivinhou, `getWeather(String city)`. Ninguém precisa saber que, sob o capô, precisamos fazer duas chamadas de API (uma para locationId e outra para clima) porque ninguém realmente se importa. Só nos preocupamos em obter o `Clima 'para uma determinada cidade.

#### Criando nosso  Repositório Weather

Este arquivo pode estar em nossa pasta de repositório. Então vá em frente e crie um arquivo chamado `weather_repository.dart` e abra-o.

Nosso `WeatherRepository` é bastante simples e deve ser algo como isto:

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

#### Exporte WeatherRepository no Barrel

Vá em frente e abra `repositories.dart` e exporte da seguinte maneira:

`export 'weather_repository.dart';`

Impressionante! Agora estamos prontos para avançar para a camada de lógica de negócios e começar a construir nosso `WeatherBloc`.

## Lógica de Negócio (Bloc)

> Nosso `WeatherBloc` é responsável por receber o `WeatherEvents` e convertê-los em `WeatherStates`. Depende do `WeatherRepository` para que possa recuperar o `Weather` quando um usuário inserir uma cidade de sua escolha.

#### Criando nosso primeiro Bloc

Vamos criar alguns blocs durante este tutorial, então vamos criar uma pasta dentro do `lib` chamada` blocs`. Novamente, como teremos vários blocs, vamos primeiro criar um arquivo barrel chamado `blocs.dart` dentro da pasta` blocs`.

Antes de pular para o bloc, precisamos definir quais eventos o nosso `WeatherBloc` manipulará e como vamos representar o nosso `WeatherState`. Para manter nossos arquivos pequenos, separaremos `event`, `state` e `bloc` em três arquivos.

#### Weather Event

Vamos criar um arquivo chamado `weather_event.dart` dentro da pasta `blocs`. Para simplificar, vamos começar com um único evento chamado `FetchWeather`.

Podemos defini-lo como:

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

Sempre que um usuário digitar uma cidade, adicionaremos um evento `FetchWeather` à cidade especificada e nosso bloc será responsável por descobrir o que o tempo está aí e retornar um novo `WeatherState`.

Então vamos exportar a classe em nosso arquivo barrel. Dentro do `blocs.dart`, adicione:

`export 'weather_event.dart';`

#### Weather State

Em seguida, vamos criar nosso arquivo `state`. Dentro da pasta `blocs`, vá em frente e crie um arquivo chamado `weather_state.dart` onde nosso `weatherState` viverá.

Para a aplicação atual, teremos 4 estados possíveis:

- `WeatherEmpty` - nosso estado inicial que não terá dados climáticos porque o usuário ainda não selecionou uma cidade
- `WeatherLoading` - um estado que ocorrerá enquanto buscamos o clima para uma determinada cidade
- `WeatherLoaded` - um estado que ocorrerá se conseguirmos obter o tempo com êxito em uma determinada cidade.
- `WeatherError` - um estado que ocorrerá se não conseguirmos obter tempo para uma determinada cidade.

Podemos representar esses estados da seguinte maneira:

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

Então vamos exportar essa classe em nosso arquivo barrel. Dentro do `blocs.dart` vá em frente e adicione:

`export 'weather_state.dart';`

Agora que temos nossos `Eventos` e nossos `Estados` definidos e implementados, estamos prontos para fazer nosso `WeatherBloc`.

#### Weather Bloc

> Nosso `WeatherBloc` é muito direto. Para recapitular, ele converte `WeatherEvents` em `WeatherStates` e depende do `WeatherRepository`.

?> **Dica:** Confira a extensão [Bloc VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc#overview) para aproveitar os snippets de bloc e melhorar ainda mais sua eficiência e velocidade de desenvolvimento.

Vá em frente e crie um arquivo dentro da pasta `blocs` chamada `weather_bloc.dart` e adicione o seguinte:

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

Definimos nosso `initialState` como `WeatherEmpty`, pois inicialmente o usuário não selecionou uma cidade. Então, tudo o que resta é implementar o `mapEventToState`.

Como estamos lidando apenas com o evento `FetchWeather`, tudo o que precisamos fazer é `renderizar` nosso estado `WeatherLoading` quando obtivermos um evento `FetchWeather` e, em seguida, tentar obter o clima no `WeatherRepository`.

Se conseguirmos recuperar o clima com sucesso, "produziremos" um estado "WeatherLoaded" e se não for possível recuperar o clima, "produziremos" um estado "WeatherError".

Agora exporte esta classe em `blocs.dart`:

`export 'weather_bloc.dart';`

Isso é tudo! Agora estamos prontos para avançar para a camada final: a camada de apresentação.

## Apresentação

### Setup

Como você provavelmente já viu em outros tutoriais, criaremos um `SimpleBlocDelegate` para que possamos ver todas as transições de estado em nosso aplicativo. Vamos em frente e crie `simple_bloc_delegate.dart` e crie nosso próprio delegado personalizado.

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

Podemos então importá-lo para o arquivo `main.dart` e definir nosso delegate da seguinte forma:

```dart
import 'package:flutter_weather/simple_bloc_delegate.dart';

void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();
  runApp(App());
}
```

Por fim, precisamos criar nosso `WeatherRepository` e injetá-lo no nosso widget `App` (que criaremos na próxima etapa).

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

### App Widget

Nosso widget `App` começará como um `StatelessWidget`, que tem o `WeatherRepository` injetado e cria o `MaterialApp` com o nosso widget `Weather` (que criaremos na próxima etapa). Estamos usando o widget `BlocProvider` para criar uma instância do nosso` WeatherBloc` e disponibilizá-lo para o widget `Weather` e seus filhos. Além disso, o `BlocProvider` gerencia a construção e o fechamento do `WeatherBloc`.

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

### Weather

Agora precisamos criar nosso widget `Weather`. Vá em frente e crie uma pasta chamada `widgets` dentro de `lib` e crie um arquivo barrel dentro chamado `widgets.dart`. Em seguida, crie um arquivo chamado `weather.dart`.

> Nosso widget do tempo será um `StatelessWidget` responsável por renderizar os vários dados meteorológicos do tempo.

#### Criando nosso Stateless Widget

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

Tudo o que está acontecendo neste widget é que estamos usando o `BlocBuilder` com o nosso `WeatherBloc` para reconstruir nossa interface do usuário com base nas alterações de estado no nosso `WeatherBloc`.

Vá em frente e exporte `Weather` no arquivo `widgets.dart`.

Você notará que estamos referenciando um widget `CitySelection`,` Location`, `LastUpdated` e `CombinedWeatherTemperature`, que criaremos nas seções a seguir.

### Location Widget

Vá em frente e crie um arquivo chamado `location.dart` dentro da pasta` widgets`.

> Nosso widget `Location` é simples; exibe a localização atual.

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

Certifique-se de exportar isso no arquivo `widgets.dart`.

### Ultima atualização

Em seguida, crie um arquivo `last_updated.dart` dentro da pasta `widgets`.

> Nosso widget `LastUpdated` também é super simples; exibe a última hora atualizada para que os usuários saibam o quão atualizados são os dados meteorológicos.

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

Certifique-se de exportar isso no arquivo `widgets.dart`.

?> **Nota:** Estamos utilizando [`TimeOfDay`](https://api.flutter.dev/flutter/material/TimeOfDay-class.html) para formatar o `DateTime` em um formato mais legível por humanos.

### Combined Weather Temperature

Em seguida, crie um arquivo `combinado_tempo_temperatura.dart` dentro da pasta `widgets`.

> O widget `CombinedWeatherTemperature` é um widget de composição que exibe o clima atual junto com a temperatura. Ainda vamos modularizar os widgets `Temperature` e `WeatherConditions` para que todos possam ser reutilizados.

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

Certifique-se de exportar isso no arquivo `widgets.dart`.

?> **Nota:** Estamos usando dois widgets não implementados: `WeatherConditions` e `Temperature`, que criaremos a seguir.

### Weather Conditions

Em seguida, crie um arquivo `weather_conditions.dart` dentro da pasta `widgets`.

> Nosso widget `WeatherConditions` será responsável por exibir as condições climáticas atuais (céu limpo, aguaceiros, trovoadas, etc.) juntamente com um ícone correspondente.

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

Aqui você pode ver que estamos usando alguns assets. Faça o download deles em [aqui](https://github.com/felangel/bloc/tree/master/examples/flutter_weather/assets) e adicione-os ao diretório `assets/` que criamos no início do projeto.

Certifique-se de exportar isso no arquivo `widgets.dart`.

?> **Dica:** Veja [icons8](https://icons8.com/icon/set/weather/office) para os ativos usados ​​neste tutorial.

### Temperatura

Em seguida, crie um arquivo `temperature.dart` dentro da pasta` widgets`.

> Nosso widget `Temperature` será responsável por exibir as temperaturas média, mínima e máxima.

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

Certifique-se de exportar isso no arquivo `widgets.dart`.

### Seleção de Cidade

A última coisa que precisamos implementar para ter um aplicativo funcional é o widget `CitySelection`, que permite aos usuários digitar o nome de uma cidade. Vá em frente e crie um arquivo `city_selection.dart` dentro da pasta `widgets`.

> O widget `CitySelection` permitirá que os usuários insiram um nome de cidade e passem a cidade selecionada de volta para o widget `App`.

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

Ele precisa ser um `StatefulWidget` porque precisa manter um `TextController`.

?> **Nota:** Quando pressionamos o botão de busca, usamos o `Navigator.pop` e passamos o texto atual do nosso `TextController` de volta à visualização anterior.

Certifique-se de exportar isso no arquivo `widgets.dart`.

## Rode o App

Agora que criamos todos os nossos widgets, vamos voltar ao arquivo `main.dart`. Você verá que precisamos importar o widget `Weather`, então vá em frente e adicione esta linha no topo.

`import 'package:flutter_weather/widgets/widgets.dart';`

Em seguida, você pode executar o aplicativo com `flutter run` no terminal. Vá em frente e selecione uma cidade e você perceberá que ela tem alguns problemas:

- O fundo é branco e o texto também fica dificultando a leitura
- Não temos como atualizar os dados climáticos depois que eles são buscados
- A interface do usuário é muito simples
- Tudo está em graus Celsius e não temos como mudar as unidades

Vamos resolver esses problemas e levar nosso aplicativo Weather para o próximo nível!

## Pull-To-Refresh

> Para oferecer suporte ao pull-to-refresh, precisamos atualizar nosso `WeatherEvent` para lidar com um segundo evento:` RefreshWeather`. Vá em frente e adicione o seguinte código ao `blocs / weather_event.dart`

```dart
class RefreshWeather extends WeatherEvent {
  final String city;

  const RefreshWeather({@required this.city}) : assert(city != null);

  @override
  List<Object> get props => [city];
}
```

Em seguida, precisamos atualizar nosso `mapEventToState` dentro de `weather_bloc.dart` para manipular um evento `RefreshWeather`. Vá em frente e adicione esta declaração `if` abaixo da existente.

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

Aqui, estamos apenas criando um novo evento que solicitará ao weatherRepository que faça uma chamada de API para obter o clima da cidade.

Podemos refatorar o `mapEventToState` para usar algumas funções auxiliares particulares, a fim de manter o código organizado e fácil de seguir:

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

Por fim, precisamos atualizar nossa camada de apresentação para usar um widget `RefreshIndicator`. Vamos em frente e modifique nosso widget `Weather` em` widgets / weather.dart`. Existem algumas coisas que precisamos fazer.

- Importe `async` para o arquivo `weather.dart` para lidar com `Future`

`import dart: async;`

- Adicione um Completer

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

Como nosso widget `Weather` precisará manter uma instância de um `Completer`, precisamos refatorá-lo para ser um `StatefulWidget`. Então, podemos inicializar o `Completer` em` initState`.

- Dentro do método `build` dos widgets, vamos agrupar o `ListView` em um widget `RefreshIndicator` dessa maneira. Em seguida, retorne o `_refreshCompleter.future;` quando o retorno de chamada `onRefresh` acontecer.

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

Para usar o `RefreshIndicator`, tivemos que criar um [`Completer`](https://api.dart.dev/stable/dart-async/Completer-class.html) o que nos permite produzir um "Future" que possamos concluir posteriormente.

A última coisa que precisamos fazer é concluir o `Completer` quando recebermos um estado` WeatherLoaded` para descartar o indicador de carregamento assim que o clima for atualizado.

```dart
class _WeatherState extends State<Weather> {
  ...
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ...
      body: Center(
        child: BlocConsumer<WeatherBloc, WeatherState>(
          listener: (context, state) {
            if (state is WeatherLoaded) {
              _refreshCompleter?.complete();
              _refreshCompleter = Completer();
            }
          },
          builder: (context, state) {
            ...
          }
        ),
      )
    )
  }
}
```

Convertemos nosso `BlocBuilder` em um `BlocConsumer` porque precisamos lidar com a reconstrução da interface do usuário com base em alterações de estado e também com efeitos colaterais (completando o `Completer`).

?> **Nota:** `BlocConsumer` é o mesmo que ter um` BlocBuilder` aninhado dentro de um `BlocListener`.

É isso aí! Agora resolvemos o problema nº 1 e os usuários podem atualizar o clima puxando para baixo. Sinta-se à vontade para executar o `flutter run` novamente e tente atualizar o clima.

Em seguida, vamos abordar a interface simples, criando um `ThemeBloc`.

## Temas Dinâmicos

> Nosso `ThemeBloc` será responsável por converter o `ThemeEvents` em `ThemeStates`.

Nossos `ThemeEvents` consistirão em um único evento chamado `WeatherChanged` que será adicionado sempre que as condições climáticas que estamos exibindo mudarem.

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

Nosso `ThemeState` consistirá em um` ThemeData` e um `MaterialColor` que usaremos para aprimorar nossa interface do usuário.

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

Agora, podemos implementar nosso `ThemeBloc`, que deve se parecer com:

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

Embora seja muito código, a única coisa aqui é a lógica para converter uma `WeatherCondition` em um novo `ThemeState`.

Agora podemos atualizar nosso `main` e um `ThemeBloc` fornecendo-o ao nosso `App`.

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

Nosso widget `App` pode então usar o BlocBuilder para reagir às alterações no `ThemeState`.

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

?> **Nota:** Estamos usando o `BlocProvider` para tornar nosso `ThemeBloc` disponível globalmente usando o `BlocProvider.of<ThemeBloc>(context)`.

A última coisa que precisamos fazer é criar um widget legal `GradientContainer` que colorirá nosso plano de fundo em relação às condições climáticas atuais.

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

Agora podemos usar nosso `GradientContainer` no nosso widget `Weather` da seguinte forma:

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
        child: BlocConsumer<WeatherBloc, WeatherState>(
          listener: (context, state) {
            if (state is WeatherLoaded) {
              BlocProvider.of<ThemeBloc>(context).add(
                WeatherChanged(condition: state.weather.condition),
              );
              _refreshCompleter?.complete();
              _refreshCompleter = Completer();
            }
           },
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
    );
  }
}
```

Como queremos "fazer alguma coisa" em resposta a alterações de estado em nosso `WeatherBloc`, estamos usando o `BlocListener`. Neste caso, estamos concluindo e redefinindo o `Completer` e também adicionando o evento `WeatherChanged` ao `ThemeBloc`.

?> **Dica:** Veja [SnackBar Recipe](recipesfluttershowsnackbar.md) para obter mais informações sobre o widget `BlocListener`.

Estamos acessando nosso `ThemeBloc` via `BlocProvider.of<ThemeBloc>(context)` e, em seguida, adicionamos um evento `WeatherChanged` em cada `WeatherLoad`.

Também empacotamos nosso widget `GradientContainer` com um `BlocBuilder` de `ThemeBloc` para que possamos reconstruir o `GradientContainer` e seus filhos em resposta às alterações do `ThemeState`.

Impressionante! Agora, temos um aplicativo que parece muito melhor (na minha opinião :P) e resolvemos o problema nº 2.

Tudo o que resta é lidar com a conversão de unidades entre Celsius e Fahrenheit. Para isso, criaremos um widget `Settings` e um `SettingsBloc`.

## Conversão de Unidades

Começaremos criando nosso `SettingsBloc`, que converterá `SettingsEvents` em `SettingsStates`.

Nosso `SettingsEvents` consistirá em um único evento: `TemperatureUnitsToggled`.

```dart
abstract class SettingsEvent extends Equatable {}

class TemperatureUnitsToggled extends SettingsEvent {
  @override
  List<Object> get props => [];
}
```

Nosso `SettingsState` consistirá simplesmente no atual `TemperatureUnits`.

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

Por fim, precisamos criar nosso `SettingsBloc`:

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

Tudo o que estamos fazendo é usar `fahrenheit` se `TemperatureUnitsToggled` for adicionado e as unidades atuais forem `celsius` e vice-versa.

Agora precisamos fornecer nosso `SettingsBloc` ao nosso widget `App` no `main.dart`.

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

Novamente, estamos tornando o `SettingsBloc` acessível globalmente usando o `BlocProvider` e também o fechando no retorno de chamada `close`. Desta vez, no entanto, como estamos expondo mais de um bloc usando o `BlocProvider` no mesmo nível, podemos eliminar alguns aninhamentos usando o widget `MultiBlocProvider`.

Agora precisamos criar nosso widget `Configurações` a partir do qual os usuários podem alternar as unidades.

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

Estamos usando o `BlocProvider` para acessar o `SettingsBloc` através do `BuildContext` e, em seguida, o` BlocBuilder` para reconstruir nossa interface do usuário com base no `SettingsState` alterado.

Nossa interface do usuário consiste em um `ListView` com um único `ListTile` que contém um `Switch` que os usuários podem alternar para selecionar graus Celsius x Fahrenheit.

?> **Nota:** No método `onChanged` do switch, adicionamos um evento `TemperatureUnitsToggled` para notificar o `SettingsBloc` de que as unidades de temperatura foram alteradas.

Em seguida, precisamos permitir que os usuários acessem o widget `Settings` no nosso widget `Clima`.

Podemos fazer isso adicionando um novo `IconButton` no nosso `AppBar`.

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
        child: BlocConsumer<WeatherBloc, WeatherState>(
          listener: (context, state) {
            if (state is WeatherLoaded) {
              BlocProvider.of<ThemeBloc>(context).add(
                WeatherChanged(condition: state.weather.condition),
              );
              _refreshCompleter?.complete();
              _refreshCompleter = Completer();
            }
          },
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
    );
  }
}
```

Estamos quase terminando! Nós apenas precisamos atualizar nosso widget `Temperature` para responder às unidades atuais.

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

E, finalmente, precisamos injetar o `TemperatureUnits` no widget `Temperature`.

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

Isso é tudo! Agora, implementamos com sucesso um aplicativo meteorológico no flutter usando os pacotes [bloc](https://pub.dev/packages/bloc) e [flutter_bloc](https://pub.dev/packages/flutter_bloc) e nós separamos com êxito nossa camada de apresentação de nossa lógica de negócios.

O código fonte completo deste exemplo pode ser encontrado [aqui](https://github.com/felangel/Bloc/tree/master/examples/flutter_weather).

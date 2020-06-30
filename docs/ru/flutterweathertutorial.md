# Flutter погода

![advanced](https://img.shields.io/badge/level-advanced-red.svg)

> В следующем руководстве мы собираемся создать приложение `Weather` во Flutter, которое демонстрирует как управлять несколькими блоками для реализации динамического создания тем, обновления данных и многого другого. Наше приложение погоды будет извлекать реальные данные из API и демонстрировать, как разделить наше приложение на три уровня (данные, бизнес-логика и представление).

![demo](../assets/gifs/flutter_weather.gif)

## Настройка

Мы начнем с создания нового проекта Flutter

[script](../_snippets/flutter_weather_tutorial/flutter_create.sh.md ':include')

Сначала нам нужно заменить содержимое файла `pubspec.yaml` на:

[pubspec.yaml](../_snippets/flutter_weather_tutorial/pubspec.yaml.md ':include')

?> **Примечание:** Мы собираемся добавить некоторые ресурсы (значки для типов погоды) в наше приложение, поэтому нам нужно подключить папку ресурсов в `pubspec.yaml`. Пожалуйста, создайте папку _assets_ в корне проекта.

а затем установить все наши зависимости

[script](../_snippets/flutter_weather_tutorial/flutter_packages_get.sh.md ':include')

## REST API

Для этого приложения мы будем использовать [metaweather API](https://www.metaweather.com).

Мы сосредоточимся на двух конечных ресурсах:

- `/api/location/search/?query=$city` чтобы получить locationId для данного названия города
- `/api/location/$locationId` чтобы узнать погоду для данного местоположения

Открыв [https://www.metaweather.com/api/location/search/?query=london](https://www.metaweather.com/api/location/search/?query=london) в своем браузере, мы увидим следующий ответ:

[london_search.json](../_snippets/flutter_weather_tutorial/location_search.json.md ':include')

Затем мы можем получить идентификатор `where-on-earth-id` (woeid) и использовать его для получения местоположения.

Перейдите на [https://www.metaweather.com/api/location/44418](https://www.metaweather.com/api/location/44418) в своем браузере и вы увидите ответ на погоду в Лондоне. Это должно выглядеть примерно так:

[london.json](../_snippets/flutter_weather_tutorial/location.json.md ':include')

Отлично, теперь, когда мы знаем как будут выглядеть наши данные, давайте создадим необходимые модели данных.

## Создание модели данных

Хотя API возвращает погоду на несколько дней, для простоты мы будем использовать только сегодняшний день.

Давайте начнем с создания папки для наших моделей `lib/models` и создадим там файл с именем `weather.dart`, который будет содержать нашу модель данных для нашего класса `Weather`. Затем внутри `lib/models` создадим файл с именем `models.dart`, который является индексным файлом, из которого мы экспортируем все модели.

### Импорты

Прежде всего нам нужно импортировать наши зависимости для нашего класса. В верхней части `weather.dart` добавьте:

[weather.dart](../_snippets/flutter_weather_tutorial/equatable_import.dart.md ':include')

- `equatable`: пакет, который позволяет сравнивать объекты без необходимости переопределять оператор `==`

#### Создание WeatherCondition перечисления

Далее нам нужно создать счетчик для всех возможных погодных условий. В следующей строке давайте добавим `enum`.

Эти условия берутся из определения [metaweather API](https://www.metaweather.com/api/)

[weather.dart](../_snippets/flutter_weather_tutorial/weather_condition.dart.md ':include')

#### Создание модели погоды

Далее нам нужно создать класс, который будет нашей моделью данных для объекта погоды, возвращаемого из API. Мы собираемся извлечь подмножество данных из API и создать модель `Weather`. Добавьте следующий код в файл `weather.dart` под перечислением `WeatherCondition`.

[weather.dart](../_snippets/flutter_weather_tutorial/weather.dart.md ':include')

?> Мы расширяем [`Equatable`](https://pub.dev/packages/equatable), чтобы мы могли сравнивать экземпляры `Weather`. По умолчанию оператор равенства возвращает true если только этот и другие экземпляры являются одинаковыми.

Здесь мало что происходит; мы просто определяем нашу модель данных `Weather` и реализуем метод `fromJson`, чтобы мы могли создать экземпляр `Weather` из тела ответа API и создаем метод, который мапит необработанную строку в `WeatherCondition` в перечислении.

#### Экспорты в индексе

Теперь нам нужно экспортировать этот класс в индексный файл. Откройте `lib/models/models.dart` и добавьте следующую строку кода:

[models.dart](../_snippets/flutter_weather_tutorial/weather_export.dart.md ':include')

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

[weather_api_client.dart](../_snippets/flutter_weather_tutorial/weather_api_client_constructor.dart.md ':include')

Здесь мы создаем константу для нашего базового URL и http-клиент. Затем мы создаем конструктор и обязательный параметр для внедрения экземпляра `httpClient`. Вы увидите некоторые отсутствующие зависимости. Давайте продолжим и добавим их в начало файла:

[weather_api_client.dart](../_snippets/flutter_weather_tutorial/weather_api_client_imports.dart.md ':include')

- `meta`: Defines annotations that can be used by the tools that are shipped with the Dart SDK.
- `http`: A composable, Future-based library for making HTTP requests.

- `meta`: определяет аннотации, которые могут использоваться инструментами, поставляемыми с Dart SDK.
- `http`: композитная, `Future based` библиотека для выполнения HTTP-запросов.

#### Добавление метода getLocationId

Теперь давайте добавим наш первый публичный метод, который получит `locationId` для данного города. Ниже конструктора добавьте:

[weather_api_client.dart](../_snippets/flutter_weather_tutorial/get_location_id.dart.md ':include')

Здесь мы делаем простой HTTP-запрос и затем декодируем ответ в виде списка. Говоря о декодировании, вы увидите, что `jsonDecode` это функция из зависимости, которую мы должны импортировать. Итак, давайте продолжим и сделаем это сейчас. В верхней части файла по другим импортам добавьте:

[weather_api_client.dart](../_snippets/flutter_weather_tutorial/dart_convert_import.dart.md ':include')

- `dart:convert`: кодер/декодер для преобразования между различными представлениями данных, включая JSON и UTF-8.

#### Добавление метода fetchWeather

Далее давайте добавим другой метод по выполнению запросов из `API metaweather`. Он будет получать погоду для города, учитывая его местоположение. Ниже уже реализованного метода `getLocationId` давайте продолжим и добавим:

[weather_api_client.dart](../_snippets/flutter_weather_tutorial/fetch_weather.dart.md ':include')

Здесь мы снова делаем простой HTTP-запрос и декодируем ответ в JSON. Вы заметите, что нам снова нужно импортировать зависимость, но на этот раз модель `Weather`. В верхней части файла импортируем его так:

[weather_api_client.dart](../_snippets/flutter_weather_tutorial/models_import.dart.md ':include')

#### Экспорт WeatherApiClient

Теперь, когда у нас есть класс с двумя методами, давайте продолжим и экспортируем его в файл индекса. Внутри `repositories.dart` добавьте:

[repositories.dart](../_snippets/flutter_weather_tutorial/weather_api_client_export.dart.md ':include')

#### Что далее

Мы сделали `DataProvider`, поэтому пришло время перейти на следующий уровень архитектуры нашего приложения: **уровень хранилища**.

## Хранилище

> `WeatherRepository` служит абстракцией между клиентским кодом и поставщиком данных, поэтому разработчик, работающий над функционалом, не должен знать откуда поступают данные. Наш `WeatherRepository` будет зависеть от `WeatherApiClient`, который мы только что создали и предоставит единственный открытый метод, который, как вы уже догадались, называется `getWeather(String city)`. Никто не должен знать что нам нужно сделать два вызова API (один для locationId и один для погоды), потому что на самом деле это никого не волнует. Все, о чем мы заботимся, это получение `Weather` для данного города.

### Создание хранилища

Этот файл может жить в папке хранилища. Итак, создайте файл с именем `weather_repository.dart` и откройте его.

Наш `WeatherRepository` довольно прост и должен выглядеть примерно так:

[weather_repository.dart](../_snippets/flutter_weather_tutorial/weather_repository.dart.md ':include')

#### Экспорт хранилища в индекс

Сначала откройте `repositories.dart` и сделайте экспорт так:

[repositories.dart](../_snippets/flutter_weather_tutorial/weather_repository_export.dart.md ':include')

Потрясающие! Теперь мы готовы перейти на уровень бизнес-логики и приступить к созданию `WeatherBloc`.

## Бизнес логика (Bloc)

> Наш `WeatherBloc` отвечает за получение `WeatherEvents` и преобразование их в `WeatherStates`. Он будет зависеть от `WeatherRepository` чтобы получить `Weather` когда пользователь вводит город по своему выбору.

### Создание первого блока

В этом руководстве мы создадим несколько блоков, поэтому давайте создадим внутри `lib` папку с именем `blocs`. Опять же, поскольку у нас будет несколько блоков, давайте сначала создадим индексный файл с именем `blocs.dart` внутри нашей папки `blocs`.

Прежде чем перейти к блоку, нам нужно определить, какие события будет обрабатывать наш `WeatherBloc`, а также, как мы будем представлять `WeatherState`. Чтобы наши файлы были небольшими мы разделим `event`, `state` и `bloc` на три файла.

#### Weather события

Давайте создадим файл с именем `weather_event.dart` внутри папки `blocs`. Для простоты мы собираемся начать с одного события под названием `WeatherRequested`.

Мы можем определить его так:

[weather_event.dart](../_snippets/flutter_weather_tutorial/fetch_weather_event.dart.md ':include')

Всякий раз, когда пользователь вводит город, мы `добавляем` событие `WeatherRequested` с указанным городом и наш блок будет отвечать за выяснение погоды и возвращать новый `WeatherState`.

Теперь давайте экспортируем класс в наш индексный файл. Внутри `blocs.dart` добавьте:

[blocs.dart](../_snippets/flutter_weather_tutorial/weather_event_export.dart.md ':include')

#### Weather состояния

Далее давайте создадим наш файл `state`. Внутри папки `blocs` создайте файл с именем `weather_state.dart` где будет жить наш `WeatherState`.

Для текущего приложения у нас будет 4 возможных состояния:

- `WeatherInitial` - начальное состояние, в котором не будет данных о погоде, потому что пользователь еще не выбрал город
- `WeatherLoadInProgress` - состояние, которое будет происходить пока мы выбираем погоду для данного города
- `WeatherLoadSuccess` - состояние, которое возникнет если мы сможем успешно выбрать погоду для данного города.
- `WeatherLoadFailure` - состояние, которое возникнет если мы не сможем выбрать погоду для данного города.

Мы можем представить эти состояния так:

[weather_state.dart](../_snippets/flutter_weather_tutorial/weather_state.dart.md ':include')

Теперь давайте экспортируем этот класс в наш индексный файл. Внутри `blocs.dart` добавьте:

[blocs.dart](../_snippets/flutter_weather_tutorial/weather_state_export.dart.md ':include')

Теперь когда у нас определены и реализованы наши `Events` и `States` мы готовы создать наш `WeatherBloc`.

#### Блок погоды

> `WeatherBloc` очень прост. Напомним, что он преобразует `WeatherEvents` в `WeatherStates` и зависит от `WeatherRepository`.

?> **Совет:** Изучите [Расширение Bloc VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc#overview), чтобы воспользоваться фрагментами кода и улучшить вашу эффективность и скорость разработки.

Теперь создайте файл внутри папки `blocs` с именем `weather_bloc.dart` и добавьте следующее:

[weather_bloc.dart](../_snippets/flutter_weather_tutorial/weather_bloc.dart.md ':include')

Мы установили для `initialState` значение `WeatherInitial` поскольку изначально пользователь не выбрал город. Теперь все, что осталось, это реализовать `mapEventToState`.

Поскольку мы обрабатываем только событие `WeatherRequested`, все что нам нужно сделать, это выдать (`yield`) наше состояние `WeatherLoadInProgress` когда мы получим событие `WeatherRequested`, а затем попытаться получить погоду из `WeatherRepository`.

Если мы можем успешно получить погоду, то мы выдаем состояние `WeatherLoadSuccess`, а если мы не можем получить погоду, мы выдаем состояние `WeatherLoadFailure`.

Теперь экспортируйте этот класс в `blocs.dart`:

[blocs.dart](../_snippets/flutter_weather_tutorial/weather_bloc_export.dart.md ':include')

Это все что нужно сделать! Теперь мы готовы перейти к последнему слою: уровню представления.

## Представление

### Настройка

Как вы, вероятно, уже видели в других руководствах, мы собираемся создать `SimpleBlocDelegate`, чтобы мы могли видеть все переходы состояний в нашем приложении. Давайте продолжим, создадим `simple_bloc_delegate.dart` и собственный пользовательский делегат.

[simple_bloc_delegate.dart](../_snippets/flutter_weather_tutorial/simple_bloc_delegate.dart.md ':include')

Теперь мы можем импортировать его в файл `main.dart` и установить наш делегат так:

[main.dart](../_snippets/flutter_weather_tutorial/main1.dart.md ':include')

Наконец, нам нужно создать `WeatherRepository` и добавить его в виджет `App` (который мы создадим на следующем шаге).

[main.dart](../_snippets/flutter_weather_tutorial/main2.dart.md ':include')

### Виджет App

Наш виджет `App` будет `StatelessWidget` виджетом, в который внедряется `WeatherRepository` и который создает `MaterialApp` с виджетом `Weather` (который мы создадим на следующем шаге). Мы используем виджет `BlocProvider`, чтобы создать экземпляр `WeatherBloc` и сделать его доступным для виджета `Weather` и его дочерних элементов. Кроме того, `BlocProvider` управляет созданием и закрытием `WeatherBloc`.

[main.dart](../_snippets/flutter_weather_tutorial/app.dart.md ':include')

### Погода

Теперь нам нужно создать виджет погоды. Создайте папку с именем `widgets` внутри `lib` и создайте индексный файл внутри с именем `widgets.dart`. Затем создайте файл с именем `weather.dart`.

> Виджет `Weather` будет `StatelessWidget` виджетом, отвечающим за отображение различных данных о погоде.

#### Создание Stateless виджета

[weather.dart](../_snippets/flutter_weather_tutorial/weather_widget.dart.md ':include')

Все, что происходит в этом виджете, это то, что мы используем `BlocBuilder` с нашим `WeatherBloc`, чтобы перестроить наш пользовательский интерфейс на основе изменений состояния нашего `WeatherBloc`.

Экспортируем `Weather` в файл `widgets.dart`.

Вы заметите, что мы ссылаемся на виджет `CitySelection`, `Location`, `LastUpdated` и `CombinedWeatherTemperature`, который мы создадим в следующих разделах.

### Виджет местоположения

Создайте файл с именем `location.dart` внутри папки `widgets`.

> Виджет `Location` прост; он отображает текущее местоположение.

[location.dart](../_snippets/flutter_weather_tutorial/location.dart.md ':include')

Обязательно экспортируйте его в файле `widgets.dart`.

### Последние обновления

Затем создайте файл `last_updated.dart` внутри папки `widgets`.

> Виджет `LastUpdated` также очень прост; он отображает время последнего обновления, чтобы пользователи знали, насколько свежи данные о погоде.

[last_updated.dart](../_snippets/flutter_weather_tutorial/last_updated.dart.md ':include')

Обязательно экспортируйте его в файл `widgets.dart`.

?> **Примечание:** Мы используем [`TimeOfDay`](https://api.flutter.dev/flutter/material/TimeOfDay-class.html) для форматирования `DateTime` в более понятный для человека формат.

### Комбинированная температура

Теперь создайте файл `combined_weather_temperature.dart` внутри папки `widgets`.

> Виджет `CombinedWeatherTemperature` - это составной виджет, который отображает текущую погоду вместе с температурой. Мы по-прежнему собираемся создать виджеты `Temperature` и `WeatherConditions` в виде модулей, чтобы их можно было повторно использовать.

[combined_weather_temperature.dart](../_snippets/flutter_weather_tutorial/combined_weather_temperature.dart.md ':include')

Обязательно экспортируйте его в файл `widgets.dart`.

?> **Примечание:** Мы используем два еще не реализованных виджета: `WeatherConditions` и `Temperature`, которые мы создадим дальше.

### Погодные условия

Теперь создайте файл `weather_conditions.dart` внутри папки `widgets`.

> Виджет `WeatherConditions` будет отвечать за отображение текущих погодных условий (ясно, ливни, грозы и т.д.) вместе с соответствующим значком.

[weather_conditions.dart](../_snippets/flutter_weather_tutorial/weather_conditions.dart.md ':include')

Обязательно экспортируйте его в файл `widgets.dart`.

Здесь вы можете увидеть, что мы используем некоторые ресурсы. Пожалуйста, загрузите их [отсюда](https://github.com/felangel/bloc/tree/master/examples/flutter_weather/assets) и добавьте их в каталог `assets/`, который мы создали в начале проекта.

?> **Совет:** Проверьте [icons8](https://icons8.com/icon/set/weather/office) ресурсы, используемые в этом руководстве.

### Температура

Теперь создайте файл `temperature.dart` внутри папки `widgets`.

> Виджет `Temperature` будет отображать среднюю, минимальную и максимальную температуры.

[temperature.dart](../_snippets/flutter_weather_tutorial/temperature.dart.md ':include')

Обязательно экспортируйте его в файл `widgets.dart`.

### Выбор города

Последнее, что нам нужно реализовать для полнофункционального приложения - это виджет `CitySelection`, который позволяет пользователям вводить название города. Создайте файл `city_selection.dart` внутри папки `widgets`.

> Виджет `CitySelection` позволит пользователям вводить название города и передавать выбранный город обратно в виджет `App`.

[city_selection.dart](../_snippets/flutter_weather_tutorial/city_selection.dart.md ':include')

Обязательно экспортируйте его в файл `widgets.dart`.

Это должен быть `StatefulWidget`, потому что он должен поддерживать `TextController`.

?> **Примечание:** Когда мы нажимаем кнопку поиска, мы используем `Navigator.pop` и передаем текущий текст из нашего `TextController` обратно в предыдущее представление.

## Запуск приложения

Теперь, когда мы создали все наши виджеты, давайте вернемся к файлу `main.dart`. Вы увидите, что нам нужно импортировать наш виджет `Weather`, поэтому добавьте эту строку вверху.

[main.dart](../_snippets/flutter_weather_tutorial/widgets_import.dart.md ':include')

Теперь вы можете запустить приложение и выполнить `flutter run` в терминале. Сначала выберите город и вы заметите, что у него есть несколько проблем:

- Фон белый и текст очень тяжело читать
- У нас нет возможности обновить данные о погоде после получения
- Пользовательский интерфейс очень прост
- Все в градусах Цельсия и у нас нет возможности поменять единицы

Давайте рассмотрим эти проблемы и выведем наше приложение `Weather` на новый уровень!

## Протягивание до обновления

> Чтобы поддерживать функцию `протягивание до обновления` (`pull-to-refresh`), нам нужно обновить `WeatherEvent` для обработки второго события: `WeatherRefreshRequested`. Давайте добавим следующий код в `blocs/weather_event.dart`

[weather_event.dart](../_snippets/flutter_weather_tutorial/refresh_weather_event.dart.md ':include')

Теперь нам нужно обновить наш `mapEventToState` внутри `weather_bloc.dart` для обработки события `WeatherRefreshRequested`. Сначала добавьте еще одно выражение `if` ниже существующего.

[weather_bloc.dart](../_snippets/flutter_weather_tutorial/refresh_weather_bloc.dart.md ':include')

Здесь мы просто создаем новое событие, которое попросит наш `weatherRepository` сделать вызов API, чтобы узнать погоду для города.

Мы можем реорганизовать `mapEventToState` для использования некоторых частных вспомогательных функций, чтобы сохранить код организованным и легким для понимания:

[weather_bloc.dart](../_snippets/flutter_weather_tutorial/map_event_to_state_refactor.dart.md ':include')

Наконец, нам нужно обновить наш уровень представления, чтобы использовать виджет `RefreshIndicator`. Давайте продолжим и изменим наш виджет `Weather` в `widgets/weather.dart`. Есть несколько вещей, которые нам нужно сделать.

- Импортировать `async` в файл `weather.dart` для обработки `Future`

[weather.dart](../_snippets/flutter_weather_tutorial/dart_async_import.dart.md ':include')

- Добавить `Completer`

[weather.dart](../_snippets/flutter_weather_tutorial/add_completer.dart.md ':include')

Поскольку нашему виджету `Weather` нужно будет поддерживать экземпляр `Completer`, нам необходимо изменить его на `StatefulWidget`. Затем мы можем инициализировать `Completer` в `initState`.

- Внутри метода `build` виджета давайте обернем `ListView` в виджет `RefreshIndicator` как показано ниже. Затем вернем `_refreshCompleter.future` когда произойдет обратный вызов `onRefresh`.

[weather.dart](../_snippets/flutter_weather_tutorial/refresh_indicator.dart.md ':include')

Чтобы использовать `RefreshIndicator`, нам нужно было создать [`Completer`](https://api.dart.dev/stable/dart-async/Completer-class.html), который позволяет нам создавать `Future` и мы сделаем это позже.

Последнее, что нам нужно сделать, это завершить `Completer`, когда мы получим состояние `WeatherLoadSuccess`, чтобы отключить индикатор загрузки после обновления погоды.

[weather.dart](../_snippets/flutter_weather_tutorial/bloc_consumer_refactor.dart.md ':include')

Мы преобразовали наш `BlocBuilder` в `BlocConsumer`, потому что нам нужно обрабатывать как ребилдинг пользовательского интерфейса на основе изменений состояния, так и выполнение побочных эффектов (завершение `Completer`).

?> **Примечание:** `BlocConsumer` идентичен вложенному `BlocBuilder` внутри `BlocListener`.

Это оно! Теперь мы решили проблему N1 и пользователи могут обновить погоду, потянув вниз. Не стесняйтесь снова запустить `flutter run` и попробовать обновить погоду.

Далее давайте займемся простым интерфейсом, создав `ThemeBloc`.

## Динамические темы

> `ThemeBloc` будет отвечать за преобразование `ThemeEvents` в `ThemeStates`.

`ThemeEvents` будут состоять из одного события под названием `WeatherChanged`, которое будет добавляться при изменении погодных условий, которые мы отображаем.

[theme_event.dart](../_snippets/flutter_weather_tutorial/weather_changed_event.dart.md ':include')

`ThemeState` будет состоять из `ThemeData` и `MaterialColor`, которые мы будем использовать для улучшения нашего пользовательского интерфейса.

[theme_state.dart](../_snippets/flutter_weather_tutorial/theme_state.dart.md ':include')

Теперь мы можем реализовать `ThemeBloc`, который должен выглядеть следующим образом:

[theme_bloc.dart](../_snippets/flutter_weather_tutorial/theme_bloc.dart.md ':include')

Несмотря на то что кода много, единственная вещь здесь - это логика для преобразования условия `WeatherCondition` в новое состояние `ThemeState`.

Теперь мы можем обновить `main`, `ThemeBloc` и предоставить его нашему `App`.

[main.dart](../_snippets/flutter_weather_tutorial/main3.dart.md ':include')

Виджет `App` может теперь использовать `BlocBuilder`, чтобы реагировать на изменения в `ThemeState`.

[app.dart](../_snippets/flutter_weather_tutorial/app2.dart.md ':include')

?> **Примечание:** Мы используем `BlocProvider`, чтобы сделать `ThemeBloc` глобально доступным, используя `BlocProvider.of<ThemeBloc>(context)`.

Последнее, что нам нужно сделать, это создать классный виджет `GradientContainer`, который будет окрашивать наш фон в соответствии с текущими погодными условиями.

[gradient_container.dart](../_snippets/flutter_weather_tutorial/gradient_container.dart.md ':include')

Теперь мы можем использовать `GradientContainer` в виджете `Weather` следующим образом:

[weather.dart](../_snippets/flutter_weather_tutorial/integrate_gradient_container.dart.md ':include')

Поскольку мы хотим "что-то сделать" в ответ на изменения состояния в `WeatherBloc`, мы используем `BlocListener`. В этом случае мы завершаем и сбрасываем `Completer`, а также добавляем событие `WeatherChanged` в `ThemeBloc`.

?> **Совет:** Проверьте [SnackBar Recipe](ru/recipesfluttershowsnackbar.md) для получения дополнительной информации о виджете `BlocListener`.

Мы обращаемся к `ThemeBloc` через `BlocProvider.of<ThemeBloc>(context)` и добавляем событие `WeatherChanged` в каждый `WeatherLoad`.

Мы также обернули виджет `GradientContainer` с помощью `BlocBuilder` из `ThemeBloc`, чтобы мы могли перестроить `GradientContainer` и его дочерние элементы в ответ на изменения `ThemeState`.

Потрясающе! Теперь у нас есть приложение, которое выглядит намного лучше (на мой взгляд: P) и решает проблему N2.

Осталось только перевести единицы в градусы Цельсия и Фаренгейта. Для этого мы создадим виджет `Settings` и `SettingsBloc`.

## Преобразование единиц измерения

Мы начнем с создания нашего `SettingsBloc`, который преобразует `SettingsEvents` в `SettingsStates`.

`SettingsEvents` будут состоять из одного события: `TemperatureUnitsToggled`.

[settings_event.dart](../_snippets/flutter_weather_tutorial/settings_event.dart.md ':include')

`SettingsState` будет просто состоять из текущих `TemperatureUnits`.

[settings_state.dart](../_snippets/flutter_weather_tutorial/settings_state.dart.md ':include')

Наконец, нам нужно создать наш `SettingsBloc`:

[settings_bloc.dart](../_snippets/flutter_weather_tutorial/settings_bloc.dart.md ':include')

Все, что мы делаем, это используем `fahrenheit` если добавляется `TemperatureUnitsToggled` или наоборот - единицы измерения `celsius` в другом случае.

Теперь нам нужно предоставить `SettingsBloc` виджету `App` в `main.dart`.

[main.dart](../_snippets/flutter_weather_tutorial/main4.dart.md ':include')

Опять же, мы делаем `SettingsBloc` глобально доступным, используя `BlocProvider` и мы также закрываем его в обратном вызове `close`. Однако на этот раз, поскольку мы выставляем более одного блока с помощью `BlocProvider` на одном уровне, мы можем устранить некоторую вложенность с помощью виджета `MultiBlocProvider`.

Теперь нам нужно создать виджет `Settings`, в котором пользователи могут переключать единицы измерения.

[settings.dart](../_snippets/flutter_weather_tutorial/settings.dart.md ':include')

Мы используем `BlocProvider` для доступа к `SettingsBloc` через `BuildContext`, а затем с помощью `BlocBuilder` перестраиваем наш пользовательский интерфейс на основе измененного `SettingsState`.

Наш пользовательский интерфейс состоит из `ListView` с одним `ListTile`, который содержит `Switch`, предназначенный для переключения единиц измерения либо в Цельсиях либо в Фаренгейтах.

?> **Примечание:** В методе переключателя `onChanged` мы добавляем событие `TemperatureUnitsToggled`, чтобы уведомить `SettingsBloc` об изменении единиц температуры.

Далее нам нужно разрешить пользователям получать доступ к виджету `Settings` из виджета `Weather`.

Мы можем сделать это, добавив новый `IconButton` в `AppBar`.

[weather.dart](../_snippets/flutter_weather_tutorial/settings_button.dart.md ':include')

Мы почти закончили! Нам просто нужно обновить виджет `Temperature`, чтобы реагировать на текущие единицы измерения.

[temperature.dart](../_snippets/flutter_weather_tutorial/update_temperature.dart.md ':include')

И наконец, нам нужно добавить `TemperatureUnits` в виджет `Temperature`.

[consolidated_weather_temperature.dart](../_snippets/flutter_weather_tutorial/inject_temperature_units.dart.md ':include')

Вот и все, что нужно сделать! Теперь мы успешно внедрили приложение погоды во Flutter, используя пакеты [bloc](https://pub.dev/packages/bloc) и [flutter_bloc](https://pub.dev/packages/flutter_bloc) и мы успешно отделили наш уровень представления от нашей бизнес логики.

Полный исходный код этого примера можно найти [здесь](https://github.com/felangel/Bloc/tree/master/examples/flutter_weather).

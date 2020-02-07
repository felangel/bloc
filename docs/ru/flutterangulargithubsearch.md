# Flutter + AngularDart Github поиск

![advanced](https://img.shields.io/badge/level-advanced-red.svg)

> В следующем руководстве мы создадим приложение Github Search во Flutter и AngularDart, чтобы продемонстрировать, как мы можем совместно использовать слои данных и бизнес-логики между двумя проектами.

![demo](../assets/gifs/flutter_github_search.gif)

![demo](../assets/gifs/angular_github_search.gif)

## Библиотека Common Github Search

> Библиотека Common Github Search будет содержать модели, поставщика данных, хранилище, а также блок, который будет использоваться совместно AngularDart и Flutter.

### Настройка

Мы начнем с создания нового каталога для нашего приложения.

```bash
mkdir github_search && cd github_search
```

Далее мы создадим каркас для библиотеки `common_github_search`.

```bash
mkdir common_github_search
```

Нам нужно создать `pubspec.yaml` с необходимыми зависимостями.

```yaml
name: common_github_search
description: Shared Code between AngularDart and Flutter
version: 1.0.0+1

environment:
  sdk: ">=2.6.0 <3.0.0"

dependencies:
  meta: ^1.1.6
  bloc: ^3.0.0
  equatable: ^1.0.0
  http: ^0.12.0
```

Наконец, нам нужно установить все зависимости.

```bash
pub get
```

Вот и все по настройке проекта! Теперь мы можем приступить к созданию пакета `common_github_search`.

### Клиент

> `GithubClient` будет предоставлять необработанные данные из [Github API](https://developer.github.com/v3/).

?> **Примечание:** Вы можете увидеть пример того, как будут выглядеть данные, которые мы получаем обратно [здесь](https://api.github.com/search/repositories?q=dartlang).

Давайте создадим `github_client.dart`.

```dart
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:common_github_search/common_github_search.dart';

class GithubClient {
  final String baseUrl;
  final http.Client httpClient;

  GithubClient({
    http.Client httpClient,
    this.baseUrl = "https://api.github.com/search/repositories?q=",
  }) : this.httpClient = httpClient ?? http.Client();

  Future<SearchResult> search(String term) async {
    final response = await httpClient.get(Uri.parse("$baseUrl$term"));
    final results = json.decode(response.body);

    if (response.statusCode == 200) {
      return SearchResult.fromJson(results);
    } else {
      throw SearchResultError.fromJson(results);
    }
  }
}
```

?> **Примечание:** `GithubClient` просто делает сетевой запрос к API поиска GitHub в репозитории и преобразовывает результат в `SearchResult` или `SearchResultError` как `Future`.

Далее нам нужно определить наши модели `SearchResult` и `SearchResultError`.

#### Модель результатов поиска

Создайте файл `search_result.dart`.

```dart
import 'package:common_github_search/common_github_search.dart';

class SearchResult {
  final List<SearchResultItem> items;

  const SearchResult({this.items});

  static SearchResult fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>)
        .map((dynamic item) =>
            SearchResultItem.fromJson(item as Map<String, dynamic>))
        .toList();
    return SearchResult(items: items);
  }
}
```

?> **Примечание:** Реализация `SearchResult` зависит от `SearchResultItem.fromJson`, который мы еще не реализовали.

?> **Примечание:** мы не включаем свойства, которые не будут использоваться в нашей модели.

#### Элемент результатов поиска

Далее мы создадим `search_result_item.dart`.

```dart
import 'package:common_github_search/common_github_search.dart';

class SearchResultItem {
  final String fullName;
  final String htmlUrl;
  final GithubUser owner;

  const SearchResultItem({this.fullName, this.htmlUrl, this.owner});

  static SearchResultItem fromJson(dynamic json) {
    return SearchResultItem(
      fullName: json['full_name'] as String,
      htmlUrl: json['html_url'] as String,
      owner: GithubUser.fromJson(json['owner']),
    );
  }
}
```

?> **Примечание:** опять же, реализация `SearchResultItem` зависит от `GithubUser.fromJson`, который мы еще не реализовали.

#### Модель пользователя

Далее мы создадим `github_user.dart`.

```dart
class GithubUser {
  final String login;
  final String avatarUrl;

  const GithubUser({this.login, this.avatarUrl});

  static GithubUser fromJson(dynamic json) {
    return GithubUser(
      login: json['login'] as String,
      avatarUrl: json['avatar_url'] as String,
    );
  }
}
```

На этом этапе мы завершили реализацию `SearchResult` и его зависимостей, поэтому далее мы перейдем к `SearchResultError`.

#### Модель ошибки результата поиска

Далее мы создадим `search_result_error.dart`.

```dart
class SearchResultError {
  final String message;

  const SearchResultError({this.message});

  static SearchResultError fromJson(dynamic json) {
    return SearchResultError(
      message: json['message'] as String,
    );
  }
}
```

`GithubClient` завершен, поэтому далее мы перейдем к `GithubCache`, который будет отвечать за [запоминание](https://en.wikipedia.org/wiki/Memoization) для оптимизации производительности.

### Кеш

> `GithubCache` будет отвечать за запоминание всех прошлых запросов, чтобы мы могли избежать ненужных сетевых запросов к Github API. Это также поможет улучшить производительность нашего приложения.

Создадим `github_cache.dart`.

```dart
import 'package:common_github_search/common_github_search.dart';

class GithubCache {
  final _cache = <String, SearchResult>{};

  SearchResult get(String term) => _cache[term];

  void set(String term, SearchResult result) => _cache[term] = result;

  bool contains(String term) => _cache.containsKey(term);

  void remove(String term) => _cache.remove(term);
}
```

Теперь мы готовы создать наш `GithubRepository`!

### Хранилище

> Репозиторий Github отвечает за создание абстракции между уровнем данных (`GithubClient`) и уровнем бизнес-логики (`Bloc`). Это также то место, где мы собираемся использовать наш `GithubCache`.

Создайте `github_repository.dart`.

```dart
import 'dart:async';

import 'package:common_github_search/common_github_search.dart';

class GithubRepository {
  final GithubCache cache;
  final GithubClient client;

  GithubRepository(this.cache, this.client);

  Future<SearchResult> search(String term) async {
    if (cache.contains(term)) {
      return cache.get(term);
    } else {
      final result = await client.search(term);
      cache.set(term, result);
      return result;
    }
  }
}
```

?> **Примечание:** `GithubRepository` зависит от `GithubCache` и `GithubClient` и абстрагирует базовую реализацию. Наше приложение никогда не должно знать о том, как данные извлекаются или откуда они поступают поскольку это не должно волновать. Мы можем изменить работу репозитория в любое время и до тех пор, пока мы не изменим интерфейс, нам не нужно менять какой-либо клиентский код.

На этом этапе мы завершили уровень поставщика данных и уровень хранилища, поэтому мы готовы перейти к уровню бизнес-логики.

### Событие

> Наш блок будет уведомлен когда пользователь введет имя репозитория, которое мы будем представлять как `TextChanged` `GithubSearchEvent`.

Создайте `github_search_event.dart`.

```dart
import 'package:equatable/equatable.dart';

abstract class GithubSearchEvent extends Equatable {
  const GithubSearchEvent();
}

class TextChanged extends GithubSearchEvent {
  final String text;

  const TextChanged({this.text});

  @override
  List<Object> get props => [text];

  @override
  String toString() => 'TextChanged { text: $text }';
}
```

?> **Примечание:** Мы расширяем [`Equatable`](https://pub.dev/packages/equatable), чтобы мы могли сравнивать экземпляры `GithubSearchEvent`; по умолчанию оператор равенства возвращает true, если и только если этот и другие являются одинаковыми экземплярами.

### Состояние

Уровень представления должен иметь несколько частей информации для правильного представления:

- `SearchStateEmpty` - сообщит уровню представления, что пользователь не предоставил информации
- `SearchStateLoading` - сообщит уровню представления, что он должен отображать индикатор загрузки
- `SearchStateSuccess` - сообщит уровню представления, что у него есть данные для представления

- `items`- будет `List<SearchResultItem>`, который будет отображаться

- `SearchStateError` - сообщит уровню представления, что при загрузке репозиториев произошла ошибка

- `error`- будет точной ошибкой, которая произошла

Теперь мы можем создать `github_search_state.dart` и реализовать его следующим образом.

```dart
import 'package:equatable/equatable.dart';

import 'package:common_github_search/common_github_search.dart';

abstract class GithubSearchState extends Equatable {
  const GithubSearchState();

  @override
  List<Object> get props => [];
}

class SearchStateEmpty extends GithubSearchState {}

class SearchStateLoading extends GithubSearchState {}

class SearchStateSuccess extends GithubSearchState {
  final List<SearchResultItem> items;

  const SearchStateSuccess(this.items);

  @override
  List<Object> get props => [items];

  @override
  String toString() => 'SearchStateSuccess { items: ${items.length} }';
}

class SearchStateError extends GithubSearchState {
  final String error;

  const SearchStateError(this.error);

  @override
  List<Object> get props => [error];
}
```

?> **Note:** We extend [`Equatable`](https://pub.dev/packages/equatable) so that we can compare instances of `GithubSearchState`; by default, the equality operator returns true if and only if this and other are the same instance.

Now that we have our Events and States implemented, we can create our `GithubSearchBloc`.

?> **Примечание:** Мы расширяем [`Equatable`](https://pub.dev/packages/equatable), чтобы мы могли сравнивать экземпляры `GithubSearchState`; по умолчанию оператор равенства возвращает true, если и только если этот и другие являются одинаковыми экземплярами.

Теперь, когда у нас реализованы наши `Events` и `States`, мы можем создать наш `GithubSearchBloc`.

### Блок

Создадим `github_search_bloc.dart`

```dart
import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:bloc/bloc.dart';

import 'package:common_github_search/common_github_search.dart';

class GithubSearchBloc extends Bloc<GithubSearchEvent, GithubSearchState> {
  final GithubRepository githubRepository;

  GithubSearchBloc({@required this.githubRepository});

  @override
  Stream<GithubSearchState> transformEvents(
    Stream<GithubSearchEvent> events,
    Stream<GithubSearchState> Function(GithubSearchEvent event) next,
  ) {
    return super.transformEvents(
      events.debounceTime(
        Duration(milliseconds: 500),
      ),
      next,
    );
  }

  @override
  void onTransition(
      Transition<GithubSearchEvent, GithubSearchState> transition) {
    print(transition);
  }

  @override
  GithubSearchState get initialState => SearchStateEmpty();

  @override
  Stream<GithubSearchState> mapEventToState(
    GithubSearchEvent event,
  ) async* {
    if (event is TextChanged) {
      final String searchTerm = event.text;
      if (searchTerm.isEmpty) {
        yield SearchStateEmpty();
      } else {
        yield SearchStateLoading();
        try {
          final results = await githubRepository.search(searchTerm);
          yield SearchStateSuccess(results.items);
        } catch (error) {
          yield error is SearchResultError
              ? SearchStateError(error.message)
              : SearchStateError('something went wrong');
        }
      }
    }
  }
}
```

?> **Примечание:** `GithubSearchBloc` преобразует `GithubSearchEvent` в `GithubSearchState` и зависит от `GithubRepository`.

?> **Примечание:** Мы переопределяем метод `transformEvents` для [debounce](http://reactivex.io/documentation/operators/debounce.html) `GithubSearchEvents`.

?> **Примечание:** Мы переопределяем `onTransition` для логирования каждый раз, когда происходит изменение состояния.

Потрясающие! Мы все сделали с пакетом `common_github_search`.

Готовый продукт должен выглядеть [следующим образом](https://github.com/felangel/Bloc/tree/master/examples/github_search/common_github_search).

Далее мы будем работать над реализацией Flutter.

## Flutter Github поиск

> Flutter Github Search будет приложением Flutter, которое повторно использует модели, поставщиков данных, репозитории и блоки из `common_github_search` для реализации Github Search.

### Настройка

Начнем с создания нового проекта Flutter в каталоге `github_search` на том же уровне, что и `common_github_search`.

```bash
flutter create flutter_github_search
```

Далее нам нужно обновить `pubspec.yaml`, чтобы включить все необходимые зависимости.

```yaml
name: flutter_github_search
description: A new Flutter project.

version: 1.0.0+1

environment:
  sdk: ">=2.6.0 <3.0.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^3.2.0
  url_launcher: ^4.0.3
  common_github_search:
    path: ../common_github_search

flutter:
  uses-material-design: true
```

?> **Примечание:** Мы включаем вновь созданную библиотеку `common_github_search` в качестве зависимости.

Теперь нам нужно установить зависимости.

```bash
flutter packages get
```

Это все для настройки проекта и, поскольку пакет `common_github_search` содержит уровень данных, а также уровень бизнес-логики все, что нам нужно построить - это уровень представления.

### Форма поиска

Нам нужно создать форму с виджетом `SearchBar` и `SearchBody`.

- `SearchBar` будет отвечать за ввод данных пользователем.
- `SearchBody` будет отвечать за отображение результатов поиска, индикаторов загрузки и ошибок.

Давайте создадим `search_form.dart`.

> `SearchForm` будет `StatelessWidget`, который отображает виджеты `SearchBar` и `SearchBody`.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:common_github_search/common_github_search.dart';

class SearchForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[_SearchBar(), _SearchBody()],
    );
  }
}
```

Далее мы реализуем `_SearchBar`.

### Панель поиска

> `SearchBar` также будет `StatefulWidget`, потому что ему нужно будет поддерживать свой собственный `TextController`, чтобы мы могли отслеживать, что пользователь ввел в качестве ввода.

```dart
class _SearchBar extends StatefulWidget {
  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final _textController = TextEditingController();
  GithubSearchBloc _githubSearchBloc;

  @override
  void initState() {
    super.initState();
    _githubSearchBloc = BlocProvider.of<GithubSearchBloc>(context);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _textController,
      autocorrect: false,
      onChanged: (text) {
        _githubSearchBloc.add(
          TextChanged(text: text),
        );
      },
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.search),
        suffixIcon: GestureDetector(
          child: Icon(Icons.clear),
          onTap: _onClearTapped,
        ),
        border: InputBorder.none,
        hintText: 'Enter a search term',
      ),
    );
  }

  void _onClearTapped() {
    _textController.text = '';
    _githubSearchBloc.add(TextChanged(text: ''));
  }
}
```

?> **Примечание:** `_SearchBar` обращается к `GitHubSearchBloc` через `BlocProvider.of<GithubSearchBloc>(context)` и уведомляет блок о событиях `TextChanged`.

Мы закончили с `_SearchBar`, теперь начнем `_SearchBody`.

### Тело поиска

> `SearchBody` - это StatelessWidget, который будет отвечать за отображение результатов поиска, ошибок и индикаторов загрузки. Это будет потребитель `GithubSearchBloc`.

```dart
class _SearchBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GithubSearchBloc, GithubSearchState>(
      bloc: BlocProvider.of<GithubSearchBloc>(context),
      builder: (BuildContext context, GithubSearchState state) {
        if (state is SearchStateEmpty) {
          return Text('Please enter a term to begin');
        }
        if (state is SearchStateLoading) {
          return CircularProgressIndicator();
        }
        if (state is SearchStateError) {
          return Text(state.error);
        }
        if (state is SearchStateSuccess) {
          return state.items.isEmpty
              ? Text('No Results')
              : Expanded(child: _SearchResults(items: state.items));
        }
      },
    );
  }
}
```

?> **Примечание:** `_SearchBody` также обращается к `GithubSearchBloc` через `BlocProvider` и использует `BlocBuilder` для перерендеринга в ответ на изменения состояния.

Если наше состояние равно `SearchStateSuccess`, мы отображаем `_SearchResults`, который мы будем реализовывать следующим.

### Результаты поиска

> `SearchResults` является `StatelessWidget`, который принимает `List<SearchResultItem>` и отображает их в виде списка `SearchResultItems`.

```dart
class _SearchResults extends StatelessWidget {
  final List<SearchResultItem> items;

  const _SearchResults({Key key, this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        return _SearchResultItem(item: items[index]);
      },
    );
  }
}
```

?> **Примечание:** Мы используем `ListView.builder`, чтобы создать прокручиваемый список `SearchResultItem`.

Пришло время реализовать `_SearchResultItem`.

### Элемент результата поиска

> `SearchResultItem` является `StatelessWidget` и отвечает за отображение информации для одного результата поиска. Он также отвечает за обработку взаимодействия с пользователем и переход к URL-адресу хранилища по касанию пользователя.

```dart
class _SearchResultItem extends StatelessWidget {
  final SearchResultItem item;

  const _SearchResultItem({Key key, @required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Image.network(item.owner.avatarUrl),
      ),
      title: Text(item.fullName),
      onTap: () async {
        if (await canLaunch(item.htmlUrl)) {
          await launch(item.htmlUrl);
        }
      },
    );
  }
}
```

?> **Примечание:** мы используем пакет [url_launcher](https://pub.dev/packages/url_launcher) для доступа к внешним URL.

### Собираем все вместе

На данный момент `search_form.dart` должен выглядеть так:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:common_github_search/common_github_search.dart';

class SearchForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[_SearchBar(), _SearchBody()],
    );
  }
}

class _SearchBar extends StatefulWidget {
  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final _textController = TextEditingController();
  GithubSearchBloc _githubSearchBloc;

  @override
  void initState() {
    super.initState();
    _githubSearchBloc = BlocProvider.of<GithubSearchBloc>(context);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _textController,
      autocorrect: false,
      onChanged: (text) {
        _githubSearchBloc.add(
          TextChanged(text: text),
        );
      },
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.search),
        suffixIcon: GestureDetector(
          child: Icon(Icons.clear),
          onTap: _onClearTapped,
        ),
        border: InputBorder.none,
        hintText: 'Enter a search term',
      ),
    );
  }

  void _onClearTapped() {
    _textController.text = '';
    _githubSearchBloc.add(TextChanged(text: ''));
  }
}

class _SearchBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GithubSearchBloc, GithubSearchState>(
      bloc: BlocProvider.of<GithubSearchBloc>(context),
      builder: (BuildContext context, GithubSearchState state) {
        if (state is SearchStateEmpty) {
          return Text('Please enter a term to begin');
        }
        if (state is SearchStateLoading) {
          return CircularProgressIndicator();
        }
        if (state is SearchStateError) {
          return Text(state.error);
        }
        if (state is SearchStateSuccess) {
          return state.items.isEmpty
              ? Text('No Results')
              : Expanded(child: _SearchResults(items: state.items));
        }
      },
    );
  }
}

class _SearchResults extends StatelessWidget {
  final List<SearchResultItem> items;

  const _SearchResults({Key key, this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        return _SearchResultItem(item: items[index]);
      },
    );
  }
}

class _SearchResultItem extends StatelessWidget {
  final SearchResultItem item;

  const _SearchResultItem({Key key, @required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Image.network(item.owner.avatarUrl),
      ),
      title: Text(item.fullName),
      onTap: () async {
        if (await canLaunch(item.htmlUrl)) {
          await launch(item.htmlUrl);
        }
      },
    );
  }
}
```

Теперь осталось только реализовать основное приложение в `main.dart`.

```dart
import 'package:flutter/material.dart';

import 'package:meta/meta.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:common_github_search/common_github_search.dart';
import 'package:flutter_github_search/search_form.dart';

void main() {
  final GithubRepository _githubRepository = GithubRepository(
    GithubCache(),
    GithubClient(),
  );

  runApp(App(githubRepository: _githubRepository));
}

class App extends StatelessWidget {
  final GithubRepository githubRepository;

  const App({
    Key key,
    @required this.githubRepository,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Github Search',
      home: Scaffold(
        appBar: AppBar(title: Text('Github Search')),
        body: BlocProvider(
          create: (context) =>
              GithubSearchBloc(githubRepository: githubRepository),
          child: SearchForm(),
        ),
      ),
    );
  }
}
```

?> **Примечание:** `GithubRepository` создается в `main` и внедряется в `App`. `SearchForm` обернута в `BlocProvider`, который отвечает за инициализацию, закрытие и обеспечение доступности экземпляра `GithubSearchBloc` для виджета `SearchForm` и его дочерних элементов.

Вот и все, что нужно сделать! Теперь мы успешно внедрили поисковое приложение Github на Flutter, используя пакеты [bloc](https://pub.dev/packages/bloc) и [flutter_bloc](https://pub.dev/packages/flutter_bloc) и мы успешно отделили наш уровень представления от нашей бизнес-логики.

Полный исходный код можно найти [здесь](https://github.com/felangel/Bloc/tree/master/examples/github_search/flutter_github_search).

Наконец, мы собираемся создать наше приложение AngularDart Github Search.

## AngularDart Github поиск

> AngularDart Github Search будет приложением AngularDart, которое повторно использует модели, поставщиков данных, репозитории и блоки из `common_github_search` для реализации Github Search.

### Настройка

Нам нужно начать с создания нового проекта AngularDart в каталоге `github_search` на том же уровне, что и `common_github_search`.

```bash
stagehand web-angular
```

!> Активируйте `stagehand`, запустив `pub global activate stagehand`

Затем мы можем заменить содержимое `pubspec.yaml` на:

```yaml
name: angular_github_search
description: A web app that uses AngularDart Components

environment:
  sdk: ">=2.6.0 <3.0.0"

dependencies:
  angular: ^5.3.0
  angular_components: ^0.13.0
  angular_bloc: ^3.0.0
  common_github_search:
    path: ../common_github_search

dev_dependencies:
  angular_test: ^2.0.0
  build_runner: ">=1.6.2 <2.0.0"
  build_test: ^0.10.2
  build_web_compilers: ">=1.2.0 <3.0.0"
  test: ^1.0.0
```

### Форма поиска

Как и в приложении Flutter, нам нужно создать `SearchForm` с компонентами `SearchBar` и `SearchBody`.

> Компонент `SearchForm` будет реализовывать `OnInit` и `OnDestroy`, потому что ему нужно будет создать и закрыть `GithubSearchBloc`.

- `SearchBar` будет отвечать за ввод данных пользователем.
- `SearchBody` будет отвечать за отображение результатов поиска, индикаторов загрузки и ошибок.

Давайте создадим `search_form_component.dart`.

```dart
import 'package:angular/angular.dart';
import 'package:angular_bloc/angular_bloc.dart';

import 'package:common_github_search/common_github_search.dart';
import 'package:angular_github_search/src/github_search.dart';

@Component(
    selector: 'search-form',
    templateUrl: 'search_form_component.html',
    directives: [
      SearchBarComponent,
      SearchBodyComponent,
    ],
    pipes: [
      BlocPipe
    ])
class SearchFormComponent implements OnInit, OnDestroy {
  @Input()
  GithubRepository githubRepository;

  GithubSearchBloc githubSearchBloc;

  @override
  void ngOnInit() {
    githubSearchBloc = GithubSearchBloc(
      githubRepository: githubRepository,
    );
  }

  @override
  void ngOnDestroy() {
    githubSearchBloc.close();
  }
}
```

?> **Примечание:** `GithubRepository` внедряется в `SearchFormComponent`.

?> **Примечание:** `GithubSearchBloc` создается и закрывается с помощью `SearchFormComponent`.

Шаблон `search_form_component.html` будет выглядеть так:

```html
<div>
  <h1>Github Search</h1>
  <search-bar [githubSearchBloc]="githubSearchBloc"></search-bar>
  <search-body [state]="githubSearchBloc | bloc"></search-body>
</div>
```

Далее мы реализуем компонент `SearchBar`.

### Панель поиска

> SearchBar - это компонент, который будет отвечать за ввод данных пользователем и уведомлять `GithubSearchBloc` об изменениях текста.

Создадим `search_bar_component.dart`.

```dart
import 'package:angular/angular.dart';

import 'package:common_github_search/common_github_search.dart';

@Component(
  selector: 'search-bar',
  templateUrl: 'search_bar_component.html',
)
class SearchBarComponent {
  @Input()
  GithubSearchBloc githubSearchBloc;

  void onTextChanged(String text) {
    githubSearchBloc.add(TextChanged(text: text));
  }
}
```

?> **Примечание:** `SearchBarComponent` зависит от `GitHubSearchBloc`, поскольку он отвечает за уведомление блока о событиях `TextChanged`.

Далее мы можем создать `search_bar_component.html`.

```html
<label for="term" class="clip">Enter a search term</label>
<input
  id="term"
  placeholder="Enter a search term"
  class="input-reset outline-transparent glow o-50 bg-near-black near-white w-100 pv2 border-box b--white-50 br-0 bl-0 bt-0 bb-ridge mb3"
  autofocus
  (keyup)="onTextChanged($event.target.value)"
/>
```

Мы закончили с `SearchBar`, теперь займемся `SearchBody`.

### Тело поиска

> `SearchBody` - это компонент, который будет отвечать за отображение результатов поиска, ошибок и индикаторов загрузки. Это будет потребитель `GithubSearchBloc`.

Создадим `search_body_component.dart`

```dart
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';

import 'package:common_github_search/common_github_search.dart';
import 'package:angular_github_search/src/github_search.dart';

@Component(
  selector: 'search-body',
  templateUrl: 'search_body_component.html',
  directives: [
    coreDirectives,
    MaterialSpinnerComponent,
    MaterialIconComponent,
    SearchResultsComponent,
  ],
)
class SearchBodyComponent {
  @Input()
  GithubSearchState state;

  bool get isEmpty => state is SearchStateEmpty;
  bool get isLoading => state is SearchStateLoading;
  bool get isSuccess => state is SearchStateSuccess;
  bool get isError => state is SearchStateError;

  List<SearchResultItem> get items =>
      isSuccess ? (state as SearchStateSuccess).items : [];

  String get error => isError ? (state as SearchStateError).error : '';
}
```

?> **Примечание:** `SearchBodyComponent` зависит от `GithubSearchState`, который предоставляется `GithubSearchBloc` с использованием блока `angular_bloc`.

Создадим `search_body_component.html`

```html
<div *ngIf="state != null" class="mw10">
  <div *ngIf="isEmpty" class="tc">
    <material-icon icon="info" class="light-blue"></material-icon>
    <p>Please enter a term to begin</p>
  </div>
  <div *ngIf="isLoading" class="tc"><material-spinner></material-spinner></div>
  <div *ngIf="isError" class="tc">
    <material-icon icon="error" class="light-red"></material-icon>
    <p>{{ error }}</p>
  </div>
  <div *ngIf="isSuccess">
    <div *ngIf="items.length == 0" class="tc">
      <material-icon icon="warning" class="light-yellow"></material-icon>
      <p>No Results</p>
    </div>
    <search-results [items]="items"></search-results>
  </div>
</div>
```

Если наше состояние `isSuccess`, мы визуализируем `SearchResults`, который мы будем реализовывать следующим.

### Результаты поиска

> `SearchResults` - это компонент, который берет `List<SearchResultItem>` и отображает в виде списка `SearchResultItems`.

Создадим `search_results_component.dart`

```dart
import 'package:angular/angular.dart';

import 'package:common_github_search/common_github_search.dart';
import 'package:angular_github_search/src/github_search.dart';

@Component(
  selector: 'search-results',
  templateUrl: 'search_results_component.html',
  directives: [coreDirectives, SearchResultItemComponent],
)
class SearchResultsComponent {
  @Input()
  List<SearchResultItem> items;
}
```

Далее мы создадим `search_results_component.html`.

```html
<ul class="list pa0 ma0">
  <li *ngFor="let item of items" class="pa2 cf">
    <search-result-item [item]="item"></search-result-item>
  </li>
</ul>
```

?> **Примечание:** мы используем `ngFor`, чтобы создать список компонентов `SearchResultItem`.

Пришло время реализовать `SearchResultItem`.

### Элемент результата поиска

> `SearchResultItem` - это компонент, который отвечает за отображение информации для одного результата поиска. Он также отвечает за обработку взаимодействия с пользователем и переход к URL-адресу хранилища по касанию пользователя.

Создадим `search_result_item_component.dart`.

```dart
import 'package:angular/angular.dart';

import 'package:common_github_search/common_github_search.dart';

@Component(
  selector: 'search-result-item',
  templateUrl: 'search_result_item_component.html',
)
class SearchResultItemComponent {
  @Input()
  SearchResultItem item;
}
```

и соответствующий шаблон в `search_result_item_component.html`.

```html
<div class="fl w-10 h-auto">
  <img class="br-100" src="{{ item?.owner.avatarUrl }}" />
</div>
<div class="fl w-90 ph3">
  <h1 class="f5 ma0">{{ item.fullName }}</h1>
  <p>
    <a href="{{ item?.htmlUrl }}" class="light-blue" target="_blank"
      >{{ item?.htmlUrl }}</a
    >
  </p>
</div>
```

### Собираем все вместе

У нас есть все компоненты и теперь пришло время собрать их все вместе в `app_component.dart`.

```dart
import 'package:angular/angular.dart';

import 'package:common_github_search/common_github_search.dart';
import 'package:angular_github_search/src/github_search.dart';

@Component(
  selector: 'my-app',
  template:
      '<search-form [githubRepository]="githubRepository"></search-form>',
  directives: [SearchFormComponent],
)
class AppComponent {
  final githubRepository = GithubRepository(
    GithubCache(),
    GithubClient(),
  );
}
```

?> **Примечание:** мы создаем `GithubRepository` в `AppComponent` и внедряем его в компонент `SearchForm`.

Вот и все, что нужно сделать! Теперь мы успешно внедрили поисковое приложение Github в AngularDart с использованием пакетов `bloc` и `angular_bloc` и успешно отделили уровень представления от бизнес-логики.

Полный исходный код можно найти [здесь](https://github.com/felangel/Bloc/tree/master/examples/github_search/angular_github_search).

## Резюме

В этом руководстве мы создали приложение Flutter и AngularDart, в то же время обмениваясь всеми моделями, поставщиками данных и блоками.

Единственной вещью, которую мы фактически должны были написать дважды, был уровень представления (UI), который является удивительным с точки зрения эффективности и скорости разработки. Кроме того, веб-приложения и мобильные приложения довольно часто имеют разные пользовательские интерфейсы и стили и этот подход действительно демонстрирует, насколько легко создавать два приложения, которые выглядят совершенно по-разному, но имеют одни и те же слои данных и бизнес-логики.

Полный исходный код можно найти [здесь](https://github.com/felangel/Bloc/tree/master/examples/github_search).

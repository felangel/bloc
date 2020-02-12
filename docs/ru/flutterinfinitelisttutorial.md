# Flutter бесконечный список

![intermediate](https://img.shields.io/badge/level-intermediate-orange.svg)

> В этом руководстве мы собираемся реализовать приложение, которое извлекает данные по сети и загружает их когда пользователь выполняет прокрутку, используя Flutter и библиотеку `bloc`.

![demo](../assets/gifs/flutter_infinite_list.gif)

## Настройка

Мы начнем с создания нового проекта Flutter

```bash
flutter create flutter_infinite_list
```

Сначала нам нужно заменить содержимое файла `pubspec.yaml` на:

```yaml
name: flutter_infinite_list
description: A new Flutter project.

version: 1.0.0+1

environment:
  sdk: ">=2.6.0 <3.0.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^3.2.0
  http: ^0.12.0
  equatable: ^1.0.0

flutter:
  uses-material-design: true
```

а затем установить все наши зависимости

```bash
flutter packages get
```

## REST API

Для этого демонстрационного приложения мы будем использовать [jsonplaceholder](http://jsonplaceholder.typicode.com) в качестве источника данных.

?> `jsonplaceholder` - это онлайн REST API, который обслуживает поддельные данные; это очень полезно для создания прототипов.

Откройте новую вкладку в своем браузере и посетите страницу https://jsonplaceholder.typicode.com/posts?_start=0&_limit=2, чтобы узнать что возвращает API.

```json
[
  {
    "userId": 1,
    "id": 1,
    "title": "sunt aut facere repellat provident occaecati excepturi optio reprehenderit",
    "body": "quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto"
  },
  {
    "userId": 1,
    "id": 2,
    "title": "qui est esse",
    "body": "est rerum tempore vitae\nsequi sint nihil reprehenderit dolor beatae ea dolores neque\nfugiat blanditiis voluptate porro vel nihil molestiae ut reiciendis\nqui aperiam non debitis possimus qui neque nisi nulla"
  }
]
```

?> **Примечание:** в нашем URL мы указали начало и ограничение в качестве параметров для запроса GET.

Отлично, теперь когда мы знаем как будут выглядеть наши данные, давайте создадим модель.

## Модель данных

Создайте `post.dart` и давайте приступим к созданию модели нашего объекта `Post`.

```dart
import 'package:equatable/equatable.dart';

class Post extends Equatable {
  final int id;
  final String title;
  final String body;

  const Post({this.id, this.title, this.body});

  @override
  List<Object> get props => [id, title, body];

  @override
  String toString() => 'Post { id: $id }';
}
```

`Post` это просто класс с `id`, `title`, and `body`.

?> Мы переопределяем функцию `toString`, чтобы иметь собственное строковое представление нашего `Post` на будущее.

?> Мы расширяем [`Equatable`](https://pub.dev/packages/equatable), чтобы мы могли сравнивать `Posts`; по умолчанию оператор равенства возвращает true, если этот и другие являются одинаковыми экземплярами.

Теперь, когда у нас есть объектная модель `Post`, давайте приступим к работе с компонентом Business Logic (`bloc`).

## События

Прежде чем мы углубимся в реализацию, нам нужно определить, что будет делать наш `PostBloc`.

На верхнем уровне он будет реагировать на пользовательский ввод (прокрутку) и извлекать больше сообщений, чтобы их отображал уровень презентации. Давайте начнем с создания нашего `Event`.

Наш `PostBloc` будет отвечать только на одно событие; `Fetch`, которое будет добавляться уровнем представления всякий раз, когда ему нужно представить больше сообщений. Поскольку наше событие `Fetch` является типом `PostEvent`, мы можем создать `bloc/post_event.dart` и реализовать событие следующим образом.

```dart
import 'package:equatable/equatable.dart';

abstract class PostEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class Fetch extends PostEvent {}
```

?> Опять же, мы переопределяем `toString` для облегчения чтения строкового представления нашего события. Мы опять расширяем [`Equatable`](https://pub.dev/packages/equatable), чтобы мы могли сравнивать экземпляры на равенство.

Напомним, что наш `PostBloc` будет получать `PostEvents` и преобразовывать их в `PostStates`. Мы определили все наши `PostEvents` (Fetch), так что теперь давайте определим наш `PostState`.

## Состояния

Наш уровень представления должен иметь несколько видов информации, чтобы правильно соотвествовать:

- `PostUninitialized` - сообщит слою представления, что ему нужно визуализировать индикатор загрузки, пока загружается начальная часть сообщений.

- `PostLoaded` - сообщит слою представления, что у него есть контент для рендеринга
  - `posts` - будет списком объектов `List<Post>`, который будет отображен
  - `hasReachedMax` - сообщит слою представления, достигло ли оно максимального количества постов
- `PostError` - сообщит слою представления, что при получении сообщений произошла ошибка

Теперь мы можем создать `bloc/post_state.dart` и реализовать это приблизительно так:

```dart
import 'package:equatable/equatable.dart';

import 'package:flutter_infinite_list/models/models.dart';

abstract class PostState extends Equatable {
  const PostState();

  @override
  List<Object> get props => [];
}

class PostUninitialized extends PostState {}

class PostError extends PostState {}

class PostLoaded extends PostState {
  final List<Post> posts;
  final bool hasReachedMax;

  const PostLoaded({
    this.posts,
    this.hasReachedMax,
  });

  PostLoaded copyWith({
    List<Post> posts,
    bool hasReachedMax,
  }) {
    return PostLoaded(
      posts: posts ?? this.posts,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object> get props => [posts, hasReachedMax];

  @override
  String toString() =>
      'PostLoaded { posts: ${posts.length}, hasReachedMax: $hasReachedMax }';
}
```

?> Мы реализовали `copyWith`, чтобы мы могли скопировать экземпляр `PostLoaded` и выборочно обновить его свойства (это пригодится позже).

Теперь, когда у нас реализованы наши `Events` и `States`, мы можем создать наш `PostBloc`.

Чтобы было удобно импортировать наши состояния и события с помощью одного импорта, мы можем создать `bloc/bloc.dart`, который экспортирует их все (мы добавим наш экспорт`post_bloc.dart` в следующем разделе).

```dart
export './post_event.dart';
export './post_state.dart';
```

## Блок

Для простоты наш `PostBloc` будет иметь прямую зависимость от `http client`; однако в финальном приложении вы можете вместо этого внедрить клиент API и использовать паттерн репозитория [по ссылке](ru/architecture.md).

Давайте создадим `post_bloc.dart` и создадим наш пустой `PostBloc`.

```dart
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_infinite_list/bloc/bloc.dart';
import 'package:flutter_infinite_list/post.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final http.Client httpClient;

  PostBloc({@required this.httpClient});

  @override
  // TODO: implement initialState
  PostState get initialState => null;

  @override
  Stream<PostState> mapEventToState(PostEvent event) async* {
    // TODO: implement mapEventToState
    yield null;
  }
}
```

?> **Примечание:** только в объявлении класса мы можем сказать, что наш `PostBloc` будет принимать `PostEvents` в качестве ввода и вывода `PostStates`.

Мы можем начать с реализации `initialState`, который будет состоянием нашего `PostBloc` до добавления каких-либо событий.

```dart
@override
get initialState => PostUninitialized();
```

Затем нам нужно реализовать `mapEventToState`, который будет запускаться каждый раз, когда добавляется `PostEvent`.

```dart
@override
Stream<PostState> mapEventToState(PostEvent event) async* {
  final currentState = state;
  if (event is Fetch && !_hasReachedMax(currentState)) {
    try {
      if (currentState is PostUninitialized) {
        final posts = await _fetchPosts(0, 20);
        yield PostLoaded(posts: posts, hasReachedMax: false);
        return;
      }
      if (currentState is PostLoaded) {
        final posts =
            await _fetchPosts(currentState.posts.length, 20);
        yield posts.isEmpty
            ? currentState.copyWith(hasReachedMax: true)
            : PostLoaded(
                posts: currentState.posts + posts,
                hasReachedMax: false,
              );
      }
    } catch (_) {
      yield PostError();
    }
  }
}

bool _hasReachedMax(PostState state) =>
    state is PostLoaded && state.hasReachedMax;

Future<List<Post>> _fetchPosts(int startIndex, int limit) async {
  final response = await httpClient.get(
      'https://jsonplaceholder.typicode.com/posts?_start=$startIndex&_limit=$limit');
  if (response.statusCode == 200) {
    final data = json.decode(response.body) as List;
    return data.map((rawPost) {
      return Post(
        id: rawPost['id'],
        title: rawPost['title'],
        body: rawPost['body'],
      );
    }).toList();
  } else {
    throw Exception('error fetching posts');
  }
}
```

Наш `PostBloc` будет производить `yield` всякий раз, когда появляется новое состояние, потому что он возвращает `Stream <PostState>`. Проверьте [Основные понятия](ru/coreconcepts?id=streams-Потоки) для получения дополнительной информации о `Streams` и других основах.

Теперь каждый раз, когда добавляется `PostEvent` и если это событие `Fetch`, а также есть еще сообщения для извлечения, наш `PostBloc` будет извлекать следующие 20 сообщений.

API вернет пустой массив, если мы попытаемся извлечь больше максимального количества записей (100), поэтому, если мы вернем пустой массив, наш блок сделает `yield currentState` и, кроме того, мы установим для `hasReachedMax` значение true.

Если мы не можем получить сообщения, мы выдаем исключение и `yield PostError ()`.

Если мы можем получить сообщения, мы возвращаем `PostLoaded()`, который принимает весь список сообщений.

Одна из оптимизаций, которую мы можем сделать - это `debounce Events` (отменить события), чтобы избежать ненужного спама в нашем API. Мы можем сделать это, переопределив метод `transform` в нашем `PostBloc`.

?> **Примечание:** Переопределение позволяет нам преобразовать `Stream<Event>` до вызова `mapEventToState`. Это позволяет применять такие операции, как Different(), debounceTime() и т.д.

```dart
@override
Stream<PostState> transformEvents(
  Stream<PostEvent> events,
  Stream<PostState> Function(PostEvent event) next,
) {
  return super.transformEvents(
    events.debounceTime(
      Duration(milliseconds: 500),
    ),
    next,
  );
}
```

Our finished `PostBloc` should now look like this:

```dart
import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;
import 'package:bloc/bloc.dart';

import 'package:flutter_infinite_list/post.dart';
import 'package:flutter_infinite_list/bloc/bloc.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final http.Client httpClient;

  PostBloc({@required this.httpClient});

  @override
  Stream<PostState> transformEvents(
    Stream<PostEvent> events,
    Stream<PostState> Function(PostEvent event) next,
  ) {
    return super.transformEvents(
      events.debounceTime(
        Duration(milliseconds: 500),
      ),
      next,
    );
  }

  @override
  get initialState => PostUninitialized();

  @override
  Stream<PostState> mapEventToState(event) async* {
    final currentState = state;
    if (event is Fetch && !_hasReachedMax(currentState)) {
      try {
        if (currentState is PostUninitialized) {
          final posts = await _fetchPosts(0, 20);
          yield PostLoaded(posts: posts, hasReachedMax: false);
        }
        if (currentState is PostLoaded) {
          final posts = await _fetchPosts(currentState.posts.length, 20);
          yield posts.isEmpty
              ? currentState.copyWith(hasReachedMax: true)
              : PostLoaded(
                  posts: currentState.posts + posts, hasReachedMax: false);
        }
      } catch (_) {
        yield PostError();
      }
    }
  }

  bool _hasReachedMax(PostState state) =>
      state is PostLoaded && state.hasReachedMax;

  Future<List<Post>> _fetchPosts(int startIndex, int limit) async {
    final response = await httpClient.get(
        'https://jsonplaceholder.typicode.com/posts?_start=$startIndex&_limit=$limit');
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((rawPost) {
        return Post(
          id: rawPost['id'],
          title: rawPost['title'],
          body: rawPost['body'],
        );
      }).toList();
    } else {
      throw Exception('error fetching posts');
    }
  }
}
```

Не забудьте обновить `bloc/bloc.dart` и включить наш `PostBloc`!

```dart
export './post_bloc.dart';
export './post_event.dart';
export './post_state.dart';
```

Great! Now that we’ve finished implementing the business logic all that’s left to do is implement the presentation layer.

Великолепно! Теперь, когда мы закончили реализацию бизнес логики, нам остался только уровень представления.

## Представление

В нашем `main.dart` мы можем начать с реализации нашей основной функции и вызова `runApp` для рендеринга корневого виджета.

В нашем виджете `App` мы используем `BlocProvider` для создания и предоставления экземпляра `PostBloc` для поддерева. Также мы добавляем событие `Fetch`, чтобы при загрузке приложения оно запрашивало начальные данные.

```dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_infinite_list/bloc/bloc.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Infinite Scroll',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Posts'),
        ),
        body: BlocProvider(
          create: (context) =>
              PostBloc(httpClient: http.Client())..add(Fetch()),
          child: HomePage(),
        ),
      ),
    );
  }
}
```

Далее нам нужно реализовать наш виджет `HomePage`, который будет представлять наши сообщения и подключаться к нашему `PostBloc`.

```dart
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scrollController = ScrollController();
  final _scrollThreshold = 200.0;
  PostBloc _postBloc;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _postBloc = BlocProvider.of<PostBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostBloc, PostState>(
      builder: (context, state) {
        if (state is PostUninitialized) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (state is PostError) {
          return Center(
            child: Text('failed to fetch posts'),
          );
        }
        if (state is PostLoaded) {
          if (state.posts.isEmpty) {
            return Center(
              child: Text('no posts'),
            );
          }
          return ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              return index >= state.posts.length
                  ? BottomLoader()
                  : PostWidget(post: state.posts[index]);
            },
            itemCount: state.hasReachedMax
                ? state.posts.length
                : state.posts.length + 1,
            controller: _scrollController,
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= _scrollThreshold) {
      _postBloc.add(Fetch());
    }
  }
}
```

?> `HomePage` является `StatefulWidget` потому, что он должен поддерживать `ScrollController`. В `initState` мы добавляем слушателя к нашему `ScrollController`, чтобы мы могли реагировать на события прокрутки. Мы также обращаемся к нашему экземпляру `PostBloc` через `BlocProvider.of<PostBloc>(context)`.

В дальнейшем наш метод `build` возвращает `BlocBuilder`. `BlocBuilder` - это виджет Flutter из пакета [flutter_bloc](https://pub.dev/packages/flutter_bloc), который обрабатывает создание виджета в ответ на новые состояния блока. Каждый раз, когда изменяется наше состояние `PostBloc`, наша функция конструктора будет вызываться с новым `PostState`.

!> Нам нужно помнить о необходимости убирать за собой и избавляться от нашего `ScrollController` при удалении `StatefulWidget`.

Всякий раз, когда пользователь прокручивает, мы вычисляем как далеко от нижней части страницы мы находимся и если расстояние ≤ нашего `_scrollThreshold`, мы добавляем событие `Fetch`, чтобы загрузить больше сообщений.

Далее нам нужно реализовать наш виджет `BottomLoader`, который будет указывать пользователю, что мы загружаем больше постов.

```dart
class BottomLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Center(
        child: SizedBox(
          width: 33,
          height: 33,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
          ),
        ),
      ),
    );
  }
}
```

Наконец, нам нужно реализовать наш `PostWidget`, который будет отображать отдельный пост.

```dart
class PostWidget extends StatelessWidget {
  final Post post;

  const PostWidget({Key key, @required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(
        '${post.id}',
        style: TextStyle(fontSize: 10.0),
      ),
      title: Text(post.title),
      isThreeLine: true,
      subtitle: Text(post.body),
      dense: true,
    );
  }
}
```

На этом этапе мы должны иметь возможность запустить наше приложение, и все должно работать; тем не менее, есть еще одна вещь, которую мы можем сделать.

Еще один дополнительный бонус от использования библиотеки `bloc` - это то, что мы можем иметь доступ ко всем `Transitions` в одном месте.

> Переход из одного состояния в другое называется `Transition`.

?> `Transition` состоит из текущего состояния, события и следующего состояния.

Несмотря на то, что в этом приложении у нас есть только один блок, в больших приложениях довольно часто можно видеть множество блоков, управляющих различными частями состояния приложения.

Если мы хотим иметь возможность что-то делать в ответ на все `Transitions`, мы можем просто создать наш собственный `BlocDelegate`.

```dart
import 'package:bloc/bloc.dart';

class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }
}
```

?> Все, что нам нужно сделать, это расширить `BlocDelegate` и переопределить метод `onTransition`.

Чтобы указать `Bloc` использовать наш `SimpleBlocDelegate`, нам просто нужно настроить нашу основную функцию.

```dart
void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();
  runApp(MyApp());
}
```

Теперь, когда мы запускаем наше приложение, каждый раз, когда происходит блок `Transition`, мы можем видеть переход, напечатанный на консоли.

?> На практике вы можете создавать разные `BlocDelegates` и, поскольку каждое изменение состояния сохраняется, мы можем очень легко оборудовать наши приложения и отслеживать все взаимодействия пользователей и изменения состояния в одном месте!

Вот и все, что нужно сделать! Теперь мы успешно реализовали бесконечный список во Flutter, используя пакеты [bloc](https://pub.dev/packages/bloc) и [flutter_bloc](https://pub.dev/packages/flutter_bloc) и мы успешно отделили наш уровень представления от нашей бизнес логики.

Наша `HomePage` не знает откуда берутся сообщения и как они извлекаются. И наоборот, наш `PostBloc` не знает как отображается `State`, он просто конвертирует события в состояния.

Полный исходный код этого примера можно найти [здесь](https://github.com/felangel/Bloc/tree/master/examples/flutter_infinite_list).

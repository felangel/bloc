# Рецепты: Навигация

> В этом рецепте мы рассмотрим, как использовать `BlocBuilder` и/или `BlocListener` для навигации. Мы исследуем два подхода: прямая навигация и навигация по маршруту.

## Прямая навигация

> В этом примере мы рассмотрим, как использовать `BlocBuilder` для отображения конкретной страницы (виджета) в ответ на изменение состояния в блоке без использования маршрута.

![demo](../assets/gifs/recipes_flutter_navigation_direct.gif)

### Блок

#### События

Давайте создадим `MyBloc`, который возьмет `MyEvents` и преобразует их в `MyStates`.

#### Мои события

Для простоты наш `MyBloc` будет отвечать только на два `MyEvents`: `eventA` и `eventB`.

```dart
enum MyEvent { eventA, eventB }
```

#### Мои состояния

`MyBloc` может иметь один из двух разных `DataStates`:

- `StateA` - состояние блока при отображении `PageA`.
- `StateB` - состояние блока при отображении `PageB`.

```dart
abstract class MyState {}

class StateA extends MyState {}

class StateB extends MyState {}
```

#### Мой блок

`MyBloc` должен выглядеть примерно так:

```dart
import 'package:bloc/bloc.dart';

class MyBloc extends Bloc<MyEvent, MyState> {
  @override
  MyState get initialState => StateA();

  @override
  Stream<MyState> mapEventToState(MyEvent event) async* {
    switch (event) {
      case MyEvent.eventA:
        yield StateA();
        break;
      case MyEvent.eventB:
        yield StateB();
        break;
    }
  }
}
```

### UI слой

Теперь давайте посмотрим, как подключить `MyBloc` к виджету и показать другую страницу, основанную на состоянии блока.

```dart
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(
    BlocProvider(
      create: (context) => MyBloc(),
      child: MyApp(),
    ),
  );
}

enum MyEvent { eventA, eventB }

@immutable
abstract class MyState {}

class StateA extends MyState {}

class StateB extends MyState {}

class MyBloc extends Bloc<MyEvent, MyState> {
  @override
  MyState get initialState => StateA();

  @override
  Stream<MyState> mapEventToState(MyEvent event) async* {
    switch (event) {
      case MyEvent.eventA:
        yield StateA();
        break;
      case MyEvent.eventB:
        yield StateB();
        break;
    }
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocBuilder<MyBloc, MyState>(
        builder: (_, state) => state is StateA ? PageA() : PageB(),
      ),
    );
  }
}

class PageA extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Page A'),
      ),
      body: Center(
        child: RaisedButton(
          child: Text('Go to PageB'),
          onPressed: () {
            BlocProvider.of<MyBloc>(context).add(MyEvent.eventB);
          },
        ),
      ),
    );
  }
}

class PageB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Page B'),
      ),
      body: Center(
        child: RaisedButton(
          child: Text('Go to PageA'),
          onPressed: () {
            BlocProvider.of<MyBloc>(context).add(MyEvent.eventA);
          },
        ),
      ),
    );
  }
}
```

?> Мы используем виджет `BlocBuilder`, чтобы отобразить правильный виджет в ответ на изменения состояния в `MyBloc`.

?> Мы используем виджет `BlocProvider`, чтобы сделать экземпляр `MyBloc` доступным для всего дерева виджетов.

Полный источник этого рецепта можно найти [здесь](https://gist.github.com/felangel/386c840aad41c7675ab8695f15c4cb09).

## Навигация по маршруту

> В этом примере мы рассмотрим, как использовать `BlocListener` для перехода на определенную страницу (виджет) в ответ на изменение состояния в блоке с использованием маршрута.

![demo](../assets/gifs/recipes_flutter_navigation_routes.gif)

### Блок

Мы будем повторно использовать тот же `MyBloc` из предыдущего примера.

### UI слой

Давайте посмотрим, как перейти на другую страницу в зависимости от состояния MyBloc.

```dart
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(
    BlocProvider(
      create: (context) => MyBloc(),
      child: MyApp(),
    ),
  );
}

enum MyEvent { eventA, eventB }

@immutable
abstract class MyState {}

class StateA extends MyState {}

class StateB extends MyState {}

class MyBloc extends Bloc<MyEvent, MyState> {
  @override
  MyState get initialState => StateA();

  @override
  Stream<MyState> mapEventToState(MyEvent event) async* {
    switch (event) {
      case MyEvent.eventA:
        yield StateA();
        break;
      case MyEvent.eventB:
        yield StateB();
        break;
    }
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (context) => PageA(),
        '/pageB': (context) => PageB(),
      },
      initialRoute: '/',
    );
  }
}

class PageA extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<MyBloc, MyState>(
      listener: (context, state) {
        if (state is StateB) {
          Navigator.of(context).pushNamed('/pageB');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Page A'),
        ),
        body: Center(
          child: RaisedButton(
            child: Text('Go to PageB'),
            onPressed: () {
              BlocProvider.of<MyBloc>(context).add(MyEvent.eventB);
            },
          ),
        ),
      ),
    );
  }
}

class PageB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Page B'),
      ),
      body: Center(
        child: RaisedButton(
          child: Text('Pop'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}
```

?> Мы используем виджет `BlocListener`, чтобы выставить новый маршрут в ответ на изменения состояния в нашем `MyBloc`.

!> Ради этого примера мы добавляем событие только для навигации. В реальном приложении не следует создавать явные события навигации. Если для запуска навигации не требуется бизнес-логика, вы всегда должны осуществлять непосредственную навигацию в ответ на ввод пользователя (в обратном вызове `onPressed` и т.д.). Переходите только в ответ на изменения состояния, если требуется некоторая бизнес-логика, чтобы определить, куда переходить.

Полный источник этого рецепта можно найти [здесь](https://gist.github.com/felangel/6bcd4be10c046ceb33eecfeb380135dd).

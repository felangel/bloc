# Рецепты: Доступ к блоку

> В этом рецепте мы рассмотрим, как использовать `BlocProvider`, чтобы сделать блок доступным по всему дереву виджетов. Мы изучим три сценария: локальный доступ, доступ с маршрутом и глобальный доступ.

## Локальный доступ

> В этом примере мы будем использовать `BlocProvider`, чтобы сделать блок доступным для локального поддерева. В этом контексте локальный означает внутри контекста, где нет маршрутов, которые переходят/возвращаются.

### Блок

Для простоты мы будем использовать `Counter` в качестве примера приложения.

Реализация `CounterBloc` будет выглядеть так:

```dart
enum CounterEvent { increment, decrement }

class CounterBloc extends Bloc<CounterEvent, int> {
  @override
  int get initialState => 0;

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.decrement:
        yield currentState - 1;
        break;
      case CounterEvent.increment:
        yield currentState + 1;
        break;
    }
  }
}
```

### UI

У нас будет 3 части нашего интерфейса:

- `App` - виджет корневого приложения
- `CounterPage` - контейнерный виджет, который будет управлять `CounterBloc` и показывает `FloatingActionButtons` для увеличения и уменьшения счетчика.
- `CounterText` - текстовый виджет, который отвечает за отображение текущего `count`.

#### Приложение

```dart
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: BlocProvider(
        create: (BuildContext context) => CounterBloc(),
        child: CounterPage(),
      ),
    );
  }
}
```

Виджет `App` - это `StatelessWidget`, который использует `MaterialApp` и устанавливает наш `CounterPage` в качестве домашнего виджета. Виджет `App` отвечает за создание и закрытие `CounterBloc`, а также делает его доступным для `CounterPage` с помощью `BlocProvider`.

?> **Примечание:** когда мы оборачиваем виджет с помощью `BlocProvider`, мы можем предоставить блок всем виджетам в этом поддереве. В этом случае мы можем получить доступ к `CounterBloc` из виджета `CounterPage` и любых дочерних элементов виджета `CounterPage`, используя `BlocProvider.of<CounterBloc>(context)`.

#### Страница счетчика

```dart
class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final counterBloc = BlocProvider.of<CounterBloc>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Counter')),
      body: Center(
        child: CounterText(),
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                counterBloc.add(CounterEvent.increment);
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: Icon(Icons.remove),
              onPressed: () {
                counterBloc.add(CounterEvent.decrement);
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

Виджет `CounterPage` - это `StatelessWidget`, который обращается к `CounterBloc` через `BuildContext`.

#### Текст счетчика

```dart
class CounterText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CounterBloc, int>(
      builder: (context, count) {
        return Text('$count');
      },
    );
  }
}
```

Виджет `CounterText` использует `BlocBuilder` для ререндеринга себя всякий раз, когда изменяется состояние `CounterBloc`. Мы используем `BlocProvider.of<CounterBloc>(context)`, чтобы получить доступ к предоставленному `CounterBloc` и вернуть виджет `Text` с текущим счетчиком.

Это завершающая часть по доступу к локальному блоку этого рецепта и полный исходный код можно найти [здесь](https://gist.github.com/felangel/20b03abfef694c00038a4ffbcc788c35).

Далее мы рассмотрим, как создать блок для нескольких страниц/маршрутов.

## Доступ по маршруту

> В этом примере мы используем `BlocProvider` для доступа к блоку по маршруту. Когда новый маршрут выставляется, он будет иметь другой `BuildContext`, который больше не имеет ссылки на ранее предоставленные блоки. В результате мы должны обернуть новый маршрут в отдельный `BlocProvider`.

### Блок

Опять же, мы будем использовать `CounterBloc` для простоты.

```dart
enum CounterEvent { increment, decrement }

class CounterBloc extends Bloc<CounterEvent, int> {
  @override
  int get initialState => 0;

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.decrement:
        yield currentState - 1;
        break;
      case CounterEvent.increment:
        yield currentState + 1;
        break;
    }
  }
}
```

### UI

Опять же, у нас будет три части пользовательского интерфейса нашего приложения:

- `App` - виджет корневого приложения
- `HomePage` - контейнерный виджет, который будет управлять `CounterBloc` и показывать `FloatingActionButtons` для увеличения или уменьшения счетчика.
- `CounterPage` - виджет, который отвечает за отображение текущего `count` в качестве отдельного маршрута.

#### Приложение

```dart
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: BlocProvider(
        create: (BuildContext context) => CounterBloc(),
        child: HomePage(),
      ),
    );
  }
}
```

Опять же, наш виджет `App` такой же, как и раньше.

#### Домашняя страница

```dart
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final counterBloc = BlocProvider.of<CounterBloc>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Counter')),
      body: Center(
        child: RaisedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<CounterPage>(
                builder: (context) {
                  return BlocProvider.value(
                    value: counterBloc,
                    child: CounterPage(),
                  );
                },
              ),
            );
          },
          child: Text('Counter'),
        ),
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              heroTag: 0,
              child: Icon(Icons.add),
              onPressed: () {
                counterBloc.add(CounterEvent.increment);
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              heroTag: 1,
              child: Icon(Icons.remove),
              onPressed: () {
                counterBloc.add(CounterEvent.decrement);
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

`HomePage` похож на `CounterPage` в приведенном выше примере, однако вместо рендеринга виджета `CounterText` он рендерит `RaisedButton` в центре, который позволяет пользователю перейти к новому экрану, на котором отображается текущий счетчик.

Когда пользователь касается `RaisedButton`, мы выставляем новый `MaterialPageRoute` и возвращаем `CounterPage`, однако мы оборачиваем `CounterPage` в `BlocProvider`, чтобы сделать текущий экземпляр `CounterBloc` доступным на следующей странице.

!> Очень важно, чтобы в этом случае мы использовали конструктор значений `BlocProvider`, потому что мы предоставляем существующий экземпляр `CounterBloc`. Конструктор значений `BlocProvider` должен использоваться только в тех случаях, когда мы хотим предоставить существующий блок новому поддереву. Кроме того, использование конструктора значений не приведет к автоматическому закрытию блока, что в данном случае является тем, что нам нужно (поскольку нам все еще нужен `CounterBloc` для работы в виджетах предков). Вместо этого мы просто передаем существующий `CounterBloc` новой странице как существующее значение, а не в компоновщике. Это гарантирует, что единственный `BlocProvider` верхнего уровня обрабатывает закрытие `CounterBloc`, когда он больше не нужен.

#### Страница счетчика

```dart
class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Counter'),
      ),
      body: BlocBuilder<CounterBloc, int>(
        builder: (context, count) {
          return Center(
            child: Text('$count'),
          );
        },
      ),
    );
  }
}
```

`CounterPage` - супер простой `StatelessWidget`, который использует `BlocBuilder` для повторного рендеринга виджета `Text` с текущим счетчиком. Как и раньше, мы можем использовать `BlocProvider.of<CounterBloc>(context)` для доступа к `CounterBloc`.

Это все, что есть в этом примере и полный исходный код можно найти [здесь](https://gist.github.com/felangel/92b256270c5567210285526a07b4cf21).

Наконец, мы рассмотрим как сделать блок глобально доступным для дерева виджетов.

## Глобальный доступ

> В этом последнем примере мы продемонстрируем, как сделать экземпляр блока доступным для всего дерева виджетов. Это полезно для конкретных случаев, таких как `AuthenticationBloc` или `ThemeBloc`, потому что это состояние применяется ко всем частям приложения.

### Блок

Как обычно, мы будем использовать `CounterBloc` в качестве нашего примера для простоты.

```dart
enum CounterEvent { increment, decrement }

class CounterBloc extends Bloc<CounterEvent, int> {
  @override
  int get initialState => 0;

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.decrement:
        yield currentState - 1;
        break;
      case CounterEvent.increment:
        yield currentState + 1;
        break;
    }
  }
}
```

### UI

Мы будем следовать той же структуре приложения, что и в примере `Локальный доступ`. В результате у нас будет три части нашего интерфейса:

- `App` - виджет корневого приложения, который управляет глобальным экземпляром нашего `CounterBloc`.
- `CounterPage` - контейнерный виджет, который показывает `FloatingActionButtons` для увеличения или уменьшения счетчика.
- `CounterText` - текстовый виджет, который отвечает за отображение текущего `count`.

#### Приложение

```dart
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => CounterBloc(),
      child: MaterialApp(
        title: 'Flutter Demo',
        home: CounterPage(),
      ),
    );
  }
}
```

Как и в примере с локальным доступом выше, `App` управляет созданием, закрытием и предоставлением `CounterBloc` для поддерева, используя `BlocProvider`. Основное отличие состоит в том, что `MaterialApp` является дочерним элементом `BlocProvider`.

Обертывание всего `MaterialApp` в `BlocProvider` является ключом к тому, чтобы сделать наш экземпляр `CounterBloc` глобально доступным. Теперь мы можем получить доступ к нашему `CounterBloc` из любой точки нашего приложения где у нас есть `BuildContext`, используя `BlocProvider.of<CounterBloc>(context)`

?> **Примечание:** Этот подход также работает, если вы используете `CupertinoApp` или `WidgetsApp`.

#### Страница счетчика

```dart
class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CounterBloc counterBloc = BlocProvider.of<CounterBloc>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Counter')),
      body: Center(
        child: CounterText(),
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                counterBloc.add(CounterEvent.increment);
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: Icon(Icons.remove),
              onPressed: () {
                counterBloc.add(CounterEvent.decrement);
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

`CounterPage` является `StatelessWidget`, потому что ему не нужно управлять своим собственным состоянием. Как мы уже упоминали выше, он использует `BlocProvider.of<CounterBloc>(context)` для доступа к глобальному экземпляру `CounterBloc`.

#### Текст счетчика

```dart
class CounterText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CounterBloc, int>(
      builder: (context, count) {
        return Text('$count');
      },
    );
  }
}
```

Здесь нет ничего нового; виджет `CounterText` такой же, как в первом примере. Это просто `StatelessWidget`, который использует `BlocBuilder` для повторного рендеринга при изменении состояния `CounterBloc` и доступа к глобальному экземпляру `CounterBloc` с помощью `BlocProvider.of<CounterBloc>(context)`.

Это все, что нужно сделать! Полный исходный код можно найти [здесь](https://gist.github.com/felangel/be891e73a7c91cdec9e7d5f035a61d5d).

# Рецепты: Показ SnackBar с BlocListener

> В этом рецепте мы рассмотрим как использовать `BlocListener` для отображения `SnackBar` в ответ на изменение состояния в блоке.

![demo](../assets/gifs/recipes_flutter_snack_bar.gif)

## Блок

Давайте создадим базовый `DataBloc`, который будет обрабатывать `DataEvents` и выводить `DataStates`.

### Событие

Для простоты `DataBloc` будет отвечать только на один `DataEvent`, называемый `FetchData`.

```dart
import 'package:meta/meta.dart';

@immutable
abstract class DataEvent {}

class FetchData extends DataEvent {}
```

### Состояние

`DataBloc` может иметь один из трех разных `DataStates`:

- `Initial` - начальное состояние перед добавлением каких-либо событий
- `Loading` - состояние блока во время асинхронной 'выборки данных'
- `Success` - состояние блока, когда он успешно 'извлек данные'

```dart
import 'package:meta/meta.dart';

@immutable
abstract class DataState {}

class Initial extends DataState {}

class Loading extends DataState {}

class Success extends DataState {}
```

### Блок

`DataBloc` должен выглядеть примерно так:

```dart
import 'package:bloc/bloc.dart';

class DataBloc extends Bloc<DataEvent, DataState> {
  @override
  DataState get initialState => Initial();

  @override
  Stream<DataState> mapEventToState(
    DataEvent event,
  ) async* {
    if (event is FetchData) {
      yield Loading();
      await Future.delayed(Duration(seconds: 2));
      yield Success();
    }
  }
}
```

?> **Примечание:** мы используем `Future.delayed` для имитации задержки.

## UI слой

Теперь давайте посмотрим, как подключить `DataBloc` к виджету и показать `SnackBar` в ответ на состояние `success`.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DataBloc(),
      child: MaterialApp(
        home: Home(),
      ),
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dataBloc = BlocProvider.of<DataBloc>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: BlocListener<DataBloc, DataState>(
        listener: (context, state) {
          if (state is Success) {
            Scaffold.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.green,
                content: Text('Success'),
              ),
            );
          }
        },
        child: BlocBuilder<DataBloc, DataState>(
          builder: (context, state) {
            if (state is Initial) {
              return Center(child: Text('Press the Button'));
            }
            if (state is Loading) {
              return Center(child: CircularProgressIndicator());
            }
            if (state is Success) {
              return Center(child: Text('Success'));
            }
          },
        ),
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            child: Icon(Icons.play_arrow),
            onPressed: () {
              dataBloc.add(FetchData());
            },
          ),
        ],
      ),
    );
  }
}
```

?> Мы используем виджет `BlocListener`, чтобы **что-то делать** в ответ на изменения состояния в `DataBloc`.

?> мы используем виджет `BlocBuilder` для **отрисовки виджетов** в ответ на изменения состояния в нашем `DataBloc`.

!> Мы не должны **НИКОГДА** не должны 'что-то делать' в ответ на изменения состояния в методе `builder` `BlocBuilder` потому, что этот метод может вызываться много раз средой Flutter. Метод `builder` должен быть [чистой функцией](https://en.wikipedia.org/wiki/Pure_function), который просто возвращает виджет в ответ на состояние блока.

Полный исходный код этого рецепта можно найти [здесь](https://gist.github.com/felangel/1e5b2c25b263ad1aa7bbed75d8c76c44).

# Рецепты: Показ SnackBar с BlocListener

> В этом рецепте мы рассмотрим как использовать `BlocListener` для отображения `SnackBar` в ответ на изменение состояния в блоке.

![demo](../assets/gifs/recipes_flutter_snack_bar.gif)

## Блок

Давайте создадим базовый `DataBloc`, который будет обрабатывать `DataEvents` и выводить `DataStates`.

### Событие

Для простоты `DataBloc` будет отвечать только на один `DataEvent`, называемый `FetchData`.

[data_event.dart](../_snippets/recipes_flutter_show_snack_bar/data_event.dart.md ':include')

### Состояние

`DataBloc` может иметь один из трех разных `DataStates`:

- `Initial` - начальное состояние перед добавлением каких-либо событий
- `Loading` - состояние блока во время асинхронной 'выборки данных'
- `Success` - состояние блока, когда он успешно 'извлек данные'

[data_state.dart](../_snippets/recipes_flutter_show_snack_bar/data_state.dart.md ':include')

### Блок

`DataBloc` должен выглядеть примерно так:

[data_bloc.dart](../_snippets/recipes_flutter_show_snack_bar/data_bloc.dart.md ':include')

?> **Примечание:** мы используем `Future.delayed` для имитации задержки.

## UI слой

Теперь давайте посмотрим, как подключить `DataBloc` к виджету и показать `SnackBar` в ответ на состояние `success`.

[main.dart](../_snippets/recipes_flutter_show_snack_bar/main.dart.md ':include')

?> Мы используем виджет `BlocListener`, чтобы **что-то делать** в ответ на изменения состояния в `DataBloc`.

?> мы используем виджет `BlocBuilder` для **отрисовки виджетов** в ответ на изменения состояния в нашем `DataBloc`.

!> Мы не должны **НИКОГДА** не должны 'что-то делать' в ответ на изменения состояния в методе `builder` `BlocBuilder` потому, что этот метод может вызываться много раз средой Flutter. Метод `builder` должен быть [чистой функцией](https://en.wikipedia.org/wiki/Pure_function), который просто возвращает виджет в ответ на состояние блока.

Полный исходный код этого рецепта можно найти [здесь](https://gist.github.com/felangel/1e5b2c25b263ad1aa7bbed75d8c76c44).

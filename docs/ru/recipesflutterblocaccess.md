# Рецепты: Доступ к блоку

> В этом рецепте мы рассмотрим, как использовать `BlocProvider`, чтобы сделать блок доступным по всему дереву виджетов. Мы изучим три сценария: локальный доступ, доступ с маршрутом и глобальный доступ.

## Локальный доступ

> В этом примере мы будем использовать `BlocProvider`, чтобы сделать блок доступным для локального поддерева. В этом контексте локальный означает внутри контекста, где нет маршрутов, которые переходят/возвращаются.

### Блок

Для простоты мы будем использовать `Counter` в качестве примера приложения.

Реализация `CounterBloc` будет выглядеть так:

[counter_bloc.dart](../_snippets/recipes_flutter_bloc_access/counter_bloc.dart.md ':include')

### UI

У нас будет 3 части нашего интерфейса:

- `App` - виджет корневого приложения
- `CounterPage` - контейнерный виджет, который будет управлять `CounterBloc` и показывает `FloatingActionButtons` для увеличения и уменьшения счетчика.
- `CounterText` - текстовый виджет, который отвечает за отображение текущего `count`.

#### Приложение

[main.dart](../_snippets/recipes_flutter_bloc_access/local_access/main.dart.md ':include')

Виджет `App` - это `StatelessWidget`, который использует `MaterialApp` и устанавливает наш `CounterPage` в качестве домашнего виджета. Виджет `App` отвечает за создание и закрытие `CounterBloc`, а также делает его доступным для `CounterPage` с помощью `BlocProvider`.

?> **Примечание:** когда мы оборачиваем виджет с помощью `BlocProvider`, мы можем предоставить блок всем виджетам в этом поддереве. В этом случае мы можем получить доступ к `CounterBloc` из виджета `CounterPage` и любых дочерних элементов виджета `CounterPage`, используя `BlocProvider.of<CounterBloc>(context)`.

#### Страница счетчика

[counter_page.dart](../_snippets/recipes_flutter_bloc_access/local_access/counter_page.dart.md ':include')

Виджет `CounterPage` - это `StatelessWidget`, который обращается к `CounterBloc` через `BuildContext`.

#### Текст счетчика

[counter_text.dart](../_snippets/recipes_flutter_bloc_access/local_access/counter_text.dart.md ':include')

Виджет `CounterText` использует `BlocBuilder` для ререндеринга себя всякий раз, когда изменяется состояние `CounterBloc`. Мы используем `BlocProvider.of<CounterBloc>(context)`, чтобы получить доступ к предоставленному `CounterBloc` и вернуть виджет `Text` с текущим счетчиком.

Это завершающая часть по доступу к локальному блоку этого рецепта и полный исходный код можно найти [здесь](https://gist.github.com/felangel/20b03abfef694c00038a4ffbcc788c35).

Далее мы рассмотрим, как создать блок для нескольких страниц/маршрутов.

## Анонимный доступ по маршруту

> В этом примере мы используем `BlocProvider` для доступа к блоку по маршруту. Когда новый маршрут выставляется, он будет иметь другой `BuildContext`, который больше не имеет ссылки на ранее предоставленные блоки. В результате мы должны обернуть новый маршрут в отдельный `BlocProvider`.

### Блок

Опять же, мы будем использовать `CounterBloc` для простоты.

[counter_bloc.dart](../_snippets/recipes_flutter_bloc_access/counter_bloc.dart.md ':include')

### UI

Опять же, у нас будет три части пользовательского интерфейса нашего приложения:

- `App` - виджет корневого приложения
- `HomePage` - контейнерный виджет, который будет управлять `CounterBloc` и показывать `FloatingActionButtons` для увеличения или уменьшения счетчика.
- `CounterPage` - виджет, который отвечает за отображение текущего `count` в качестве отдельного маршрута.

#### Приложение

[main.dart](../_snippets/recipes_flutter_bloc_access/anonymous_route_access/main.dart.md ':include')

Опять же, наш виджет `App` такой же, как и раньше.

#### Домашняя страница

[home_page.dart](../_snippets/recipes_flutter_bloc_access/anonymous_route_access/home_page.dart.md ':include')

`HomePage` похож на `CounterPage` в приведенном выше примере, однако вместо рендеринга виджета `CounterText` он рендерит `RaisedButton` в центре, который позволяет пользователю перейти к новому экрану, на котором отображается текущий счетчик.

Когда пользователь касается `RaisedButton`, мы выставляем новый `MaterialPageRoute` и возвращаем `CounterPage`, однако мы оборачиваем `CounterPage` в `BlocProvider`, чтобы сделать текущий экземпляр `CounterBloc` доступным на следующей странице.

!> Очень важно, чтобы в этом случае мы использовали конструктор значений `BlocProvider`, потому что мы предоставляем существующий экземпляр `CounterBloc`. Конструктор значений `BlocProvider` должен использоваться только в тех случаях, когда мы хотим предоставить существующий блок новому поддереву. Кроме того, использование конструктора значений не приведет к автоматическому закрытию блока, что в данном случае является тем, что нам нужно (поскольку нам все еще нужен `CounterBloc` для работы в виджетах предков). Вместо этого мы просто передаем существующий `CounterBloc` новой странице как существующее значение, а не в компоновщике. Это гарантирует, что единственный `BlocProvider` верхнего уровня обрабатывает закрытие `CounterBloc`, когда он больше не нужен.

#### Страница счетчика

[counter_page.dart](../_snippets/recipes_flutter_bloc_access/anonymous_route_access/counter_page.dart.md ':include')

`CounterPage` - супер простой `StatelessWidget`, который использует `BlocBuilder` для повторного рендеринга виджета `Text` с текущим счетчиком. Как и раньше, мы можем использовать `BlocProvider.of<CounterBloc>(context)` для доступа к `CounterBloc`.

Это все, что есть в этом примере и полный исходный код можно найти [здесь](https://gist.github.com/felangel/92b256270c5567210285526a07b4cf21).

Далее мы рассмотрим, как настроить блок только для одного или нескольких именованных маршрутов.

## Именованный доступ к маршруту

> В этом примере мы будем использовать `BlocProvider` для доступа к блоку по нескольким именованным маршрутам. Когда проталкивается новый именованный маршрут он будет иметь другой `BuildContext` (как и прежде), который больше не имеет ссылки на ранее предоставленные блоки. В этом случае мы собираемся управлять блоками, которые мы хотим охватить в родительском виджете и выборочно предоставлять их маршрутам, которые должны иметь доступ.

### Блок

Опять же, мы будем использовать `CounterBloc` для простоты.

[counter_bloc.dart](../_snippets/recipes_flutter_bloc_access/counter_bloc.dart.md ':include')

### UI

Опять же, у нас будет три части пользовательского интерфейса нашего приложения:

- App: виджет корневого приложения
- HomePage: контейнерный виджет, который будет управлять `CounterBloc` и выставляет`FloatingActionButtons` для «приращения» и «уменьшения» счетчика.
- CounterPage: виджет, который отвечает за отображение текущего `count` в качестве отдельного маршрута.

#### App

[main.dart](../_snippets/recipes_flutter_bloc_access/named_route_access/main.dart.md ':include')

Наш виджет `App` отвечает за управление экземпляром `CounterBloc`, который мы будем предоставлять корневым (`/`) и (`/ counter`) маршрутам.

!> Важно понимать, что, поскольку \_AppState создает экземпляр `CounterBloc`, он также должен закрывать его в переопределении `dispose`.

!> Мы используем `BlocProvider.value` при предоставлении экземпляра `CounterBloc` для маршрутов, потому что мы не хотим, чтобы `BlocProvider` обрабатывал удаление блока (поскольку за это отвечает `_AppState`).

#### HomePage

[home_page.dart](../_snippets/recipes_flutter_bloc_access/named_route_access/home_page.dart.md ':include')

`HomePage` похож на `CounterPage` в приведенном выше примере, однако вместо рендеринга виджета `CounterText` он рендерит `RaisedButton` в центре, который позволяет пользователю перейти к новому экрану, на котором отображается текущий счетчик.

Когда пользователь нажимает на `RaisedButton`, мы переходим на новый именованный маршрут, чтобы перейти на `/counter`, который мы определили выше.

#### CounterPage

[counter_page.dart](../_snippets/recipes_flutter_bloc_access/named_route_access/counter_page.dart.md ':include')

CounterPage - супер простой `StatelessWidget`, который использует `BlocBuilder` для повторного рендеринга виджета `Text` с текущим счетчиком. Как и раньше, мы можем использовать `BlocProvider.of <CounterBloc> (context)` для доступа к `CounterBloc`.

Это все, что есть в этом примере и полный источник информации можно найти здесь [https://gist.github.com/felangel/8d143cf3b7da38d80de4bcc6f65e9831).

Наконец, мы рассмотрим как сделать блок глобально доступным для дерева виджетов.

## Глобальный доступ

> В этом последнем примере мы продемонстрируем, как сделать экземпляр блока доступным для всего дерева виджетов. Это полезно для конкретных случаев, таких как `AuthenticationBloc` или `ThemeBloc`, потому что это состояние применяется ко всем частям приложения.

### Блок

Как обычно, мы будем использовать `CounterBloc` в качестве нашего примера для простоты.

[counter_bloc.dart](../_snippets/recipes_flutter_bloc_access/counter_bloc.dart.md ':include')

### UI

Мы будем следовать той же структуре приложения, что и в примере `Локальный доступ`. В результате у нас будет три части нашего интерфейса:

- `App` - виджет корневого приложения, который управляет глобальным экземпляром нашего `CounterBloc`.
- `CounterPage` - контейнерный виджет, который показывает `FloatingActionButtons` для увеличения или уменьшения счетчика.
- `CounterText` - текстовый виджет, который отвечает за отображение текущего `count`.

#### Приложение

[main.dart](../_snippets/recipes_flutter_bloc_access/global_access/main.dart.md ':include')

Как и в примере с локальным доступом выше, `App` управляет созданием, закрытием и предоставлением `CounterBloc` для поддерева, используя `BlocProvider`. Основное отличие состоит в том, что `MaterialApp` является дочерним элементом `BlocProvider`.

Обертывание всего `MaterialApp` в `BlocProvider` является ключом к тому, чтобы сделать наш экземпляр `CounterBloc` глобально доступным. Теперь мы можем получить доступ к нашему `CounterBloc` из любой точки нашего приложения где у нас есть `BuildContext`, используя `BlocProvider.of<CounterBloc>(context)`

?> **Примечание:** Этот подход также работает, если вы используете `CupertinoApp` или `WidgetsApp`.

#### Страница счетчика

[counter_page.dart](../_snippets/recipes_flutter_bloc_access/global_access/counter_page.dart.md ':include')

`CounterPage` является `StatelessWidget`, потому что ему не нужно управлять своим собственным состоянием. Как мы уже упоминали выше, он использует `BlocProvider.of<CounterBloc>(context)` для доступа к глобальному экземпляру `CounterBloc`.

#### Текст счетчика

[counter_text.dart](../_snippets/recipes_flutter_bloc_access/global_access/counter_text.dart.md ':include')

Здесь нет ничего нового; виджет `CounterText` такой же, как в первом примере. Это просто `StatelessWidget`, который использует `BlocBuilder` для повторного рендеринга при изменении состояния `CounterBloc` и доступа к глобальному экземпляру `CounterBloc` с помощью `BlocProvider.of<CounterBloc>(context)`.

Это все, что нужно сделать! Полный исходный код можно найти [здесь](https://gist.github.com/felangel/be891e73a7c91cdec9e7d5f035a61d5d).

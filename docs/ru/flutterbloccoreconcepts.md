# Flutter Bloc основные понятия

?> Пожалуйста, внимательно прочитайте и поймите следующие разделы, прежде чем работать с [flutter_bloc](https://pub.dev/packages/flutter_bloc).

## Bloc Widgets (Блок виджетов)

### BlocBuilder (блок строитель)

**BlocBuilder** - это виджет `Flutter`, который требует функции `Bloc` и `builder`. `BlocBuilder` обрабатывает создание виджета в ответ на новые состояния. `BlocBuilder` очень похож на `StreamBuilder`, но имеет более простой API для уменьшения необходимого количества стандартного кода. Функция `builder` потенциально может быть вызвана много раз и должна быть [чистой функцией](https://en.wikipedia.org/wiki/Pure_function), которая возвращает виджет в ответ на состояние.

Смотрите `BlocListener`, если вы хотите что-то делать в ответ на изменения состояния, такие как навигация, отображение диалогового окна и т.д.

Если параметр `bloc` пропущен, `BlocBuilder` автоматически выполнит поиск, используя `BlocProvider` и текущий `BuildContext`.

```dart
BlocBuilder<BlocA, BlocAState>(
  builder: (context, state) {
    // return widget here based on BlocA's state
  }
)
```

Указывайте `bloc` только в том случае, если вы хотите предоставить `bloc`, ограниченый одним виджетом и недоступным через родительский `BlocProvider` и текущий `BuildContext`.

```dart
BlocBuilder<BlocA, BlocAState>(
  bloc: blocA, // provide the local bloc instance
  builder: (context, state) {
    // return widget here based on BlocA's state
  }
)
```

Если вам нужен детальный контроль над тем, когда вызывается функция компоновщика, вы можете предоставить необязательное условие `condition` для `BlocBuilder`. Условие принимает предыдущее и текущее состояния блока и возвращает логическое значение. Если `condition` возвращает true, `builder` будет вызываться с помощью `state` и виджет перестраивается. Если `condition` возвращает false, `builder` не будет вызван со `state` и перестройка не произойдет.

```dart
BlocBuilder<BlocA, BlocAState>(
  condition: (previousState, state) {
    // return true/false to determine whether or not
    // to rebuild the widget with state
  },
  builder: (context, state) {
    // return widget here based on BlocA's state
  }
)
```

### BlocProvider (Блок поставщик)

**BlocProvider** - это виджет Flutter, который предоставляет блок своим дочерним элементам через `BlocProvider.of<T>(context)`. Он используется как виджет внедрения зависимостей (DI), так что один экземпляр блока может быть предоставлен нескольким виджетам в поддереве.

В большинстве случаев `BlocProvider` следует использовать для создания новых блоков, которые будут доступны остальному поддереву. В этом случае, поскольку `BlocProvider` отвечает за создание блока, он автоматически обрабатывает закрытие блока.

```dart
BlocProvider(
  create: (BuildContext context) => BlocA(),
  child: ChildA(),
);
```

В некоторых случаях `BlocProvider` может использоваться для предоставления существующего блока новой части дерева виджетов. Это будет наиболее часто использоваться, когда существующий блок должен быть доступен для нового маршрута. В этом случае `BlocProvider` не будет автоматически закрывать блок, поскольку он его не создавал.

```dart
BlocProvider.value(
  value: BlocProvider.of<BlocA>(context),
  child: ScreenA(),
);
```

затем из `ChildA` или `ScreenA` мы можем получить `BlocA` с помощью:

```dart
BlocProvider.of<BlocA>(context)
```

### MultiBlocProvider (Мульти блок поставщик)

**MultiBlocProvider** is a Flutter widget that merges multiple `BlocProvider` widgets into one.
`MultiBlocProvider` improves the readability and eliminates the need to nest multiple `BlocProviders`.
By using `MultiBlocProvider` we can go from:

**MultiBlocProvider** - это виджет Flutter, который объединяет несколько виджетов `BlocProvider` в один.
`MultiBlocProvider` улучшает читаемость и устраняет необходимость вложения нескольких `BlocProviders`.
Используя `MultiBlocProvider`, мы можем перейти от:

```dart
BlocProvider<BlocA>(
  create: (BuildContext context) => BlocA(),
  child: BlocProvider<BlocB>(
    create: (BuildContext context) => BlocB(),
    child: BlocProvider<BlocC>(
      create: (BuildContext context) => BlocC(),
      child: ChildA(),
    )
  )
)
```

к:

```dart
MultiBlocProvider(
  providers: [
    BlocProvider<BlocA>(
      create: (BuildContext context) => BlocA(),
    ),
    BlocProvider<BlocB>(
      create: (BuildContext context) => BlocB(),
    ),
    BlocProvider<BlocC>(
      create: (BuildContext context) => BlocC(),
    ),
  ],
  child: ChildA(),
)
```

### BlocListener (Блок слушатель)

**BlocListener** - это виджет Flutter, который принимает `BlocWidgetListener` и необязательный `Bloc` и вызывает `listener` в ответ на изменения состояния в блоке. Его следует использовать для функциональности, которая должна выполняться один раз для каждого изменения состояния, например для навигации, отображения `SnackBar`, отображения `Dialog` и т.д.

`listener` вызывается только один раз для каждого изменения состояния (**НЕ** включая `initialState`) в отличие от `builder` в `BlocBuilder` и является функцией `void`.

Если параметр `bloc` пропущен, `BlocListener` автоматически выполнит поиск, используя `BlocProvider` и текущий `BuildContext`.

```dart
BlocListener<BlocA, BlocAState>(
  listener: (context, state) {
    // do stuff here based on BlocA's state
  },
  child: Container(),
)
```

Указывайте `bloc` только в том случае, если вы хотите предоставить `bloc`, который в ином случае был бы недоступен через `BlocProvider` и текущий `BuildContext`.

```dart
BlocListener<BlocA, BlocAState>(
  bloc: blocA,
  listener: (context, state) {
    // do stuff here based on BlocA's state
  }
)
```

Если вам нужен детальный контроль над тем, когда вызывается функция слушателя, вы можете предоставить необязательное условие для `BlocListener`. Условие принимает предыдущее состояние `bloc` и текущее состояние `bloc` и возвращает логическое значение. Если `condition` возвращает true, `listener` будет вызван со `state`. Если `condition` возвращает false, `listener` не будет вызван со `state`.

```dart
BlocListener<BlocA, BlocAState>(
  condition: (previousState, state) {
    // return true/false to determine whether or not
    // to call listener with state
  },
  listener: (context, state) {
    // do stuff here based on BlocA's state
  }
  child: Container(),
)
```

### MultiBlocListener (Мульти блок слушатель)

**MultiBlocListener** - это виджет Flutter, который объединяет несколько виджетов `BlocListener` в один.
`MultiBlocListener` улучшает читаемость и устраняет необходимость вложения нескольких `BlocListener`.
Используя `MultiBlocListener`, мы можем перейти от:

```dart
BlocListener<BlocA, BlocAState>(
  listener: (context, state) {},
  child: BlocListener<BlocB, BlocBState>(
    listener: (context, state) {},
    child: BlocListener<BlocC, BlocCState>(
      listener: (context, state) {},
      child: ChildA(),
    ),
  ),
)
```

к:

```dart
MultiBlocListener(
  listeners: [
    BlocListener<BlocA, BlocAState>(
      listener: (context, state) {},
    ),
    BlocListener<BlocB, BlocBState>(
      listener: (context, state) {},
    ),
    BlocListener<BlocC, BlocCState>(
      listener: (context, state) {},
    ),
  ],
  child: ChildA(),
)
```

### BlocConsumer (Блок потребитель)

**BlocConsumer** предоставляет `builder` и `listener` чтобы реагировать на новые состояния. `BlocConsumer` аналогичен вложенным `BlocListener` и `BlocBuilder`, но уменьшает необходимое количество шаблонов. `BlocConsumer` следует использовать только тогда, когда необходимо не только перестроить пользовательский интерфейс, но и выполнить другие действия на изменения состояния в блоке. `BlocConsumer` принимает обязательные `BlocWidgetBuilder` и `BlocWidgetListener`, а также необязательный `bloc`, `BlocBuilderCondition` и `BlocListenerCondition`.

Если параметр `bloc` не указан, `BlocConsumer` автоматически выполнит поиск, используя
`BlocProvider` и текущий `BuildContext`.

```dart
BlocConsumer<BlocA, BlocAState>(
  listener: (context, state) {
    // do stuff here based on BlocA's state
  },
  builder: (context, state) {
    // return widget here based on BlocA's state
  }
)
```

Необязательные `listenWhen` и `buildWhen` могут быть реализованы для более детального управления при вызове `listener` и `builder`. `ListenWhen` и `buildWhen` будут вызываться при каждом изменении `bloc`. Каждый из них принимает предыдущий `state` и текущий `state` и должен возвращать `bool`, который определяет, будет ли вызываться функция `builder` и/или `listener`. Предыдущий `state` будет инициализирован как `state` блока когда инициализируется `BlocConsumer`. `listenWhen` и `buildWhen` являются необязательными и, если они не реализованы, по умолчанию они будут иметь значение `true`.

```dart
BlocConsumer<BlocA, BlocAState>(
  listenWhen: (previous, current) {
    // return true/false to determine whether or not
    // to invoke listener with state
  },
  listener: (context, state) {
    // do stuff here based on BlocA's state
  },
  buildWhen: (previous, current) {
    // return true/false to determine whether or not
    // to rebuild the widget with state
  },
  builder: (context, state) {
    // return widget here based on BlocA's state
  }
)
```

### RepositoryProvider (Постащик хранилища)

**RepositoryProvider** - это виджет Flutter, который предоставляет хранилище своим дочерним элементам через `RepositoryProvider.of<T>(context)`. Он используется в качестве виджета внедрения зависимостей (DI) так, что один экземпляр репозитория может быть предоставлен нескольким виджетам в поддереве. `BlocProvider` должен использоваться для предоставления блоков, тогда как `RepositoryProvider` должен использоваться только для репозиториев.

```dart
RepositoryProvider(
  builder: (context) => RepositoryA(),
  child: ChildA(),
);
```

затем из `ChildA` мы можем получить экземпляр `Repository` с помощью:

```dart
RepositoryProvider.of<RepositoryA>(context)
```

### MultiRepositoryProvider (Мульти поставщик хранилищ)

**MultiRepositoryProvider** - это виджет Flutter, который объединяет несколько виджетов `RepositoryProvider` в один. `MultiRepositoryProvider` улучшает читаемость и устраняет необходимость вложения нескольких `RepositoryProvider`.

Используя `MultiRepositoryProvider`, мы можем перейти от:

```dart
RepositoryProvider<RepositoryA>(
  builder: (context) => RepositoryA(),
  child: RepositoryProvider<RepositoryB>(
    builder: (context) => RepositoryB(),
    child: RepositoryProvider<RepositoryC>(
      builder: (context) => RepositoryC(),
      child: ChildA(),
    )
  )
)
```

к:

```dart
MultiRepositoryProvider(
  providers: [
    RepositoryProvider<RepositoryA>(
      builder: (context) => RepositoryA(),
    ),
    RepositoryProvider<RepositoryB>(
      builder: (context) => RepositoryB(),
    ),
    RepositoryProvider<RepositoryC>(
      builder: (context) => RepositoryC(),
    ),
  ],
  child: ChildA(),
)
```

## Использование

Давайте посмотрим, как использовать `BlocBuilder` для подключения виджета `CounterPage` к `CounterBloc`.

### counter_bloc.dart

```dart
enum CounterEvent { increment, decrement }

class CounterBloc extends Bloc<CounterEvent, int> {
  @override
  int get initialState => 0;

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.decrement:
        yield state - 1;
        break;
      case CounterEvent.increment:
        yield state + 1;
        break;
    }
  }
}
```

### counter_page.dart

```dart
class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CounterBloc counterBloc = BlocProvider.of<CounterBloc>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Counter')),
      body: BlocBuilder<CounterBloc, int>(
        builder: (context, count) {
          return Center(
            child: Text(
              '$count',
              style: TextStyle(fontSize: 24.0),
            ),
          );
        },
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

На данный момент мы успешно отделили наш уровень представления от уровня бизнес-логики. Обратите внимание, что виджет `CounterPage` ничего не знает о том что происходит, когда пользователь нажимает кнопки. Виджет просто сообщает `CounterBloc`, что пользователь нажал кнопку увеличения или уменьшения.

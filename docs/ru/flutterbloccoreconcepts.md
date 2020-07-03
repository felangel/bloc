# Flutter Bloc основные понятия

?> Пожалуйста, внимательно прочитайте и поймите следующие разделы, прежде чем работать с [flutter_bloc](https://pub.dev/packages/flutter_bloc).

## Bloc Widgets (Блок виджетов)

### BlocBuilder (блок строитель)

**BlocBuilder** - это виджет `Flutter`, который требует функции `Bloc` и `builder`. `BlocBuilder` обрабатывает создание виджета в ответ на новые состояния. `BlocBuilder` очень похож на `StreamBuilder`, но имеет более простой API для уменьшения необходимого количества стандартного кода. Функция `builder` потенциально может быть вызвана много раз и должна быть [чистой функцией](https://en.wikipedia.org/wiki/Pure_function), которая возвращает виджет в ответ на состояние.

Смотрите `BlocListener`, если вы хотите что-то делать в ответ на изменения состояния, такие как навигация, отображение диалогового окна и т.д.

Если параметр `bloc` пропущен, `BlocBuilder` автоматически выполнит поиск, используя `BlocProvider` и текущий `BuildContext`.

[bloc_builder.dart](../_snippets/flutter_bloc_core_concepts/bloc_builder.dart.md ':include')

Указывайте `bloc` только в том случае, если вы хотите предоставить `bloc`, ограниченый одним виджетом и недоступным через родительский `BlocProvider` и текущий `BuildContext`.

[bloc_builder.dart](../_snippets/flutter_bloc_core_concepts/bloc_builder_explicit_bloc.dart.md ':include')

Если вам нужен детальный контроль над тем, когда вызывается функция компоновщика, вы можете предоставить необязательное условие `buildWhen` для `BlocBuilder`. Условие принимает предыдущее и текущее состояния блока и возвращает логическое значение. Если `buildWhen` возвращает true, `builder` будет вызываться с помощью `state` и виджет перестраивается. Если `buildWhen` возвращает false, `builder` не будет вызван со `state` и перестройка не произойдет.

[bloc_builder.dart](../_snippets/flutter_bloc_core_concepts/bloc_builder_condition.dart.md ':include')

### BlocProvider (Блок поставщик)

**BlocProvider** - это виджет Flutter, который предоставляет блок своим дочерним элементам через `BlocProvider.of<T>(context)`. Он используется как виджет внедрения зависимостей (DI), так что один экземпляр блока может быть предоставлен нескольким виджетам в поддереве.

В большинстве случаев `BlocProvider` следует использовать для создания новых блоков, которые будут доступны остальному поддереву. В этом случае, поскольку `BlocProvider` отвечает за создание блока, он автоматически обрабатывает закрытие блока.

[bloc_provider.dart](../_snippets/flutter_bloc_core_concepts/bloc_provider.dart.md ':include')

В некоторых случаях `BlocProvider` может использоваться для предоставления существующего блока новой части дерева виджетов. Это будет наиболее часто использоваться, когда существующий блок должен быть доступен для нового маршрута. В этом случае `BlocProvider` не будет автоматически закрывать блок, поскольку он его не создавал.

[bloc_provider.dart](../_snippets/flutter_bloc_core_concepts/bloc_provider_value.dart.md ':include')

затем из `ChildA` или `ScreenA` мы можем получить `BlocA` с помощью:

[bloc_provider.dart](../_snippets/flutter_bloc_core_concepts/bloc_provider_lookup.dart.md ':include')

### MultiBlocProvider (Мульти блок поставщик)

**MultiBlocProvider** - это виджет Flutter, который объединяет несколько виджетов `BlocProvider` в один.
`MultiBlocProvider` улучшает читаемость и устраняет необходимость вложения нескольких `BlocProviders`.
Используя `MultiBlocProvider`, мы можем перейти от:

[bloc_provider.dart](../_snippets/flutter_bloc_core_concepts/nested_bloc_provider.dart.md ':include')

к:

[multi_bloc_provider.dart](../_snippets/flutter_bloc_core_concepts/multi_bloc_provider.dart.md ':include')

### BlocListener (Блок слушатель)

**BlocListener** - это виджет Flutter, который принимает `BlocWidgetListener` и необязательный `Bloc` и вызывает `listener` в ответ на изменения состояния в блоке. Его следует использовать для функциональности, которая должна выполняться один раз для каждого изменения состояния, например для навигации, отображения `SnackBar`, отображения `Dialog` и т.д.

`listener` вызывается только один раз для каждого изменения состояния (**НЕ** включая `initialState`) в отличие от `builder` в `BlocBuilder` и является функцией `void`.

Если параметр `bloc` пропущен, `BlocListener` автоматически выполнит поиск, используя `BlocProvider` и текущий `BuildContext`.

[bloc_listener.dart](../_snippets/flutter_bloc_core_concepts/bloc_listener.dart.md ':include')

Указывайте `bloc` только в том случае, если вы хотите предоставить `bloc`, который в ином случае был бы недоступен через `BlocProvider` и текущий `BuildContext`.

[bloc_listener.dart](../_snippets/flutter_bloc_core_concepts/bloc_listener_explicit_bloc.dart.md ':include')

Если вам нужен детальный контроль над тем, когда вызывается функция слушателя, вы можете предоставить необязательное условие для `BlocListener`. Условие принимает предыдущее состояние `bloc` и текущее состояние `bloc` и возвращает логическое значение. Если `listenWhen` возвращает true, `listener` будет вызван со `state`. Если `listenWhen` возвращает false, `listener` не будет вызван со `state`.

[bloc_listener.dart](../_snippets/flutter_bloc_core_concepts/bloc_listener_condition.dart.md ':include')

### MultiBlocListener (Мульти блок слушатель)

**MultiBlocListener** - это виджет Flutter, который объединяет несколько виджетов `BlocListener` в один.
`MultiBlocListener` улучшает читаемость и устраняет необходимость вложения нескольких `BlocListener`.
Используя `MultiBlocListener`, мы можем перейти от:

[bloc_listener.dart](../_snippets/flutter_bloc_core_concepts/nested_bloc_listener.dart.md ':include')

к:

[multi_bloc_listener.dart](../_snippets/flutter_bloc_core_concepts/multi_bloc_listener.dart.md ':include')

### BlocConsumer (Блок потребитель)

**BlocConsumer** предоставляет `builder` и `listener` чтобы реагировать на новые состояния. `BlocConsumer` аналогичен вложенным `BlocListener` и `BlocBuilder`, но уменьшает необходимое количество шаблонов. `BlocConsumer` следует использовать только тогда, когда необходимо не только перестроить пользовательский интерфейс, но и выполнить другие действия на изменения состояния в блоке. `BlocConsumer` принимает обязательные `BlocWidgetBuilder` и `BlocWidgetListener`, а также необязательный `bloc`, `BlocBuilderCondition` и `BlocListenerCondition`.

Если параметр `bloc` не указан, `BlocConsumer` автоматически выполнит поиск, используя
`BlocProvider` и текущий `BuildContext`.

[bloc_consumer.dart](../_snippets/flutter_bloc_core_concepts/bloc_consumer.dart.md ':include')

Необязательные `listenWhen` и `buildWhen` могут быть реализованы для более детального управления при вызове `listener` и `builder`. `ListenWhen` и `buildWhen` будут вызываться при каждом изменении `bloc`. Каждый из них принимает предыдущий `state` и текущий `state` и должен возвращать `bool`, который определяет, будет ли вызываться функция `builder` и/или `listener`. Предыдущий `state` будет инициализирован как `state` блока когда инициализируется `BlocConsumer`. `listenWhen` и `buildWhen` являются необязательными и, если они не реализованы, по умолчанию они будут иметь значение `true`.

[bloc_consumer.dart](../_snippets/flutter_bloc_core_concepts/bloc_consumer_condition.dart.md ':include')

### RepositoryProvider (Поставщик хранилища)

**RepositoryProvider** - это виджет Flutter, который предоставляет хранилище своим дочерним элементам через `RepositoryProvider.of<T>(context)`. Он используется в качестве виджета внедрения зависимостей (DI) так, что один экземпляр репозитория может быть предоставлен нескольким виджетам в поддереве. `BlocProvider` должен использоваться для предоставления блоков, тогда как `RepositoryProvider` должен использоваться только для репозиториев.

[repository_provider.dart](../_snippets/flutter_bloc_core_concepts/repository_provider.dart.md ':include')

затем из `ChildA` мы можем получить экземпляр `Repository` с помощью:

[repository_provider.dart](../_snippets/flutter_bloc_core_concepts/repository_provider_lookup.dart.md ':include')

### MultiRepositoryProvider (Мульти поставщик хранилищ)

**MultiRepositoryProvider** - это виджет Flutter, который объединяет несколько виджетов `RepositoryProvider` в один. `MultiRepositoryProvider` улучшает читаемость и устраняет необходимость вложения нескольких `RepositoryProvider`.

Используя `MultiRepositoryProvider`, мы можем перейти от:

[repository_provider.dart](../_snippets/flutter_bloc_core_concepts/nested_repository_provider.dart.md ':include')

к:

[multi_repository_provider.dart](../_snippets/flutter_bloc_core_concepts/multi_repository_provider.dart.md ':include')

## Использование

Давайте посмотрим, как использовать `BlocBuilder` для подключения виджета `CounterPage` к `CounterBloc`.

### counter_bloc.dart

[counter_bloc.dart](../_snippets/flutter_bloc_core_concepts/counter_bloc.dart.md ':include')

### counter_page.dart

[counter_page.dart](../_snippets/flutter_bloc_core_concepts/counter_page.dart.md ':include')

На данный момент мы успешно отделили наш уровень представления от уровня бизнес-логики. Обратите внимание, что виджет `CounterPage` ничего не знает о том что происходит, когда пользователь нажимает кнопки. Виджет просто сообщает `CounterBloc`, что пользователь нажал кнопку увеличения или уменьшения.

# Flutter задачи

![advanced](https://img.shields.io/badge/level-advanced-red.svg)

> В следующем руководстве мы собираемся создать приложение Todos во Flutter с использованием библиотеки Bloc.

![demo](../assets/gifs/flutter_todos.gif)

## Настройка

Мы начнем с создания нового проекта Flutter

[script](../_snippets/flutter_todos_tutorial/flutter_create.sh.md ':include')

Сначала нам нужно заменить содержимое файла `pubspec.yaml` на:

[pubspec.yaml](../_snippets/flutter_todos_tutorial/pubspec.yaml.md ':include')

а затем установить все наши зависимости

[script](../_snippets/flutter_todos_tutorial/flutter_packages_get.sh.md ':include')

?> **Примечание:** Мы переопределяем некоторые зависимости, потому что собираемся повторно использовать их из [Образцов архитектуры Flutter Брайана Игана](https://github.com/brianegan/flutter_architecture_samples).

## Ключи приложения

Прежде чем мы перейдем к коду приложения, давайте создадим `flutter_todos_keys.dart`. Этот файл будет содержать ключи, которые мы будем использовать для уникальной идентификации важных виджетов. Позже мы можем написать тесты, которые находят виджеты на основе ключей.

[flutter_todos_keys.dart](../_snippets/flutter_todos_tutorial/flutter_todos_keys.dart.md ':include')

Мы будем ссылаться на эти ключи в оставшейся части руководства.

?> **Примечание:** Вы можете проверить интеграционные тесты для приложения [здесь](https://github.com/brianegan/flutter_architecture_samples/tree/master/integration_tests). Вы также можете проверить тесты модулей и виджетов [здесь](https://github.com/brianegan/flutter_architecture_samples/tree/master/bloc_library/test).

## Локализация

Последнее, что мы затронем прежде чем углубляться в само приложение - это локализация. Создайте `localization.dart` и мы создадим основу для мультиязычной поддержки.

[localization.dart](../_snippets/flutter_todos_tutorial/localization.dart.md ':include')

Теперь мы можем импортировать и предоставить `FlutterBlocLocalizationsDelegate` нашему `MaterialApp`(далее в этом руководстве).

Для получения дополнительной информации о локализации ознакомьтесь с [официальными документами по Flutter](https://flutter.dev/docs/development/accessibility-and-localization/internationalization).

## Todos хранилище

В этом руководстве мы не будем вдаваться в подробности реализации `TodosRepository`, потому что это уже было реализовано [Brian Egan](https://github.com/brianegan) и является общим для всех [примеров архитектуры Todo](https://github.com/brianegan/flutter_architecture_samples). На высоком уровне `TodosRepository` представит метод для `loadTodos` и `saveTodos`. Это почти все, что нам нужно знать, поэтому в оставшейся части урока мы сосредоточимся на слоях `Bloc` и `Presentation`.

## Todos блок

> `TodosBloc` будет отвечать за преобразование `TodosEvents` в `TodosStates` и будет управлять списком задач.

### Модель

Первое, что нам нужно сделать, это определить нашу модель `Todo`. Каждое задание должно иметь идентификатор, задачу, необязательную заметку и необязательный флаг завершения.

Давайте создадим каталог `models` и создадим внутри файл `todo.dart`.

[todo.dart](../_snippets/flutter_todos_tutorial/todo.dart.md ':include')

?> **Примечание:** Мы используем пакет [Equatable](https://pub.dev/packages/equatable), чтобы мы могли сравнивать экземпляры `Todos` без необходимости вручную переопределять `==` и `hashCode`.

Далее нам нужно создать `TodosState`, который получит наш уровень представления.

### Состояния

Давайте создадим `blocs/todos/todos_state.dart` и определим различные состояния, которые нам нужно обработать.

Мы будем реализовывать три состояния:

- `TodosLoadInProgress` - состояние, когда наше приложение выбирает задачи из репозитория.
- `TodosLoadSuccess` - состояние нашего приложения после успешной загрузки задач.
- `TodosLoadFailure` - состояние нашего приложения, если задачи не были успешно загружены.

[todos_state.dart](../_snippets/flutter_todos_tutorial/todos_state.dart.md ':include')

Далее, давайте реализуем события, которые нам нужно будет обработать.

### События

События, которые нам нужно обработать в нашем `TodosBloc`:

- `TodosLoaded` - сообщает блоку, что ему нужно загрузить задачи из `TodosRepository`.
- `TodoAdded` - сообщает блоку, что ему нужно добавить новую задачу в список задач.
- `TodoUpdated` - сообщает блоку, что ему нужно обновить существующую задачу.
- `TodoDeleted` - сообщает блоку, что ему нужно удалить существующую задачу.
- `ClearCompleted` - сообщает блоку, что ему нужно удалить все выполненные задачи.
- `ToggleAll` - сообщает блоку, что он должен переключить состояние завершения для всех задач.

Создайте `blocs/todos/todos_event.dart` и давайте реализуем события, которые мы описали выше.

[todos_event.dart](../_snippets/flutter_todos_tutorial/todos_event.dart.md ':include')

Теперь, когда у нас реализованы `TodosStates` и `TodosEvents`, мы можем реализовать наш `TodosBloc`.

### Блок

Давайте создадим `blocs/todos/todos_bloc.dart` и начнем! Нам просто нужно реализовать `initialState` и `mapEventToState`.

[todos_bloc.dart](../_snippets/flutter_todos_tutorial/todos_bloc.dart.md ':include')

!> Когда мы выдаем состояние в приватных обработчиках `mapEventToState`, мы всегда получаем новое состояние, а не изменяем `state`. Это потому, что каждый раз, когда мы делаем `yield`, блок будет сравнивать `state` с `nextState` и вызывать изменение состояния (`transition`) только если два состояния **не равны**. Если мы просто изменим и выдадим один и тот же экземпляр состояния, то `state == nextState` будет иметь значение true и изменение состояния не произойдет.

`TodosBloc` будет зависеть от `TodosRepository`, чтобы он мог загружать и сохранять задачи. Он будет иметь начальное состояние `TodosLoadInProgress` и определять частные обработчики для каждого из событий. Всякий раз, когда `TodosBloc` изменяет список задач, он вызывает метод `saveTodos` в `TodosRepository`, чтобы сохранить все изменения.

### Индексный файл

Теперь, когда мы закончили с нашим `TodosBloc`, мы можем создать индексный файл для экспорта всех наших блочных файлов и сделать его удобным для последующего импорта.

Создайте `blocs/todos/todos.dart` и экспортируйте блок, события и состояния:

[bloc.dart](../_snippets/flutter_todos_tutorial/todos_bloc_barrel.dart.md ':include')

## Блок отфильтрованных задач

> `FilteredTodosBloc` будет отвечать за изменения состояния в только что созданном `TodosBloc` и будет поддерживать состояние отфильтрованных задач в нашем приложении.

### Модель

Прежде чем мы начнем определять и реализовывать `TodosStates`, нам нужно реализовать модель `VisibilityFilter`, которая будет определять, какие задачи будут содержать наши `FilteredTodosState`. В этом случае у нас будет три фильтра:

- `all` - показать все Todos (по умолчанию)
- `active` - показывать только Todos, которые не были завершены
- `completed` - показать только Todos, которые были завершены

Мы можем создать `models/visibility_filter.dart` и определить наш фильтр как enum:

[visibility_filter.dart](../_snippets/flutter_todos_tutorial/visibility_filter.dart.md ':include')

### Состояния

Как и в случае с `TodosBloc`, нам необходимо определить различные состояния для нашего `FilteredTodosBloc`.

В этом случае у нас есть только два состояния:

- `FilteredTodosLoadInProgress` - состояние, пока мы выбираем задачи
- `FilteredTodosLoadSuccess` - состояние, когда мы больше не выбираем задачи

Давайте создадим `blocs/filtered_todos/filtered_todos_state.dart` и реализуем два состояния.

[filtered_todos_state.dart](../_snippets/flutter_todos_tutorial/filtered_todos_state.dart.md ':include')

?> **Примечание:** Состояние `FilteredTodosLoadSuccess` содержит список отфильтрованных задач, а также фильтр активной видимости.

### События

Мы собираемся реализовать два события для нашего `FilteredTodosBloc`:

- `FilterUpdated` - уведомляет блок об изменении фильтра видимости.
- `TodosUpdated` - уведомляет блок об изменении списка задач.

Создайте `blocs/filtered_todos/filtered_todos_event.dart` и давайте реализуем два события.

[filtered_todos_event.dart](../_snippets/flutter_todos_tutorial/filtered_todos_event.dart.md ':include')

Мы готовы к реализации нашего `FilteredTodosBloc` дальше!

### Блок

`FilteredTodosBloc` будет похож на `TodosBloc`, однако вместо зависимости от `TodosRepository`, он будет зависеть от самого `TodosBloc`. Это позволит `FilteredTodosBloc` обновлять свое состояние в ответ на изменения состояния в `TodosBloc`.

Создайте `blocs/filtered_todos/filtered_todos_bloc.dart` и начнем.

[filtered_todos_bloc.dart](../_snippets/flutter_todos_tutorial/filtered_todos_bloc.dart.md ':include')

!> Мы создаем `StreamSubscription` для потока `TodosStates`, чтобы мы могли прослушивать изменения состояния в `TodosBloc`. Мы переопределяем метод закрытия блока и отменяем подписку, чтобы мы могли выполнить очистку после закрытия блока.

### Индексный файл

Как и раньше, мы можем создать индексный файл, чтобы было удобнее импортировать различные классы по фильтрации задач.

Создайте `blocs/filtered_todos/filtered_todos.dart` и экспортируйте три файла:

[bloc.dart](../_snippets/flutter_todos_tutorial/filtered_todos_bloc_barrel.dart.md ':include')

Далее мы собираемся реализовать `StatsBloc`.

## Блок статистики

> `StatsBloc` будет отвечать за ведение статистики количества активных и выполненных задач. Аналогично, для `FilteredTodosBloc` он будет зависеть от самого `TodosBloc`, чтобы он мог реагировать на изменения в состоянии `TodosBloc`.

### Состояние

`StatsBloc` будет иметь два состояния:

- `StatsLoadInProgress` - состояние, когда статистика еще не рассчитана.
- `StatsLoadSuccess` - состояние, когда статистика была рассчитана.

Создайте `blocs/stats/stats_state.dart` и давайте реализуем `StatsState`.

[stats_state.dart](../_snippets/flutter_todos_tutorial/stats_state.dart.md ':include')

Далее давайте определим и реализуем `StatsEvents`.

### События

Будет только одно событие, на которое наш `StatsBloc` ответит: `StatsUpdated`. Это событие будет добавлено всякий раз, когда изменяется состояние `TodosBloc`, чтобы наш `StatsBloc` мог пересчитать новую статистику.

Создайте `blocs/stats/stats_event.dart` и давайте реализуем это.

[stats_event.dart](../_snippets/flutter_todos_tutorial/stats_event.dart.md ':include')

Теперь мы готовы реализовать `StatsBloc`, который будет очень похож на `FilteredTodosBloc`.

### Блок

`StatsBloc` будет зависеть от самого `TodosBloc`, что позволит ему обновлять свое состояние в ответ на изменения состояния в `TodosBloc`.

Создайте `blocs/stats/stats_bloc.dart` и начнем.

[stats_bloc.dart](../_snippets/flutter_todos_tutorial/stats_bloc.dart.md ':include')

Это все, что нужно сделать! `StatsBloc` пересчитывает свое состояние, которое содержит количество активных задач и количество выполненных задач при каждом изменении состояния `TodosBloc`.

Теперь, когда мы закончили со `StatsBloc`, у нас есть только один последний блок для реализации: `TabBloc`.

## Блок вкладок

> `TabBloc` будет отвечать за поддержание состояния вкладок в нашем приложении. Он будет принимать `TabEvents` в качестве ввода и вывода `AppTabs`.

### Модель/состояние

Нам необходимо определить модель `AppTab`, которую мы также будем использовать для представления `TabState`. `AppTab` будет просто enum, представляющий активную вкладку в нашем приложении. Поскольку приложение, которое мы создаем, будет иметь только две вкладки: задачи и статистику, нам просто нужно два значения.

Создайте `models/app_tab.dart`:

[app_tab.dart](../_snippets/flutter_todos_tutorial/app_tab.dart.md ':include')

### Событие

`TabBloc` будет отвечать за обработку одного `TabEvent`:

- `TabUpdated` - уведомляет блок об обновлении активной вкладки

Создайте `blocs/tab/tab_event.dart`:

[tab_event.dart](../_snippets/flutter_todos_tutorial/tab_event.dart.md ':include')

### Блок

Реализация `TabBloc` будет очень простой. Как всегда, нам просто нужно реализовать `initialState` и `mapEventToState`.

Создайте `blocs/tab/tab_bloc.dart` и давайте быстро сделаем реализацию.

[tab_bloc.dart](../_snippets/flutter_todos_tutorial/tab_bloc.dart.md ':include')

Я сказал вам, что это будет просто. Все, что делает `TabBloc` - это устанавливает начальное состояние на вкладку todos и обрабатывает событие `TabUpdated`, создавая новый экземпляр `AppTab`.

### Индексный файл

Наконец, мы создадим еще один индексный файл для нашего экспорта `TabBloc`. Создайте `blocs/tab/tab.dart` и экспортируйте два файла:

[bloc.dart](../_snippets/flutter_todos_tutorial/tab_bloc_barrel.dart.md ':include')

## Блок делегат

Прежде чем перейти к уровню представления, мы реализуем наш собственный `BlocDelegate`, который позволит нам обрабатывать все изменения состояния и ошибки в одном месте. Это действительно полезно для таких вещей, как журналы разработчиков или аналитика.

Создайте `blocs/simple_bloc_delegate.dart` и начнем.

[simple_bloc_delegate.dart](../_snippets/flutter_todos_tutorial/simple_bloc_delegate.dart.md ':include')

Все, что мы делаем в этом случае - это печатаем все изменения состояния (`transitions`) и ошибки на консоли, чтобы мы могли видеть что происходит, когда мы запускаем наше приложение. Вы можете подключить свой `BlocDelegate` к аналитике `Google`, `sentry`, `crashlitics` и т.д.

## Индекс для блоков

Теперь, когда у нас реализованы все наши блоки, мы можем создать индексный файл.
Создайте `blocs/blocs.dart` и экспортируйте все наши блоки, чтобы мы могли легко импортировать любой код блока с помощью одного импорта.

[blocs.dart](../_snippets/flutter_todos_tutorial/blocs_barrel.dart.md ':include')

Далее мы сосредоточимся на реализации основных экранов в нашем приложении Todos.

## Экраны

### Домашний экран

> `HomeScreen` будет отвечать за создание `Scaffold` нашего приложения. Он будет поддерживать `AppBar`,`BottomNavigationBar`, а также виджеты `Stats`/`FilteredTodos` (в зависимости от активной вкладки).

Давайте создадим новую директорию под названием `screens`, в которую мы поместим все наши новые виджеты экрана, а затем создадим `screens/home_screen.dart`.

[home_screen.dart](../_snippets/flutter_todos_tutorial/home_screen.dart.md ':include')

`HomeScreen` обращается к `TabBloc` с помощью `BlocProvider.of<TabBloc>(context)`, который будет доступен из нашего корневого виджета `TodosApp` (мы узнаем об этом позже в этом уроке).

Далее мы реализуем `DetailsScreen`.

### Экран задачи

> `DetailsScreen` отображает полную информацию о выбранной задаче и позволяет пользователю либо редактировать, либо удалять задачу.

Создайте `screens/details_screen.dart` и давайте его создадим.

[details_screen.dart](../_snippets/flutter_todos_tutorial/details_screen.dart.md ':include')

?> **Примечание:** Для `DetailsScreen` требуется идентификатор todo, чтобы он мог извлекать детали todo из `TodosBloc` и чтобы он мог обновляться всякий раз, когда были изменены детали todo (идентификатор todo нельзя изменить) ,

Главное, на что следует обратить внимание это то, что существует `IconButton`, который добавляет событие `TodoDeleted`, а также флажок, который добавляет событие `TodoUpdated`.

Существует также другой `FloatingActionButton`, который перемещает пользователя к `AddEditScreen` с `isEditing`, установленным в `true`. Далее мы рассмотрим `AddEditScreen`.

### Экраны добавления/редактирования

> Виджет `AddEditScreen` позволяет пользователю либо создать новую задачу, либо обновить существующую на основе флага `isEditing`, который передается через конструктор.

Создайте `screens/add_edit_screen.dart` и давайте посмотрим на реализацию.

[add_edit_screen.dart](../_snippets/flutter_todos_tutorial/add_edit_screen.dart.md ':include')

В этом виджете нет ничего специфичного для блока. Это просто представление формы и:

- если значение `isEditing` равно true, форма заполняется существующими деталями todo.
- если входные данные пусты то пользователь может создать новую задачу.

Он использует функцию обратного вызова `onSave`, чтобы уведомить своего родителя об обновленном или вновь созданном todo.

Вот и все для экранов в нашем приложении, поэтому, прежде чем мы забудем, давайте создадим файл индекса для их экспорта.

### Индекс экранов

Создайте `screens/screens.dart` и экспортируйте все три.

[screens.dart](../_snippets/flutter_todos_tutorial/screens_barrel.dart.md ':include')

Далее, давайте реализуем все «виджеты» (все, что не является экраном).

## Виджеты

### Кнопка фильтрации

> Виджет `FilterButton` будет отвечать за предоставление пользователю списка параметров фильтра и будет уведомлять `FilteredTodosBloc` при выборе нового фильтра.

Давайте создадим новый каталог с именем `widgets` и поместим нашу реализацию `FilterButton` в `widgets/filter_button.dart`.

[filter_button.dart](../_snippets/flutter_todos_tutorial/filter_button.dart.md ':include')

`FilterButton` должна реагировать на изменения состояния в `FilteredTodosBloc`, поэтому он использует `BlocProvider` для доступа к `FilteredTodosBloc` из `BuildContext`. Затем он использует `BlocBuilder` для повторного рендеринга всякий раз, когда `FilteredTodosBloc` изменяет состояние.

Остальная часть реализации - чистый Flutter и там не так много работы, поэтому мы можем перейти к виджету `ExtraActions`.

### Дополнительные действия

> Подобно `FilterButton`, виджет `ExtraActions` отвечает за предоставление пользователю списка дополнительных опций: `Переключение задач` и `Очистка завершенных задач`.

Поскольку этот виджет не заботится о фильтрах, он будет взаимодействовать с `TodosBloc` вместо `FilteredTodosBloc`.

Давайте создадим модель `ExtraAction` в `models/extra_action.dart`.

[extra_action.dart](../_snippets/flutter_todos_tutorial/extra_action.dart.md ':include')

И не забудьте экспортировать его из файла индекса `models/models.dart`.

Далее, давайте создадим `widgets/extra_actions.dart` и реализуем его.

[extra_actions.dart](../_snippets/flutter_todos_tutorial/extra_actions.dart.md ':include')

Как и в случае с `FilterButton`, мы используем `BlocProvider` для доступа к `TodosBloc` из `BuildContext` и `BlocBuilder`, чтобы реагировать на изменения состояния в `TodosBloc`.

Основываясь на выбранном действии, виджет добавляет событие в `TodosBloc` либо о состоянии завершения `ToggleAll`, либо в `ClearCompleted`.

Далее мы рассмотрим виджет `TabSelector`.

### Селектор вкладок

> Виджет `TabSelector` отвечает за отображение вкладок в `BottomNavigationBar` и обработку пользовательского ввода.

Давайте создадим `widgets/tab_selector.dart` и реализуем его.

[tab_selector.dart](../_snippets/flutter_todos_tutorial/tab_selector.dart.md ':include')

Вы можете видеть, что в этом виджете нет зависимости от блоков; он просто вызывает `onTabSelected`, когда вкладка выбрана, а также принимает в качестве входных данных `activeTab`, чтобы знать какая вкладка выбрана в данный момент.

Далее мы рассмотрим виджет `FilteredTodos`.

### Отфильтованные задачи

> Виджет `FilteredTodos` отвечает за отображение списка задач на основе текущего активного фильтра.

Создайте `widgets/filtered_todos.dart` и давайте реализуем это.

[filtered_todos.dart](../_snippets/flutter_todos_tutorial/filtered_todos.dart.md ':include')

Как и предыдущие виджеты, которые мы написали, виджет `FilteredTodos` использует `BlocProvider` для доступа к блокам (в этом случае необходимы и `FilteredTodosBloc`, и `TodosBloc`).

?> `FilteredTodosBloc` необходим, чтобы помочь нам отобразить правильные задачи на основе текущего фильтра.

?> `TodosBloc` необходим для того, чтобы мы могли добавлять/удалять задачи в ответ на взаимодействие с пользователем, такое как пролистывание отдельной задачи.

Из виджета `FilteredTodos` пользователь может перейти к `DetailsScreen`, где можно редактировать или удалять выбранные задачи. Поскольку наш виджет `FilteredTodos` отображает список виджетов `TodoItem`, мы рассмотрим их далее.

### Элемент задачи

> `TodoItem` - это виджет без сохранения состояния, который отвечает за рендеринг одной задачи и обработку действий пользователя (нажатий/листаний).

Создайте `widgets/todo_item.dart` и давайте его создадим.

[todo_item.dart](../_snippets/flutter_todos_tutorial/todo_item.dart.md ':include')

Опять же, обратите внимание, что в `TodoItem` нет специфичного для блока кода. Он просто выполняет рендеринг на основе задачи, которую мы передаем через конструктор и вызывает введенные функции обратного вызова всякий раз, когда пользователь взаимодействует с задачей.

Далее мы создадим `DeleteTodoSnackBar`.

### Информационный SnackBar

> `DeleteTodoSnackBar` отвечает за указание пользователю, что задача была удалена и позволяет пользователю отменить свое действие.

Создайте `widgets/delete_todo_snack_bar.dart` и давайте реализуем это.

[delete_todo_snack_bar.dart](../_snippets/flutter_todos_tutorial/delete_todo_snack_bar.dart.md ':include')

К настоящему времени вы, вероятно, заметили шаблон: этот виджет также не имеет специфичного для блока кода. Он просто берет задачу для визуализации и вызывает функцию обратного вызова, называемую `onUndo`, если пользователь нажимает кнопку отмены.

Мы почти закончили; осталось только два виджета!

### Индикатор загрузки

> Виджет `LoadingIndicator` - это виджет без сохранения состояния, который отвечает за указание пользователю, что что-то выполняется.

Создайте `widgets/loading_indicator.dart` и давайте напишем это.

[loading_indicator.dart](../_snippets/flutter_todos_tutorial/loading_indicator.dart.md ':include')

Не очень много к обсуждению; мы просто используем `CircularProgressIndicator`, обернутый в виджет `Center` (опять же, нет специфичного для блока кода).

Наконец, нам нужно построить наш виджет `Stats`.

### Статистика

> Виджет `Stats` отвечает за отображение количества активных (выполняемых) задач по сравнению с выполненными.

Давайте создадим `widgets/stats.dart` и посмотрим на реализацию.

[stats.dart](../_snippets/flutter_todos_tutorial/stats.dart.md ':include')

Мы обращаемся к `StatsBloc` с помощью `BlocProvider` и `BlocBuilder` для перестройки в ответ на изменения состояния `StatsBloc`.

## Собираем все вместе

Давайте создадим `main.dart` и виджет `TodosApp`. Нам нужно создать функцию `main` и запустить `TodosApp`.

[main.dart](../_snippets/flutter_todos_tutorial/main1.dart.md ':include')

?> **Примечание:** Мы устанавливаем делегата нашего `BlocSupervisor` в `SimpleBlocDelegate`, который мы создали ранее, чтобы мы могли подключиться ко всем переходам и ошибкам.

?> **Примечание:** Мы также оборачиваем наш виджет `TodosApp` в `BlocProvider`, который управляет инициализацией, закрытием и предоставлением `TodosBloc` для всего нашего дерева виджетов из [flutter_bloc](https://pub.dev/packages/flutter_bloc). Мы немедленно добавляем событие `TodosLoaded`, чтобы запросить последние задачи.

Далее давайте реализуем наш виджет `TodosApp`.

[main.dart](../_snippets/flutter_todos_tutorial/todos_app.dart.md ':include')

`TodosApp` является `StatelessWidget`, который обращается к предоставленному `TodosBloc` через `BuildContext`.

`TodosApp` имеет два маршрута:

- `Home` - отображает`HomeScreen`
- `TodoAdded` - отображает `AddEditScreen` с `isEditing`, установленным в `false`.

`TodosApp` также делает `TabBloc`, `FilteredTodosBloc` и `StatsBloc` доступными для виджетов в своем поддереве с помощью виджета `MultiBlocProvider` из [flutter_bloc](https://pub.dev/packages/flutter_bloc)

[multi_bloc_provider.dart](../_snippets/flutter_todos_tutorial/multi_bloc_provider.dart.md ':include')

эквивалентно написанию

[nested_bloc_providers.dart](../_snippets/flutter_todos_tutorial/nested_bloc_providers.dart.md ':include')

Вы можете видеть как использование `MultiBlocProvider` помогает снизить уровни вложенности и облегчает чтение и сопровождение кода.

Весь файл `main.dart` должен выглядеть так:

[main.dart](../_snippets/flutter_todos_tutorial/main2.dart.md ':include')

Вот и все, что нужно сделать! Теперь мы успешно реализовали приложение todos в Flutter, используя пакеты [bloc](https://pub.dev/packages/bloc) и [flutter_bloc](https://pub.dev/packages/flutter_bloc) и мы успешно отделили наш уровень представления от нашей бизнес логики.

Полный исходный код этого примера можно найти [здесь](https://github.com/felangel/Bloc/tree/master/examples/flutter_todos).

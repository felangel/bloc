# Flutter задачи

![advanced](https://img.shields.io/badge/level-advanced-red.svg)

> В следующем руководстве мы собираемся создать приложение Todos во Flutter с использованием библиотеки Bloc.

![demo](../assets/gifs/flutter_todos.gif)

## Настройка

Мы начнем с создания нового проекта Flutter

```bash
flutter create flutter_todos
```

Сначала нам нужно заменить содержимое файла `pubspec.yaml` на:

```yaml
name: flutter_todos
description: A new Flutter project.

environment:
  sdk: ">=2.6.0 <3.0.0"

dependencies:
  meta: ^1.1.6
  equatable: ^1.0.0
  flutter_bloc: ^4.0.0
  flutter:
    sdk: flutter

dependency_overrides:
  todos_app_core:
    git:
      url: https://github.com/felangel/flutter_architecture_samples
      path: todos_app_core
      ref: rxdart/0.23.0
  todos_repository_core:
    git:
      url: https://github.com/felangel/flutter_architecture_samples
      path: todos_repository_core
      ref: rxdart/0.23.0
  todos_repository_simple:
    git:
      url: https://github.com/felangel/flutter_architecture_samples
      path: todos_repository_simple
      ref: rxdart/0.23.0

flutter:
  uses-material-design: true
```

а затем установить все наши зависимости

```bash
flutter packages get
```

?> **Примечание:** Мы переопределяем некоторые зависимости, потому что собираемся повторно использовать их из [Образцов архитектуры Flutter Брайана Игана](https://github.com/brianegan/flutter_architecture_samples).

## Ключи приложения

Прежде чем мы перейдем к коду приложения, давайте создадим `flutter_todos_keys.dart`. Этот файл будет содержать ключи, которые мы будем использовать для уникальной идентификации важных виджетов. Позже мы можем написать тесты, которые находят виджеты на основе ключей.

```dart
import 'package:flutter/widgets.dart';

class FlutterTodosKeys {
  static final extraActionsPopupMenuButton =
      const Key('__extraActionsPopupMenuButton__');
  static final extraActionsEmptyContainer =
      const Key('__extraActionsEmptyContainer__');
  static final filteredTodosEmptyContainer =
      const Key('__filteredTodosEmptyContainer__');
  static final statsLoadInProgressIndicator = const Key('__statsLoadInProgressIndicator__');
  static final emptyStatsContainer = const Key('__emptyStatsContainer__');
  static final emptyDetailsContainer = const Key('__emptyDetailsContainer__');
  static final detailsScreenCheckBox = const Key('__detailsScreenCheckBox__');
}
```

Мы будем ссылаться на эти ключи в оставшейся части руководства.

?> **Примечание:** Вы можете проверить интеграционные тесты для приложения [здесь](https://github.com/brianegan/flutter_architecture_samples/tree/master/integration_tests). Вы также можете проверить тесты модулей и виджетов [здесь](https://github.com/brianegan/flutter_architecture_samples/tree/master/bloc_library/test).

## Локализация

Последнее, что мы затронем прежде чем углубляться в само приложение - это локализация. Создайте `localization.dart` и мы создадим основу для мультиязычной поддержки.

```dart
import 'dart:async';

import 'package:flutter/material.dart';

class FlutterBlocLocalizations {
  static FlutterBlocLocalizations of(BuildContext context) {
    return Localizations.of<FlutterBlocLocalizations>(
      context,
      FlutterBlocLocalizations,
    );
  }

  String get appTitle => "Flutter Todos";
}

class FlutterBlocLocalizationsDelegate
    extends LocalizationsDelegate<FlutterBlocLocalizations> {
  @override
  Future<FlutterBlocLocalizations> load(Locale locale) =>
      Future(() => FlutterBlocLocalizations());

  @override
  bool shouldReload(FlutterBlocLocalizationsDelegate old) => false;

  @override
  bool isSupported(Locale locale) =>
      locale.languageCode.toLowerCase().contains("en");
}
```

Теперь мы можем импортировать и предоставить `FlutterBlocLocalizationsDelegate` нашему `MaterialApp`(далее в этом руководстве).

Для получения дополнительной информации о локализации ознакомьтесь с [официальными документами по Flutter](https://flutter.dev/docs/development/accessibility-and-localization/internationalization).

## Todos хранилище

В этом руководстве мы не будем вдаваться в подробности реализации `TodosRepository`, потому что это уже было реализовано [Brian Egan](https://github.com/brianegan) и является общим для всех [примеров архитектуры Todo](https://github.com/brianegan/flutter_architecture_samples). На высоком уровне `TodosRepository` представит метод для `loadTodos` и `saveTodos`. Это почти все, что нам нужно знать, поэтому в оставшейся части урока мы сосредоточимся на слоях `Bloc` и `Presentation`.

## Todos блок

> `TodosBloc` будет отвечать за преобразование `TodosEvents` в `TodosStates` и будет управлять списком задач.

### Модель

Первое, что нам нужно сделать, это определить нашу модель `Todo`. Каждое задание должно иметь идентификатор, задачу, необязательную заметку и необязательный флаг завершения.

Давайте создадим каталог `models` и создадим внутри файл `todo.dart`.

```dart
import 'package:todos_app_core/todos_app_core.dart';
import 'package:equatable/equatable.dart';
import 'package:todos_repository_core/todos_repository_core.dart';

class Todo extends Equatable {
  final bool complete;
  final String id;
  final String note;
  final String task;

  Todo(
    this.task, {
    this.complete = false,
    String note = '',
    String id,
  })  : this.note = note ?? '',
        this.id = id ?? Uuid().generateV4();

  Todo copyWith({bool complete, String id, String note, String task}) {
    return Todo(
      task ?? this.task,
      complete: complete ?? this.complete,
      id: id ?? this.id,
      note: note ?? this.note,
    );
  }

  @override
  List<Object> get props => [complete, id, note, task];

  @override
  String toString() {
    return 'Todo { complete: $complete, task: $task, note: $note, id: $id }';
  }

  TodoEntity toEntity() {
    return TodoEntity(task, id, note, complete);
  }

  static Todo fromEntity(TodoEntity entity) {
    return Todo(
      entity.task,
      complete: entity.complete ?? false,
      note: entity.note,
      id: entity.id ?? Uuid().generateV4(),
    );
  }
}
```

?> **Примечание:** Мы используем пакет [Equatable](https://pub.dev/packages/equatable), чтобы мы могли сравнивать экземпляры `Todos` без необходимости вручную переопределять `==` и `hashCode`.

Далее нам нужно создать `TodosState`, который получит наш уровень представления.

### Состояния

Давайте создадим `blocs/todos/todos_state.dart` и определим различные состояния, которые нам нужно обработать.

Мы будем реализовывать три состояния:

- `TodosLoadInProgress` - состояние, когда наше приложение выбирает задачи из репозитория.
- `TodosLoadSuccess` - состояние нашего приложения после успешной загрузки задач.
- `TodosLoadFailure` - состояние нашего приложения, если задачи не были успешно загружены.

```dart
import 'package:equatable/equatable.dart';
import 'package:flutter_todos/models/models.dart';

abstract class TodosState extends Equatable {
  const TodosState();

  @override
  List<Object> get props => [];
}

class TodosLoadInProgress extends TodosState {}

class TodosLoadSuccess extends TodosState {
  final List<Todo> todos;

  const TodosLoadSuccess([this.todos = const []]);

  @override
  List<Object> get props => [todos];

  @override
  String toString() => 'TodosLoadSuccess { todos: $todos }';
}

class TodosLoadFailure extends TodosState {}
```

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

```dart
import 'package:equatable/equatable.dart';
import 'package:flutter_todos/models/models.dart';

abstract class TodosEvent extends Equatable {
  const TodosEvent();

  @override
  List<Object> get props => [];
}

class TodosLoaded extends TodosEvent {}

class TodoAdded extends TodosEvent {
  final Todo todo;

  const TodoAdded(this.todo);

  @override
  List<Object> get props => [todo];

  @override
  String toString() => 'TodoAdded { todo: $todo }';
}

class TodoUpdated extends TodosEvent {
  final Todo updatedTodo;

  const TodoUpdated(this.updatedTodo);

  @override
  List<Object> get props => [updatedTodo];

  @override
  String toString() => 'TodoUpdated { updatedTodo: $updatedTodo }';
}

class TodoDeleted extends TodosEvent {
  final Todo todo;

  const TodoDeleted(this.todo);

  @override
  List<Object> get props => [todo];

  @override
  String toString() => 'TodoDeleted { todo: $todo }';
}

class ClearCompleted extends TodosEvent {}

class ToggleAll extends TodosEvent {}
```

Теперь, когда у нас реализованы `TodosStates` и `TodosEvents`, мы можем реализовать наш `TodosBloc`.

### Блок

Давайте создадим `blocs/todos/todos_bloc.dart` и начнем! Нам просто нужно реализовать `initialState` и `mapEventToState`.

```dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:flutter_todos/blocs/todos/todos.dart';
import 'package:flutter_todos/models/models.dart';
import 'package:todos_repository_simple/todos_repository_simple.dart';

class TodosBloc extends Bloc<TodosEvent, TodosState> {
  final TodosRepositoryFlutter todosRepository;

  TodosBloc({@required this.todosRepository});

  @override
  TodosState get initialState => TodosLoadInProgress();

  @override
  Stream<TodosState> mapEventToState(TodosEvent event) async* {
    if (event is TodosLoaded) {
      yield* _mapTodosLoadedToState();
    } else if (event is TodoAdded) {
      yield* _mapTodoAddedToState(event);
    } else if (event is TodoUpdated) {
      yield* _mapTodoUpdatedToState(event);
    } else if (event is TodoDeleted) {
      yield* _mapTodoDeletedToState(event);
    } else if (event is ToggleAll) {
      yield* _mapToggleAllToState();
    } else if (event is ClearCompleted) {
      yield* _mapClearCompletedToState();
    }
  }

  Stream<TodosState> _mapTodosLoadedToState() async* {
    try {
      final todos = await this.todosRepository.loadTodos();
      yield TodosLoadSuccess(
        todos.map(Todo.fromEntity).toList(),
      );
    } catch (_) {
      yield TodosLoadFailure();
    }
  }

  Stream<TodosState> _mapTodoAddedToState(TodoAdded event) async* {
    if (state is TodosLoadSuccess) {
      final List<Todo> updatedTodos = List.from((state as TodosLoadSuccess).todos)
        ..add(event.todo);
      yield TodosLoadSuccess(updatedTodos);
      _saveTodos(updatedTodos);
    }
  }

  Stream<TodosState> _mapTodoUpdatedToState(TodoUpdated event) async* {
    if (state is TodosLoadSuccess) {
      final List<Todo> updatedTodos = (state as TodosLoadSuccess).todos.map((todo) {
        return todo.id == event.updatedTodo.id ? event.updatedTodo : todo;
      }).toList();
      yield TodosLoadSuccess(updatedTodos);
      _saveTodos(updatedTodos);
    }
  }

  Stream<TodosState> _mapTodoDeletedToState(TodoDeleted event) async* {
    if (state is TodosLoadSuccess) {
      final updatedTodos = (state as TodosLoadSuccess)
          .todos
          .where((todo) => todo.id != event.todo.id)
          .toList();
      yield TodosLoadSuccess(updatedTodos);
      _saveTodos(updatedTodos);
    }
  }

  Stream<TodosState> _mapToggleAllToState() async* {
    if (state is TodosLoadSuccess) {
      final allComplete =
          (state as TodosLoadSuccess).todos.every((todo) => todo.complete);
      final List<Todo> updatedTodos = (state as TodosLoadSuccess)
          .todos
          .map((todo) => todo.copyWith(complete: !allComplete))
          .toList();
      yield TodosLoadSuccess(updatedTodos);
      _saveTodos(updatedTodos);
    }
  }

  Stream<TodosState> _mapClearCompletedToState() async* {
    if (state is TodosLoadSuccess) {
      final List<Todo> updatedTodos =
          (state as TodosLoadSuccess).todos.where((todo) => !todo.complete).toList();
      yield TodosLoadSuccess(updatedTodos);
      _saveTodos(updatedTodos);
    }
  }

  Future _saveTodos(List<Todo> todos) {
    return todosRepository.saveTodos(
      todos.map((todo) => todo.toEntity()).toList(),
    );
  }
}
```

!> Когда мы выдаем состояние в приватных обработчиках `mapEventToState`, мы всегда получаем новое состояние, а не изменяем `state`. Это потому, что каждый раз, когда мы делаем `yield`, блок будет сравнивать `state` с `nextState` и вызывать изменение состояния (`transition`) только если два состояния **не равны**. Если мы просто изменим и выдадим один и тот же экземпляр состояния, то `state == nextState` будет иметь значение true и изменение состояния не произойдет.

`TodosBloc` будет зависеть от `TodosRepository`, чтобы он мог загружать и сохранять задачи. Он будет иметь начальное состояние `TodosLoadInProgress` и определять частные обработчики для каждого из событий. Всякий раз, когда `TodosBloc` изменяет список задач, он вызывает метод `saveTodos` в `TodosRepository`, чтобы сохранить все изменения.

### Индексный файл

Теперь, когда мы закончили с нашим `TodosBloc`, мы можем создать индексный файл для экспорта всех наших блочных файлов и сделать его удобным для последующего импорта.

Создайте `blocs/todos/todos.dart` и экспортируйте блок, события и состояния:

```dart
export './todos_bloc.dart';
export './todos_event.dart';
export './todos_state.dart';
```

## Блок отфильтрованных задач

> `FilteredTodosBloc` будет отвечать за изменения состояния в только что созданном `TodosBloc` и будет поддерживать состояние отфильтрованных задач в нашем приложении.

### Модель

Прежде чем мы начнем определять и реализовывать `TodosStates`, нам нужно реализовать модель `VisibilityFilter`, которая будет определять, какие задачи будут содержать наши `FilteredTodosState`. В этом случае у нас будет три фильтра:

- `all` - показать все Todos (по умолчанию)
- `active` - показывать только Todos, которые не были завершены
- `completed` - показать только Todos, которые были завершены

Мы можем создать `models/visibility_filter.dart` и определить наш фильтр как enum:

```dart
enum VisibilityFilter { all, active, completed }
```

### Состояния

Как и в случае с `TodosBloc`, нам необходимо определить различные состояния для нашего `FilteredTodosBloc`.

В этом случае у нас есть только два состояния:

- `FilteredTodosLoadInProgress` - состояние, пока мы выбираем задачи
- `FilteredTodosLoadSuccess` - состояние, когда мы больше не выбираем задачи

Давайте создадим `blocs/filtered_todos/filtered_todos_state.dart` и реализуем два состояния.

```dart
import 'package:equatable/equatable.dart';
import 'package:flutter_todos/models/models.dart';

abstract class FilteredTodosState extends Equatable {
  const FilteredTodosState();

  @override
  List<Object> get props => [];
}

class FilteredTodosLoadInProgress extends FilteredTodosState {}

class FilteredTodosLoadSuccess extends FilteredTodosState {
  final List<Todo> filteredTodos;
  final VisibilityFilter activeFilter;

  const FilteredTodosLoadSuccess(
    this.filteredTodos,
    this.activeFilter,
  );

  @override
  List<Object> get props => [filteredTodos, activeFilter];

  @override
  String toString() {
    return 'FilteredTodosLoadSuccess { filteredTodos: $filteredTodos, activeFilter: $activeFilter }';
  }
}
```

?> **Примечание:** Состояние `FilteredTodosLoadSuccess` содержит список отфильтрованных задач, а также фильтр активной видимости.

### События

Мы собираемся реализовать два события для нашего `FilteredTodosBloc`:

- `FilterUpdated` - уведомляет блок об изменении фильтра видимости.
- `TodosUpdated` - уведомляет блок об изменении списка задач.

Создайте `blocs/filtered_todos/filtered_todos_event.dart` и давайте реализуем два события.

```dart
import 'package:equatable/equatable.dart';
import 'package:flutter_todos/models/models.dart';

abstract class FilteredTodosEvent extends Equatable {
  const FilteredTodosEvent();
}

class FilterUpdated extends FilteredTodosEvent {
  final VisibilityFilter filter;

  const FilterUpdated(this.filter);

  @override
  List<Object> get props => [filter];

  @override
  String toString() => 'FilterUpdated { filter: $filter }';
}

class TodosUpdated extends FilteredTodosEvent {
  final List<Todo> todos;

  const TodosUpdated(this.todos);

  @override
  List<Object> get props => [todos];

  @override
  String toString() => 'TodosUpdated { todos: $todos }';
}
```

Мы готовы к реализации нашего `FilteredTodosBloc` дальше!

### Блок

`FilteredTodosBloc` будет похож на `TodosBloc`, однако вместо зависимости от `TodosRepository`, он будет зависеть от самого `TodosBloc`. Это позволит `FilteredTodosBloc` обновлять свое состояние в ответ на изменения состояния в `TodosBloc`.

Создайте `blocs/filtered_todos/filtered_todos_bloc.dart` и начнем.

```dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:flutter_todos/blocs/filtered_todos/filtered_todos.dart';
import 'package:flutter_todos/blocs/todos/todos.dart';
import 'package:flutter_todos/models/models.dart';

class FilteredTodosBloc extends Bloc<FilteredTodosEvent, FilteredTodosState> {
  final TodosBloc todosBloc;
  StreamSubscription todosSubscription;

  FilteredTodosBloc({@required this.todosBloc}) {
    todosSubscription = todosBloc.listen((state) {
      if (state is TodosLoadSuccess) {
        add(TodosUpdated((todosBloc.state as TodosLoadSuccess).todos));
      }
    });
  }

  @override
  FilteredTodosState get initialState {
    return todosBloc.state is TodosLoadSuccess
        ? FilteredTodosLoadSuccess(
            (todosBloc.state as TodosLoadSuccess).todos,
            VisibilityFilter.all,
          )
        : FilteredTodosLoadInProgress();
  }

  @override
  Stream<FilteredTodosState> mapEventToState(FilteredTodosEvent event) async* {
    if (event is FilterUpdated) {
      yield* _mapFilterUpdatedToState(event);
    } else if (event is TodosUpdated) {
      yield* _mapTodosUpdatedToState(event);
    }
  }

  Stream<FilteredTodosState> _mapFilterUpdatedToState(
    FilterUpdated event,
  ) async* {
    if (todosBloc.state is TodosLoadSuccess) {
      yield FilteredTodosLoadSuccess(
        _mapTodosToFilteredTodos(
          (todosBloc.state as TodosLoadSuccess).todos,
          event.filter,
        ),
        event.filter,
      );
    }
  }

  Stream<FilteredTodosState> _mapTodosUpdatedToState(
    TodosUpdated event,
  ) async* {
    final visibilityFilter = state is FilteredTodosLoadSuccess
        ? (state as FilteredTodosLoadSuccess).activeFilter
        : VisibilityFilter.all;
    yield FilteredTodosLoadSuccess(
      _mapTodosToFilteredTodos(
        (todosBloc.state as TodosLoadSuccess).todos,
        visibilityFilter,
      ),
      visibilityFilter,
    );
  }

  List<Todo> _mapTodosToFilteredTodos(
      List<Todo> todos, VisibilityFilter filter) {
    return todos.where((todo) {
      if (filter == VisibilityFilter.all) {
        return true;
      } else if (filter == VisibilityFilter.active) {
        return !todo.complete;
      } else {
        return todo.complete;
      }
    }).toList();
  }

  @override
  Future<void> close() {
    todosSubscription.cancel();
    return super.close();
  }
}
```

!> Мы создаем `StreamSubscription` для потока `TodosStates`, чтобы мы могли прослушивать изменения состояния в `TodosBloc`. Мы переопределяем метод закрытия блока и отменяем подписку, чтобы мы могли выполнить очистку после закрытия блока.

### Индексный файл

Как и раньше, мы можем создать индексный файл, чтобы было удобнее импортировать различные классы по фильтрации задач.

Создайте `blocs/filtered_todos/filtered_todos.dart` и экспортируйте три файла:

```dart
export './filtered_todos_bloc.dart';
export './filtered_todos_event.dart';
export './filtered_todos_state.dart';
```

Далее мы собираемся реализовать `StatsBloc`.

## Блок статистики

> `StatsBloc` будет отвечать за ведение статистики количества активных и выполненных задач. Аналогично, для `FilteredTodosBloc` он будет зависеть от самого `TodosBloc`, чтобы он мог реагировать на изменения в состоянии `TodosBloc`.

### Состояние

`StatsBloc` будет иметь два состояния:

- `StatsLoadInProgress` - состояние, когда статистика еще не рассчитана.
- `StatsLoadSuccess` - состояние, когда статистика была рассчитана.

Создайте `blocs/stats/stats_state.dart` и давайте реализуем `StatsState`.

```dart
import 'package:equatable/equatable.dart';

abstract class StatsState extends Equatable {
  const StatsState();

  @override
  List<Object> get props => [];
}

class StatsLoadInProgress extends StatsState {}

class StatsLoadSuccess extends StatsState {
  final int numActive;
  final int numCompleted;

  const StatsLoadSuccess(this.numActive, this.numCompleted);

  @override
  List<Object> get props => [numActive, numCompleted];

  @override
  String toString() {
    return 'StatsLoadSuccess { numActive: $numActive, numCompleted: $numCompleted }';
  }
}
```

Далее давайте определим и реализуем `StatsEvents`.

### События

Будет только одно событие, на которое наш `StatsBloc` ответит: `StatsUpdated`. Это событие будет добавлено всякий раз, когда изменяется состояние `TodosBloc`, чтобы наш `StatsBloc` мог пересчитать новую статистику.

Создайте `blocs/stats/states_event.dart` и давайте реализуем это.

```dart
import 'package:equatable/equatable.dart';
import 'package:flutter_todos/models/models.dart';

abstract class StatsEvent extends Equatable {
  const StatsEvent();
}

class StatsUpdated extends StatsEvent {
  final List<Todo> todos;

  const StatsUpdated(this.todos);

  @override
  List<Object> get props => [todos];

  @override
  String toString() => 'StatsUpdated { todos: $todos }';
}
```

Теперь мы готовы реализовать `StatsBloc`, который будет очень похож на `FilteredTodosBloc`.

### Блок

`StatsBloc` будет зависеть от самого `TodosBloc`, что позволит ему обновлять свое состояние в ответ на изменения состояния в `TodosBloc`.

Создайте `blocs/stats/stats_bloc.dart` и начнем.

```dart
import 'dart:async';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_todos/blocs/blocs.dart';

class StatsBloc extends Bloc<StatsEvent, StatsState> {
  final TodosBloc todosBloc;
  StreamSubscription todosSubscription;

  StatsBloc({@required this.todosBloc}) {
    todosSubscription = todosBloc.listen((state) {
      if (state is TodosLoadSuccess) {
        add(StatsUpdated(state.todos));
      }
    });
  }

  @override
  StatsState get initialState => StatsLoadInProgress();

  @override
  Stream<StatsState> mapEventToState(StatsEvent event) async* {
    if (event is StatsUpdated) {
      int numActive =
          event.todos.where((todo) => !todo.complete).toList().length;
      int numCompleted =
          event.todos.where((todo) => todo.complete).toList().length;
      yield StatsLoadSuccess(numActive, numCompleted);
    }
  }

  @override
  Future<void> close() {
    todosSubscription.cancel();
    return super.close();
  }
}
```

Это все, что нужно сделать! `StatsBloc` пересчитывает свое состояние, которое содержит количество активных задач и количество выполненных задач при каждом изменении состояния `TodosBloc`.

Теперь, когда мы закончили со `StatsBloc`, у нас есть только один последний блок для реализации: `TabBloc`.

## Блок вкладок

> `TabBloc` будет отвечать за поддержание состояния вкладок в нашем приложении. Он будет принимать `TabEvents` в качестве ввода и вывода `AppTabs`.

### Модель/состояние

Нам необходимо определить модель `AppTab`, которую мы также будем использовать для представления `TabState`. `AppTab` будет просто enum, представляющий активную вкладку в нашем приложении. Поскольку приложение, которое мы создаем, будет иметь только две вкладки: задачи и статистику, нам просто нужно два значения.

Создайте `models/app_tab.dart`:

```dart
enum AppTab { todos, stats }
```

### Событие

`TabBloc` будет отвечать за обработку одного `TabEvent`:

- `TabUpdated` - уведомляет блок об обновлении активной вкладки

Создайте `blocs/tab/tab_event.dart`:

```dart
import 'package:equatable/equatable.dart';
import 'package:flutter_todos/models/models.dart';

abstract class TabEvent extends Equatable {
  const TabEvent();
}

class TabUpdated extends TabEvent {
  final AppTab tab;

  const TabUpdated(this.tab);

  @override
  List<Object> get props => [tab];

  @override
  String toString() => 'TabUpdated { tab: $tab }';
}
```

### Блок

Реализация `TabBloc` будет очень простой. Как всегда, нам просто нужно реализовать `initialState` и `mapEventToState`.

Создайте `blocs/tab/tab_bloc.dart` и давайте быстро сделаем реализацию.

```dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter_todos/blocs/tab/tab.dart';
import 'package:flutter_todos/models/models.dart';

class TabBloc extends Bloc<TabEvent, AppTab> {
  @override
  AppTab get initialState => AppTab.todos;

  @override
  Stream<AppTab> mapEventToState(TabEvent event) async* {
    if (event is TabUpdated) {
      yield event.tab;
    }
  }
}
```

Я сказал вам, что это будет просто. Все, что делает `TabBloc` - это устанавливает начальное состояние на вкладку todos и обрабатывает событие `TabUpdated`, создавая новый экземпляр `AppTab`.

### Индексный файл

Наконец, мы создадим еще один индексный файл для нашего экспорта `TabBloc`. Создайте `blocs/tab/tab.dart` и экспортируйте два файла:

```dart
export './tab_bloc.dart';
export './tab_event.dart';
```

## Блок делегат

Прежде чем перейти к уровню представления, мы реализуем наш собственный `BlocDelegate`, который позволит нам обрабатывать все изменения состояния и ошибки в одном месте. Это действительно полезно для таких вещей, как журналы разработчиков или аналитика.

Создайте `blocs/simple_bloc_delegate.dart` и начнем.

```dart
import 'package:bloc/bloc.dart';

class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onEvent(Bloc bloc, Object event) {
    super.onEvent(bloc, event);
    print(event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
    print(error);
  }
}
```

Все, что мы делаем в этом случае - это печатаем все изменения состояния (`transitions`) и ошибки на консоли, чтобы мы могли видеть что происходит, когда мы запускаем наше приложение. Вы можете подключить свой `BlocDelegate` к аналитике `Google`, `sentry`, `crashlitics` и т.д.

## Индекс для блоков

Теперь, когда у нас реализованы все наши блоки, мы можем создать индексный файл.
Создайте `blocs/blocs.dart` и экспортируйте все наши блоки, чтобы мы могли легко импортировать любой код блока с помощью одного импорта.

```dart
export './filtered_todos/filtered_todos.dart';
export './stats/stats.dart';
export './tab/tab.dart';
export './todos/todos.dart';
export './simple_bloc_delegate.dart';
```

Далее мы сосредоточимся на реализации основных экранов в нашем приложении Todos.

## Экраны

### Домашний экран

> `HomeScreen` будет отвечать за создание `Scaffold` нашего приложения. Он будет поддерживать `AppBar`,`BottomNavigationBar`, а также виджеты `Stats`/`FilteredTodos` (в зависимости от активной вкладки).

Давайте создадим новую директорию под названием `screens`, в которую мы поместим все наши новые виджеты экрана, а затем создадим `screens/home_screen.dart`.

```dart
import 'package:flutter/material.dart';
import 'package:todos_app_core/todos_app_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_todos/blocs/blocs.dart';
import 'package:flutter_todos/widgets/widgets.dart';
import 'package:flutter_todos/localization.dart';
import 'package:flutter_todos/models/models.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TabBloc, AppTab>(
      builder: (context, activeTab) {
        return Scaffold(
          appBar: AppBar(
            title: Text(FlutterBlocLocalizations.of(context).appTitle),
            actions: [
              FilterButton(visible: activeTab == AppTab.todos),
              ExtraActions(),
            ],
          ),
          body: activeTab == AppTab.todos ? FilteredTodos() : Stats(),
          floatingActionButton: FloatingActionButton(
            key: ArchSampleKeys.addTodoFab,
            onPressed: () {
              Navigator.pushNamed(context, ArchSampleRoutes.addTodo);
            },
            child: Icon(Icons.add),
            tooltip: ArchSampleLocalizations.of(context).addTodo,
          ),
          bottomNavigationBar: TabSelector(
            activeTab: activeTab,
            onTabSelected: (tab) =>
                BlocProvider.of<TabBloc>(context).add(TabUpdated(tab)),
          ),
        );
      },
    );
  }
}
```

`HomeScreen` обращается к `TabBloc` с помощью `BlocProvider.of<TabBloc>(context)`, который будет доступен из нашего корневого виджета `TodosApp` (мы узнаем об этом позже в этом уроке).

Далее мы реализуем `DetailsScreen`.

### Экран задачи

> `DetailsScreen` отображает полную информацию о выбранной задаче и позволяет пользователю либо редактировать, либо удалять задачу.

Создайте `screens/details_screen.dart` и давайте его создадим.

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todos_app_core/todos_app_core.dart';
import 'package:flutter_todos/blocs/todos/todos.dart';
import 'package:flutter_todos/screens/screens.dart';
import 'package:flutter_todos/flutter_todos_keys.dart';

class DetailsScreen extends StatelessWidget {
  final String id;

  DetailsScreen({Key key, @required this.id})
      : super(key: key ?? ArchSampleKeys.todoDetailsScreen);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodosBloc, TodosState>(
      builder: (context, state) {
        final todo = (state as TodosLoadSuccess)
            .todos
            .firstWhere((todo) => todo.id == id, orElse: () => null);
        final localizations = ArchSampleLocalizations.of(context);
        return Scaffold(
          appBar: AppBar(
            title: Text(localizations.todoDetails),
            actions: [
              IconButton(
                tooltip: localizations.deleteTodo,
                key: ArchSampleKeys.deleteTodoButton,
                icon: Icon(Icons.delete),
                onPressed: () {
                  BlocProvider.of<TodosBloc>(context).add(TodoDeleted(todo));
                  Navigator.pop(context, todo);
                },
              )
            ],
          ),
          body: todo == null
              ? Container(key: FlutterTodosKeys.emptyDetailsContainer)
              : Padding(
                  padding: EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: Checkbox(
                                key: FlutterTodosKeys.detailsScreenCheckBox,
                                value: todo.complete,
                                onChanged: (_) {
                                  BlocProvider.of<TodosBloc>(context).add(
                                    TodoUpdated(
                                      todo.copyWith(complete: !todo.complete),
                                    ),
                                  );
                                }),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Hero(
                                  tag: '${todo.id}__heroTag',
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    padding: EdgeInsets.only(
                                      top: 8.0,
                                      bottom: 16.0,
                                    ),
                                    child: Text(
                                      todo.task,
                                      key: ArchSampleKeys.detailsTodoItemTask,
                                      style:
                                          Theme.of(context).textTheme.headline,
                                    ),
                                  ),
                                ),
                                Text(
                                  todo.note,
                                  key: ArchSampleKeys.detailsTodoItemNote,
                                  style: Theme.of(context).textTheme.subhead,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
          floatingActionButton: FloatingActionButton(
            key: ArchSampleKeys.editTodoFab,
            tooltip: localizations.editTodo,
            child: Icon(Icons.edit),
            onPressed: todo == null
                ? null
                : () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return AddEditScreen(
                            key: ArchSampleKeys.editTodoScreen,
                            onSave: (task, note) {
                              BlocProvider.of<TodosBloc>(context).add(
                                TodoUpdated(
                                  todo.copyWith(task: task, note: note),
                                ),
                              );
                            },
                            isEditing: true,
                            todo: todo,
                          );
                        },
                      ),
                    );
                  },
          ),
        );
      },
    );
  }
}
```

?> **Примечание:** Для `DetailsScreen` требуется идентификатор todo, чтобы он мог извлекать детали todo из `TodosBloc` и чтобы он мог обновляться всякий раз, когда были изменены детали todo (идентификатор todo нельзя изменить) ,

Главное, на что следует обратить внимание это то, что существует `IconButton`, который добавляет событие `TodoDeleted`, а также флажок, который добавляет событие `TodoUpdated`.

Существует также другой `FloatingActionButton`, который перемещает пользователя к `AddEditScreen` с `isEditing`, установленным в `true`. Далее мы рассмотрим `AddEditScreen`.

### Экраны добавления/редактирования

> Виджет `AddEditScreen` позволяет пользователю либо создать новую задачу, либо обновить существующую на основе флага `isEditing`, который передается через конструктор.

Создайте `screens/add_edit_screen.dart` и давайте посмотрим на реализацию.

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:todos_app_core/todos_app_core.dart';
import 'package:flutter_todos/models/models.dart';

typedef OnSaveCallback = Function(String task, String note);

class AddEditScreen extends StatefulWidget {
  final bool isEditing;
  final OnSaveCallback onSave;
  final Todo todo;

  AddEditScreen({
    Key key,
    @required this.onSave,
    @required this.isEditing,
    this.todo,
  }) : super(key: key ?? ArchSampleKeys.addTodoScreen);

  @override
  _AddEditScreenState createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _task;
  String _note;

  bool get isEditing => widget.isEditing;

  @override
  Widget build(BuildContext context) {
    final localizations = ArchSampleLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? localizations.editTodo : localizations.addTodo,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: isEditing ? widget.todo.task : '',
                key: ArchSampleKeys.taskField,
                autofocus: !isEditing,
                style: textTheme.headline,
                decoration: InputDecoration(
                  hintText: localizations.newTodoHint,
                ),
                validator: (val) {
                  return val.trim().isEmpty
                      ? localizations.emptyTodoError
                      : null;
                },
                onSaved: (value) => _task = value,
              ),
              TextFormField(
                initialValue: isEditing ? widget.todo.note : '',
                key: ArchSampleKeys.noteField,
                maxLines: 10,
                style: textTheme.subhead,
                decoration: InputDecoration(
                  hintText: localizations.notesHint,
                ),
                onSaved: (value) => _note = value,
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key:
            isEditing ? ArchSampleKeys.saveTodoFab : ArchSampleKeys.saveNewTodo,
        tooltip: isEditing ? localizations.saveChanges : localizations.addTodo,
        child: Icon(isEditing ? Icons.check : Icons.add),
        onPressed: () {
          if (_formKey.currentState.validate()) {
            _formKey.currentState.save();
            widget.onSave(_task, _note);
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
```

В этом виджете нет ничего специфичного для блока. Это просто представление формы и:

- если значение `isEditing` равно true, форма заполняется существующими деталями todo.
- если входные данные пусты то пользователь может создать новую задачу.

Он использует функцию обратного вызова `onSave`, чтобы уведомить своего родителя об обновленном или вновь созданном todo.

Вот и все для экранов в нашем приложении, поэтому, прежде чем мы забудем, давайте создадим файл индекса для их экспорта.

### Индекс экранов

Создайте `screens/screens.dart` и экспортируйте все три.

```dart
export './add_edit_screen.dart';
export './details_screen.dart';
export './home_screen.dart';
```

Далее, давайте реализуем все «виджеты» (все, что не является экраном).

## Виджеты

### Кнопка фильтрации

> Виджет `FilterButton` будет отвечать за предоставление пользователю списка параметров фильтра и будет уведомлять `FilteredTodosBloc` при выборе нового фильтра.

Давайте создадим новый каталог с именем `widgets` и поместим нашу реализацию `FilterButton` в `widgets/filter_button.dart`.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todos_app_core/todos_app_core.dart';
import 'package:flutter_todos/blocs/filtered_todos/filtered_todos.dart';
import 'package:flutter_todos/models/models.dart';

class FilterButton extends StatelessWidget {
  final bool visible;

  FilterButton({this.visible, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultStyle = Theme.of(context).textTheme.body1;
    final activeStyle = Theme.of(context)
        .textTheme
        .body1
        .copyWith(color: Theme.of(context).accentColor);
    return BlocBuilder<FilteredTodosBloc, FilteredTodosState>(
        builder: (context, state) {
      final button = _Button(
        onSelected: (filter) {
          BlocProvider.of<FilteredTodosBloc>(context).add(FilterUpdated(filter));
        },
        activeFilter: state is FilteredTodosLoadSuccess
            ? state.activeFilter
            : VisibilityFilter.all,
        activeStyle: activeStyle,
        defaultStyle: defaultStyle,
      );
      return AnimatedOpacity(
        opacity: visible ? 1.0 : 0.0,
        duration: Duration(milliseconds: 150),
        child: visible ? button : IgnorePointer(child: button),
      );
    });
  }
}

class _Button extends StatelessWidget {
  const _Button({
    Key key,
    @required this.onSelected,
    @required this.activeFilter,
    @required this.activeStyle,
    @required this.defaultStyle,
  }) : super(key: key);

  final PopupMenuItemSelected<VisibilityFilter> onSelected;
  final VisibilityFilter activeFilter;
  final TextStyle activeStyle;
  final TextStyle defaultStyle;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<VisibilityFilter>(
      key: ArchSampleKeys.filterButton,
      tooltip: ArchSampleLocalizations.of(context).filterTodos,
      onSelected: onSelected,
      itemBuilder: (BuildContext context) => <PopupMenuItem<VisibilityFilter>>[
            PopupMenuItem<VisibilityFilter>(
              key: ArchSampleKeys.allFilter,
              value: VisibilityFilter.all,
              child: Text(
                ArchSampleLocalizations.of(context).showAll,
                style: activeFilter == VisibilityFilter.all
                    ? activeStyle
                    : defaultStyle,
              ),
            ),
            PopupMenuItem<VisibilityFilter>(
              key: ArchSampleKeys.activeFilter,
              value: VisibilityFilter.active,
              child: Text(
                ArchSampleLocalizations.of(context).showActive,
                style: activeFilter == VisibilityFilter.active
                    ? activeStyle
                    : defaultStyle,
              ),
            ),
            PopupMenuItem<VisibilityFilter>(
              key: ArchSampleKeys.completedFilter,
              value: VisibilityFilter.completed,
              child: Text(
                ArchSampleLocalizations.of(context).showCompleted,
                style: activeFilter == VisibilityFilter.completed
                    ? activeStyle
                    : defaultStyle,
              ),
            ),
          ],
      icon: Icon(Icons.filter_list),
    );
  }
}
```

`FilterButton` должна реагировать на изменения состояния в `FilteredTodosBloc`, поэтому он использует `BlocProvider` для доступа к `FilteredTodosBloc` из `BuildContext`. Затем он использует `BlocBuilder` для повторного рендеринга всякий раз, когда `FilteredTodosBloc` изменяет состояние.

Остальная часть реализации - чистый Flutter и там не так много работы, поэтому мы можем перейти к виджету `ExtraActions`.

### Дополнительные действия

> Подобно `FilterButton`, виджет `ExtraActions` отвечает за предоставление пользователю списка дополнительных опций: `Переключение задач` и `Очистка завершенных задач`.

Поскольку этот виджет не заботится о фильтрах, он будет взаимодействовать с `TodosBloc` вместо `FilteredTodosBloc`.

Давайте создадим модель `ExtraAction` в `models/extra_action.dart`.

```dart
enum ExtraAction { toggleAllComplete, clearCompleted }
```

И не забудьте экспортировать его из файла индекса `models/models.dart`.

Далее, давайте создадим `widgets/extra_actions.dart` и реализуем его.

```dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todos_app_core/todos_app_core.dart';
import 'package:flutter_todos/blocs/todos/todos.dart';
import 'package:flutter_todos/models/models.dart';
import 'package:flutter_todos/flutter_todos_keys.dart';

class ExtraActions extends StatelessWidget {
  ExtraActions({Key key}) : super(key: ArchSampleKeys.extraActionsButton);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodosBloc, TodosState>(
      builder: (context, state) {
        if (state is TodosLoadSuccess) {
          bool allComplete =
              (BlocProvider.of<TodosBloc>(context).state as TodosLoadSuccess)
                  .todos
                  .every((todo) => todo.complete);
          return PopupMenuButton<ExtraAction>(
            key: FlutterTodosKeys.extraActionsPopupMenuButton,
            onSelected: (action) {
              switch (action) {
                case ExtraAction.clearCompleted:
                  BlocProvider.of<TodosBloc>(context).add(ClearCompleted());
                  break;
                case ExtraAction.toggleAllComplete:
                  BlocProvider.of<TodosBloc>(context).add(ToggleAll());
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuItem<ExtraAction>>[
              PopupMenuItem<ExtraAction>(
                key: ArchSampleKeys.toggleAll,
                value: ExtraAction.toggleAllComplete,
                child: Text(
                  allComplete
                      ? ArchSampleLocalizations.of(context).markAllIncomplete
                      : ArchSampleLocalizations.of(context).markAllComplete,
                ),
              ),
              PopupMenuItem<ExtraAction>(
                key: ArchSampleKeys.clearCompleted,
                value: ExtraAction.clearCompleted,
                child: Text(
                  ArchSampleLocalizations.of(context).clearCompleted,
                ),
              ),
            ],
          );
        }
        return Container(key: FlutterTodosKeys.extraActionsEmptyContainer);
      },
    );
  }
}
```

Как и в случае с `FilterButton`, мы используем `BlocProvider` для доступа к `TodosBloc` из `BuildContext` и `BlocBuilder`, чтобы реагировать на изменения состояния в `TodosBloc`.

Основываясь на выбранном действии, виджет добавляет событие в `TodosBloc` либо о состоянии завершения `ToggleAll`, либо в `ClearCompleted`.

Далее мы рассмотрим виджет `TabSelector`.

### Селектор вкладок

> Виджет `TabSelector` отвечает за отображение вкладок в `BottomNavigationBar` и обработку пользовательского ввода.

Давайте создадим `widgets/tab_selector.dart` и реализуем его.

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:todos_app_core/todos_app_core.dart';
import 'package:flutter_todos/models/models.dart';

class TabSelector extends StatelessWidget {
  final AppTab activeTab;
  final Function(AppTab) onTabSelected;

  TabSelector({
    Key key,
    @required this.activeTab,
    @required this.onTabSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      key: ArchSampleKeys.tabs,
      currentIndex: AppTab.values.indexOf(activeTab),
      onTap: (index) => onTabSelected(AppTab.values[index]),
      items: AppTab.values.map((tab) {
        return BottomNavigationBarItem(
          icon: Icon(
            tab == AppTab.todos ? Icons.list : Icons.show_chart,
            key: tab == AppTab.todos
                ? ArchSampleKeys.todoTab
                : ArchSampleKeys.statsTab,
          ),
          title: Text(tab == AppTab.stats
              ? ArchSampleLocalizations.of(context).stats
              : ArchSampleLocalizations.of(context).todos),
        );
      }).toList(),
    );
  }
}
```

Вы можете видеть, что в этом виджете нет зависимости от блоков; он просто вызывает `onTabSelected`, когда вкладка выбрана, а также принимает в качестве входных данных `activeTab`, чтобы знать какая вкладка выбрана в данный момент.

Далее мы рассмотрим виджет `FilteredTodos`.

### Отфильтованные задачи

> Виджет `FilteredTodos` отвечает за отображение списка задач на основе текущего активного фильтра.

Создайте `widgets/filtered_todos.dart` и давайте реализуем это.

```dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todos_app_core/todos_app_core.dart';
import 'package:flutter_todos/blocs/blocs.dart';
import 'package:flutter_todos/widgets/widgets.dart';
import 'package:flutter_todos/screens/screens.dart';
import 'package:flutter_todos/flutter_todos_keys.dart';

class FilteredTodos extends StatelessWidget {
  FilteredTodos({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = ArchSampleLocalizations.of(context);

    return BlocBuilder<FilteredTodosBloc, FilteredTodosState>(
      builder: (context, state) {
        if (state is FilteredTodosLoadInProgress) {
          return LoadingIndicator(key: ArchSampleKeys.todosLoading);
        } else if (state is FilteredTodosLoadSuccess) {
          final todos = state.filteredTodos;
          return ListView.builder(
            key: ArchSampleKeys.todoList,
            itemCount: todos.length,
            itemBuilder: (BuildContext context, int index) {
              final todo = todos[index];
              return TodoItem(
                todo: todo,
                onDismissed: (direction) {
                  BlocProvider.of<TodosBloc>(context).add(TodoDeleted(todo));
                  Scaffold.of(context).showSnackBar(DeleteTodoSnackBar(
                    key: ArchSampleKeys.snackbar,
                    todo: todo,
                    onUndo: () =>
                        BlocProvider.of<TodosBloc>(context).add(TodoAdded(todo)),
                    localizations: localizations,
                  ));
                },
                onTap: () async {
                  final removedTodo = await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) {
                      return DetailsScreen(id: todo.id);
                    }),
                  );
                  if (removedTodo != null) {
                    Scaffold.of(context).showSnackBar(DeleteTodoSnackBar(
                      key: ArchSampleKeys.snackbar,
                      todo: todo,
                      onUndo: () => BlocProvider.of<TodosBloc>(context)
                          .add(TodoAdded(todo)),
                      localizations: localizations,
                    ));
                  }
                },
                onCheckboxChanged: (_) {
                  BlocProvider.of<TodosBloc>(context).add(
                    TodoUpdated(todo.copyWith(complete: !todo.complete)),
                  );
                },
              );
            },
          );
        } else {
          return Container(key: FlutterTodosKeys.filteredTodosEmptyContainer);
        }
      },
    );
  }
}
```

Как и предыдущие виджеты, которые мы написали, виджет `FilteredTodos` использует `BlocProvider` для доступа к блокам (в этом случае необходимы и `FilteredTodosBloc`, и `TodosBloc`).

?> `FilteredTodosBloc` необходим, чтобы помочь нам отобразить правильные задачи на основе текущего фильтра.

?> `TodosBloc` необходим для того, чтобы мы могли добавлять/удалять задачи в ответ на взаимодействие с пользователем, такое как пролистывание отдельной задачи.

Из виджета `FilteredTodos` пользователь может перейти к `DetailsScreen`, где можно редактировать или удалять выбранные задачи. Поскольку наш виджет `FilteredTodos` отображает список виджетов `TodoItem`, мы рассмотрим их далее.

### Элемент задачи

> `TodoItem` - это виджет без сохранения состояния, который отвечает за рендеринг одной задачи и обработку действий пользователя (нажатий/листаний).

Создайте `widgets/todo_item.dart` и давайте его создадим.

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:todos_app_core/todos_app_core.dart';
import 'package:flutter_todos/models/models.dart';

class TodoItem extends StatelessWidget {
  final DismissDirectionCallback onDismissed;
  final GestureTapCallback onTap;
  final ValueChanged<bool> onCheckboxChanged;
  final Todo todo;

  TodoItem({
    Key key,
    @required this.onDismissed,
    @required this.onTap,
    @required this.onCheckboxChanged,
    @required this.todo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ArchSampleKeys.todoItem(todo.id),
      onDismissed: onDismissed,
      child: ListTile(
        onTap: onTap,
        leading: Checkbox(
          key: ArchSampleKeys.todoItemCheckbox(todo.id),
          value: todo.complete,
          onChanged: onCheckboxChanged,
        ),
        title: Hero(
          tag: '${todo.id}__heroTag',
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Text(
              todo.task,
              key: ArchSampleKeys.todoItemTask(todo.id),
              style: Theme.of(context).textTheme.title,
            ),
          ),
        ),
        subtitle: todo.note.isNotEmpty
            ? Text(
                todo.note,
                key: ArchSampleKeys.todoItemNote(todo.id),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.subhead,
              )
            : null,
      ),
    );
  }
}
```

Опять же, обратите внимание, что в `TodoItem` нет специфичного для блока кода. Он просто выполняет рендеринг на основе задачи, которую мы передаем через конструктор и вызывает введенные функции обратного вызова всякий раз, когда пользователь взаимодействует с задачей.

Далее мы создадим `DeleteTodoSnackBar`.

### Информационный SnackBar

> `DeleteTodoSnackBar` отвечает за указание пользователю, что задача была удалена и позволяет пользователю отменить свое действие.

Создайте `widgets/delete_todo_snack_bar.dart` и давайте реализуем это.

```dart
import 'package:flutter/material.dart';
import 'package:todos_app_core/todos_app_core.dart';
import 'package:flutter_todos/models/models.dart';

class DeleteTodoSnackBar extends SnackBar {
  final ArchSampleLocalizations localizations;

  DeleteTodoSnackBar({
    Key key,
    @required Todo todo,
    @required VoidCallback onUndo,
    @required this.localizations,
  }) : super(
          key: key,
          content: Text(
            localizations.todoDeleted(todo.task),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          duration: Duration(seconds: 2),
          action: SnackBarAction(
            label: localizations.undo,
            onPressed: onUndo,
          ),
        );
}
```

К настоящему времени вы, вероятно, заметили шаблон: этот виджет также не имеет специфичного для блока кода. Он просто берет задачу для визуализации и вызывает функцию обратного вызова, называемую `onUndo`, если пользователь нажимает кнопку отмены.

Мы почти закончили; осталось только два виджета!

### Индикатор загрузки

> Виджет `LoadingIndicator` - это виджет без сохранения состояния, который отвечает за указание пользователю, что что-то выполняется.

Создайте `widgets/loading_indicator.dart` и давайте напишем это.

```dart
import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  LoadingIndicator({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}
```

Не очень много к обсуждению; мы просто используем `CircularProgressIndicator`, обернутый в виджет `Center` (опять же, нет специфичного для блока кода).

Наконец, нам нужно построить наш виджет `Stats`.

### Статистика

> Виджет `Stats` отвечает за отображение количества активных (выполняемых) задач по сравнению с выполненными.

Давайте создадим `widgets/stats.dart` и посмотрим на реализацию.

```dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todos_app_core/todos_app_core.dart';
import 'package:flutter_todos/blocs/stats/stats.dart';
import 'package:flutter_todos/widgets/widgets.dart';
import 'package:flutter_todos/flutter_todos_keys.dart';

class Stats extends StatelessWidget {
  Stats({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatsBloc, StatsState>(
      builder: (context, state) {
        if (state is StatsLoadInProgress) {
          return LoadingIndicator(key: FlutterTodosKeys.statsLoadInProgressIndicator);
        } else if (state is StatsLoadSuccess) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    ArchSampleLocalizations.of(context).completedTodos,
                    style: Theme.of(context).textTheme.title,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 24.0),
                  child: Text(
                    '${state.numCompleted}',
                    key: ArchSampleKeys.statsNumCompleted,
                    style: Theme.of(context).textTheme.subhead,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    ArchSampleLocalizations.of(context).activeTodos,
                    style: Theme.of(context).textTheme.title,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 24.0),
                  child: Text(
                    "${state.numActive}",
                    key: ArchSampleKeys.statsNumActive,
                    style: Theme.of(context).textTheme.subhead,
                  ),
                )
              ],
            ),
          );
        } else {
          return Container(key: FlutterTodosKeys.emptyStatsContainer);
        }
      },
    );
  }
}
```

Мы обращаемся к `StatsBloc` с помощью `BlocProvider` и `BlocBuilder` для перестройки в ответ на изменения состояния `StatsBloc`.

## Собираем все вместе

Давайте создадим `main.dart` и виджет `TodosApp`. Нам нужно создать функцию `main` и запустить `TodosApp`.

```dart
void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();
  runApp(
    BlocProvider(
      create: (context) {
        return TodosBloc(
          todosRepository: const TodosRepositoryFlutter(
            fileStorage: const FileStorage(
              '__flutter_bloc_app__',
              getApplicationDocumentsDirectory,
            ),
          ),
        )..add(TodosLoaded());
      },
      child: TodosApp(),
    ),
  );
}
```

?> **Примечание:** Мы устанавливаем делегата нашего `BlocSupervisor` в `SimpleBlocDelegate`, который мы создали ранее, чтобы мы могли подключиться ко всем переходам и ошибкам.

?> **Примечание:** Мы также оборачиваем наш виджет `TodosApp` в `BlocProvider`, который управляет инициализацией, закрытием и предоставлением `TodosBloc` для всего нашего дерева виджетов из [flutter_bloc](https://pub.dev/packages/flutter_bloc). Мы немедленно добавляем событие `TodosLoaded`, чтобы запросить последние задачи.

Далее давайте реализуем наш виджет `TodosApp`.

```dart
class TodosApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: FlutterBlocLocalizations().appTitle,
      theme: ArchSampleTheme.theme,
      localizationsDelegates: [
        ArchSampleLocalizationsDelegate(),
        FlutterBlocLocalizationsDelegate(),
      ],
      routes: {
        ArchSampleRoutes.home: (context) {
          return MultiBlocProvider(
            providers: [
              BlocProvider<TabBloc>(
                create: (context) => TabBloc(),
              ),
              BlocProvider<FilteredTodosBloc>(
                create: (context) => FilteredTodosBloc(
                  todosBloc: BlocProvider.of<TodosBloc>(context),
                ),
              ),
              BlocProvider<StatsBloc>(
                create: (context) => StatsBloc(
                  todosBloc: BlocProvider.of<TodosBloc>(context),
                ),
              ),
            ],
            child: HomeScreen(),
          );
        },
        ArchSampleRoutes.addTodo: (context) {
          return AddEditScreen(
            key: ArchSampleKeys.addTodoScreen,
            onSave: (task, note) {
              BlocProvider.of<TodosBloc>(context).add(
                TodoAdded(Todo(task, note: note)),
              );
            },
            isEditing: false,
          );
        },
      },
    );
  }
}
```

`TodosApp` является `StatelessWidget`, который обращается к предоставленному `TodosBloc` через `BuildContext`.

`TodosApp` имеет два маршрута:

- `Home` - отображает`HomeScreen`
- `TodoAdded` - отображает `AddEditScreen` с `isEditing`, установленным в `false`.

`TodosApp` также делает `TabBloc`, `FilteredTodosBloc` и `StatsBloc` доступными для виджетов в своем поддереве с помощью виджета `MultiBlocProvider` из [flutter_bloc](https://pub.dev/packages/flutter_bloc)

```dart
MultiBlocProvider(
  providers: [
    BlocProvider<TabBloc>(
      create: (context) => TabBloc(),
    ),
    BlocProvider<FilteredTodosBloc>(
      create: (context) => FilteredTodosBloc(todosBloc: todosBloc),
    ),
    BlocProvider<StatsBloc>(
      create: (context) => StatsBloc(todosBloc: todosBloc),
    ),
  ],
  child: HomeScreen(),
);
```

эквивалентно написанию

```dart
BlocProvider<TabBloc>(
  create: (context) => TabBloc(),
  child: BlocProvider<FilteredTodosBloc>(
    create: (context) => FilteredTodosBloc(todosBloc: todosBloc),
    child: BlocProvider<StatsBloc>(
      create: (context) => StatsBloc(todosBloc: todosBloc),
      child: Scaffold(...),
    ),
  ),
);
```

Вы можете видеть как использование `MultiBlocProvider` помогает снизить уровни вложенности и облегчает чтение и сопровождение кода.

Весь файл `main.dart` должен выглядеть так:

```dart
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todos_repository_simple/todos_repository_simple.dart';
import 'package:todos_app_core/todos_app_core.dart';
import 'package:flutter_todos/localization.dart';
import 'package:flutter_todos/blocs/blocs.dart';
import 'package:flutter_todos/models/models.dart';
import 'package:flutter_todos/screens/screens.dart';

void main() {
  // BlocSupervisor oversees Blocs and delegates to BlocDelegate.
  // We can set the BlocSupervisor's delegate to an instance of `SimpleBlocDelegate`.
  // This will allow us to handle all transitions and errors in SimpleBlocDelegate.
  BlocSupervisor.delegate = SimpleBlocDelegate();
  runApp(
    BlocProvider(
      create: (context) {
        return TodosBloc(
          todosRepository: const TodosRepositoryFlutter(
            fileStorage: const FileStorage(
              '__flutter_bloc_app__',
              getApplicationDocumentsDirectory,
            ),
          ),
        )..add(TodosLoaded());
      },
      child: TodosApp(),
    ),
  );
}

class TodosApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: FlutterBlocLocalizations().appTitle,
      theme: ArchSampleTheme.theme,
      localizationsDelegates: [
        ArchSampleLocalizationsDelegate(),
        FlutterBlocLocalizationsDelegate(),
      ],
      routes: {
        ArchSampleRoutes.home: (context) {
          return MultiBlocProvider(
            providers: [
              BlocProvider<TabBloc>(
                create: (context) => TabBloc(),
              ),
              BlocProvider<FilteredTodosBloc>(
                create: (context) => FilteredTodosBloc(
                  todosBloc: BlocProvider.of<TodosBloc>(context),
                ),
              ),
              BlocProvider<StatsBloc>(
                create: (context) => StatsBloc(
                  todosBloc: BlocProvider.of<TodosBloc>(context),
                ),
              ),
            ],
            child: HomeScreen(),
          );
        },
        ArchSampleRoutes.addTodo: (context) {
          return AddEditScreen(
            key: ArchSampleKeys.addTodoScreen,
            onSave: (task, note) {
              BlocProvider.of<TodosBloc>(context).add(
                TodoAdded(Todo(task, note: note)),
              );
            },
            isEditing: false,
          );
        },
      },
    );
  }
}
```

Вот и все, что нужно сделать! Теперь мы успешно реализовали приложение todos в Flutter, используя пакеты [bloc](https://pub.dev/packages/bloc) и [flutter_bloc](https://pub.dev/packages/flutter_bloc) и мы успешно отделили наш уровень представления от нашей бизнес логики.

Полный исходный код этого примера можно найти [здесь](https://github.com/felangel/Bloc/tree/master/examples/flutter_todos).

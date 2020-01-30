# Flutter Firestore задачи

![advanced](https://img.shields.io/badge/level-advanced-red.svg)

> В следующем руководстве мы создадим реактивное приложение Todos, которое подключается к Firestore. Мы построим все на основе примера [flutter todos](ru/fluttertodostutorial.md), но не будем вдаваться в подробности пользовательского интерфейса, поскольку они будут одинаковыми.

![demo](../assets/gifs/flutter_firestore_todos.gif)

Единственное, что мы мы сделаем - это рефакторинг существующего [примера todos](https://github.com/felangel/Bloc/tree/master/examples/flutter_todos) на уровне хранилища и частичто слоя блока.

Мы начнем со слоя репозитория с `TodosRepository`.

## Todos хранилище

Создайте новый пакет на корневом уровне нашего приложения под названием `todos_repository`.

?> **Примечание:** Причина, по которой хранилище является автономным пакетом состоит в том, чтобы проиллюстрировать, что хранилище должно быть отделено от приложения и может быть повторно использовано в нескольких приложениях.

Внутри `todos_repository` создайте следующую структуру папок/файлов.

```sh
├── lib
│   ├── src
│   │   ├── entities
│   │   │   ├── entities.dart
│   │   │   └── todo_entity.dart
│   │   ├── models
│   │   │   ├── models.dart
│   │   │   └── todo.dart
│   │   ├── todos_repository.dart
│   │   └── firebase_todos_repository.dart
│   └── todos_repository.dart
└── pubspec.yaml
```

### Зависимости

`pubspec.yaml` должен выглядеть так:

```yaml
name: todos_repository

version: 1.0.0+1

environment:
  sdk: '>=2.6.0 <3.0.0'

dependencies:
  flutter:
    sdk: flutter
  cloud_firestore: ^0.12.10+2
  rxdart: ^0.23.0
  equatable: ^1.0.0
  firebase_core: ^0.4.0+8
```

?> **Примечание:** Мы сразу видим, что наш `todos_repository` зависит от `firebase_core` и `cloud_firestore`.

### Корневой пакет

`Todos_repository.dart` непосредственно внутри `lib` должен выглядеть следующим образом:

```dart
library todos_repository;

export 'src/firebase_todos_repository.dart';
export 'src/models/models.dart';
export 'src/todos_repository.dart';
```

?> Здесь экспортируются все наши публичные классы. Если мы хотим, чтобы класс был закрытым для пакета, мы обязательно должны его опустить.

### Сущности

> Объекты представляют данные, предоставленные нашим поставщиком данных.

Файл `entity.dart` - это индексный файл, который экспортирует `todo_entity.dart`.
файл.

```dart
export 'todo_entity.dart';
```

`TodoEntity` является представлением нашего `Todo` внутри Firestore. Создайте `todo_entity.dart` и давайте его реализуем.

```dart
// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class TodoEntity extends Equatable {
  final bool complete;
  final String id;
  final String note;
  final String task;

  const TodoEntity(this.task, this.id, this.note, this.complete);

  Map<String, Object> toJson() {
    return {
      "complete": complete,
      "task": task,
      "note": note,
      "id": id,
    };
  }

  @override
  List<Object> get props => [complete, id, note, task];

  @override
  String toString() {
    return 'TodoEntity { complete: $complete, task: $task, note: $note, id: $id }';
  }

  static TodoEntity fromJson(Map<String, Object> json) {
    return TodoEntity(
      json["task"] as String,
      json["id"] as String,
      json["note"] as String,
      json["complete"] as bool,
    );
  }

  static TodoEntity fromSnapshot(DocumentSnapshot snap) {
    return TodoEntity(
      snap.data['task'],
      snap.documentID,
      snap.data['note'],
      snap.data['complete'],
    );
  }

  Map<String, Object> toDocument() {
    return {
      "complete": complete,
      "task": task,
      "note": note,
    };
  }
}
```

`ToJson` и `fromJson` являются стандартными методами для преобразования в/из json.
`FromSnapshot` и `toDocument` относятся к Firestore.

?> **Примечание:** Firestore автоматически создаст идентификатор для документа, когда мы его вставим. Поэтому мы не будем дублировать данные, сохраняя идентификатор в дополнительном поле.

### Модели

> Модели будут содержать простые классы dart, с которыми мы будем работать в нашем приложении Flutter. Разделение между моделями и сущностями позволяет нам в любое время переключать поставщика данных и нам нужно только изменить преобразования `toEntity` и `fromEntity` на уровне модели.

`models.dart` - это еще один индексный файл.
Внутри `todo.dart` давайте поместим следующий код.

```dart
import 'package:meta/meta.dart';
import '../entities/entities.dart';

@immutable
class Todo {
  final bool complete;
  final String id;
  final String note;
  final String task;

  Todo(this.task, {this.complete = false, String note = '', String id})
      : this.note = note ?? '',
        this.id = id;

  Todo copyWith({bool complete, String id, String note, String task}) {
    return Todo(
      task ?? this.task,
      complete: complete ?? this.complete,
      id: id ?? this.id,
      note: note ?? this.note,
    );
  }

  @override
  int get hashCode =>
      complete.hashCode ^ task.hashCode ^ note.hashCode ^ id.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Todo &&
          runtimeType == other.runtimeType &&
          complete == other.complete &&
          task == other.task &&
          note == other.note &&
          id == other.id;

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
      id: entity.id,
    );
  }
}

```

### Хранидище задач

> `TodosRepository` - это наш абстрактный базовый класс, который мы можем расширять всякий раз, когда хотим интегрироваться с другим `TodosProvider`.

Давайте создадим `todos_repository.dart`

```dart
import 'dart:async';

import 'package:todos_repository/todos_repository.dart';

abstract class TodosRepository {
  Future<void> addNewTodo(Todo todo);

  Future<void> deleteTodo(Todo todo);

  Stream<List<Todo>> todos();

  Future<void> updateTodo(Todo todo);
}
```

?> **Примечание:** Поскольку у нас есть интерфейс, теперь легко добавить другой тип хранилища данных. Если, например, мы хотим использовать что-то вроде [sembast](https://pub.dev/flutter/packages?q=sembast), все, что нам нужно сделать - это создать отдельный репозиторий для обработки кода, специфичного для sembast.

#### Firebase хранилище задач

> `FirebaseTodosRepository` управляет интеграцией с Firestore и реализует наш интерфейс `TodosRepository`.

Давайте откроем `firebase_todos_repository.dart` и реализуем его!

```dart
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todos_repository/todos_repository.dart';
import 'entities/entities.dart';

class FirebaseTodosRepository implements TodosRepository {
  final todoCollection = Firestore.instance.collection('todos');

  @override
  Future<void> addNewTodo(Todo todo) {
    return todoCollection.add(todo.toEntity().toDocument());
  }

  @override
  Future<void> deleteTodo(Todo todo) async {
    return todoCollection.document(todo.id).delete();
  }

  @override
  Stream<List<Todo>> todos() {
    return todoCollection.snapshots().map((snapshot) {
      return snapshot.documents
          .map((doc) => Todo.fromEntity(TodoEntity.fromSnapshot(doc)))
          .toList();
    });
  }

  @override
  Future<void> updateTodo(Todo update) {
    return todoCollection
        .document(update.id)
        .updateData(update.toEntity().toDocument());
  }
}
```

Вот и все для нашего `TodosRepository`, теперь нам нужно создать простой `UserRepository` для управления аутентификацией наших пользователей.

## Хранилище пользователей

Создайте новый пакет на корневом уровне нашего приложения под названием `user_repository`.

Внутри `user_repository` создайте следующую структуру папок/файлов.

```sh
├── lib
│   ├── src
│   │   └── user_repository.dart
│   └── user_repository.dart
└── pubspec.yaml
```

### Зависимости

`Pubspec.yaml` должен выглядеть так:

```yaml
name: user_repository

version: 1.0.0+1

environment:
  sdk: '>=2.6.0 <3.0.0'

dependencies:
  flutter:
    sdk: flutter
  firebase_auth: ^0.15.0+1
```

?> **Примечание:** Мы можем сразу увидеть, что наш `user_repository` зависит от `firebase_auth`.

### Корневой пакет

`user_repository.dart` непосредственно внутри `lib` должен выглядеть следующим образом:

```dart
library user_repository;

export 'src/user_repository.dart';
```

### Хранилище пользователей

> `UserRepository` - это наш абстрактный базовый класс, который мы можем расширять всякий раз, когда хотим интегрироваться с другим провайдером.

Давайте создадим `user_repository.dart`

```dart
abstract class UserRepository {
  Future<bool> isAuthenticated();

  Future<void> authenticate();

  Future<String> getUserId();
}
```

#### Firebase хранилище пользователей

> `FirebaseUserRepository` управляет интеграцией с Firebase и реализует наш интерфейс `UserRepository`.

Давайте откроем `firebase_user_repository.dart` и реализуем его!

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:user_repository/user_repository.dart';

class FirebaseUserRepository implements UserRepository {
  final FirebaseAuth _firebaseAuth;

  FirebaseUserRepository({FirebaseAuth firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  Future<bool> isAuthenticated() async {
    final currentUser = await _firebaseAuth.currentUser();
    return currentUser != null;
  }

  Future<void> authenticate() {
    return _firebaseAuth.signInAnonymously();
  }

  Future<String> getUserId() async {
    return (await _firebaseAuth.currentUser()).uid;
  }
}
```

Вот и все для нашего `UserRepository`. Далее нам нужно настроить приложение Flutter для использования наших новых репозиториев.

## Flutter приложение

### Настройка

Давайте создадим новое приложение Flutter под названием `flutter_firestore_todos`. Мы можем заменить содержимое `pubspec.yaml` следующим:

```yaml
name: flutter_firestore_todos
description: A new Flutter project.

version: 1.0.0+1

environment:
  sdk: '>=2.6.0 <3.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^3.1.0
  todos_repository:
    path: todos_repository
  user_repository:
    path: user_repository
  equatable: ^1.0.0

flutter:
  uses-material-design: true
```

?> **Примечание:** Мы добавляем `todos_repository` и `user_repository` в качестве внешних зависимостей.

### Auth блок

Поскольку наши пользователи должны иметь возможность войти в систему, нам нужно создать `AuthenticationBloc`.

?> Если вы еще не ознакомились с [Flutter Firebase Login](ru/flutterfirebaselogintutorial.md), я настоятельно рекомендую проверить его сейчас, потому что мы просто собираемся повторно использовать тот же `AuthenticationBloc`.

#### Auth события

```dart
import 'package:equatable/equatable.dart';

abstract class AuthenticationEvent extends Equatable {}

class AppStarted extends AuthenticationEvent {
  @override
  List<Object> get props => [];
}
```

#### Auth состояния

```dart
import 'package:equatable/equatable.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object> get props => [];
}

class Uninitialized extends AuthenticationState {}

class Authenticated extends AuthenticationState {
  final String userId;

  const Authenticated(this.userId);

  @override
  List<Object> get props => [userId];

  @override
  String toString() => 'Authenticated { userId: $userId }';
}

class Unauthenticated extends AuthenticationState {}
```

#### Auth блок

```dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:user_repository/user_repository.dart';
import 'package:flutter_firestore_todos/blocs/authentication_bloc/bloc.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository _userRepository;

  AuthenticationBloc({@required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository;

  @override
  AuthenticationState get initialState => Uninitialized();

  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {
    if (event is AppStarted) {
      yield* _mapAppStartedToState();
    }
  }

  Stream<AuthenticationState> _mapAppStartedToState() async* {
    try {
      final isSignedIn = await _userRepository.isAuthenticated();
      if (!isSignedIn) {
        await _userRepository.authenticate();
      }
      final userId = await _userRepository.getUserId();
      yield Authenticated(userId);
    } catch (_) {
      yield Unauthenticated();
    }
  }
}
```

Теперь, когда `AuthenticationBloc` закончен, нам нужно изменить `TodosBloc` из исходного [пособия по Todos](ru/fluttertodostutorial.md), чтобы использовать новый `TodosRepository`.

### Todos блок

```dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:flutter_firestore_todos/blocs/todos/todos.dart';
import 'package:todos_repository/todos_repository.dart';

class TodosBloc extends Bloc<TodosEvent, TodosState> {
  final TodosRepository _todosRepository;
  StreamSubscription _todosSubscription;

  TodosBloc({@required TodosRepository todosRepository})
      : assert(todosRepository != null),
        _todosRepository = todosRepository;

  @override
  TodosState get initialState => TodosLoading();

  @override
  Stream<TodosState> mapEventToState(TodosEvent event) async* {
    if (event is LoadTodos) {
      yield* _mapLoadTodosToState();
    } else if (event is AddTodo) {
      yield* _mapAddTodoToState(event);
    } else if (event is UpdateTodo) {
      yield* _mapUpdateTodoToState(event);
    } else if (event is DeleteTodo) {
      yield* _mapDeleteTodoToState(event);
    } else if (event is ToggleAll) {
      yield* _mapToggleAllToState();
    } else if (event is ClearCompleted) {
      yield* _mapClearCompletedToState();
    } else if (event is TodosUpdated) {
      yield* _mapTodosUpdateToState(event);
    }
  }

  Stream<TodosState> _mapLoadTodosToState() async* {
    _todosSubscription?.cancel();
    _todosSubscription = _todosRepository.todos().listen(
          (todos) => add(TodosUpdated(todos)),
        );
  }

  Stream<TodosState> _mapAddTodoToState(AddTodo event) async* {
    _todosRepository.addNewTodo(event.todo);
  }

  Stream<TodosState> _mapUpdateTodoToState(UpdateTodo event) async* {
    _todosRepository.updateTodo(event.updatedTodo);
  }

  Stream<TodosState> _mapDeleteTodoToState(DeleteTodo event) async* {
    _todosRepository.deleteTodo(event.todo);
  }

  Stream<TodosState> _mapToggleAllToState() async* {
    final currentState = state;
    if (currentState is TodosLoaded) {
      final allComplete = currentState.todos.every((todo) => todo.complete);
      final List<Todo> updatedTodos = currentState.todos
          .map((todo) => todo.copyWith(complete: !allComplete))
          .toList();
      updatedTodos.forEach((updatedTodo) {
        _todosRepository.updateTodo(updatedTodo);
      });
    }
  }

  Stream<TodosState> _mapClearCompletedToState() async* {
    final currentState = state;
    if (currentState is TodosLoaded) {
      final List<Todo> completedTodos =
          currentState.todos.where((todo) => todo.complete).toList();
      completedTodos.forEach((completedTodo) {
        _todosRepository.deleteTodo(completedTodo);
      });
    }
  }

  Stream<TodosState> _mapTodosUpdateToState(TodosUpdated event) async* {
    yield TodosLoaded(event.todos);
  }

  @override
  Future<void> close() {
    _todosSubscription?.cancel();
    return super.close();
  }
}
```

Основное различие между новым `TodosBloc` и оригинальным заключается в том, что теперь все основано на `Stream`, а не на `Future`.

```dart
Stream<TodosState> _mapLoadTodosToState() async* {
  _todosSubscription?.cancel();
  _todosSubscription = _todosRepository.todos().listen(
      (todos) => add(TodosUpdated(todos)),
    );
}
```

?> Когда мы загружаем задачи, мы подписываемся на `TodosRepository` и каждый раз, когда появляется новая задача, мы добавляем событие `TodosUpdated`. Затем мы обрабатываем все `TodosUpdates` через:

```dart
Stream<TodosState> _mapTodosUpdateToState(TodosUpdated event) async* {
  yield TodosLoaded(event.todos);
}
```

## Собираем все вместе

Последнее, что нам нужно изменить, это наш `main.dart`.

```dart
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firestore_todos/blocs/authentication_bloc/bloc.dart';
import 'package:todos_repository/todos_repository.dart';
import 'package:flutter_firestore_todos/blocs/blocs.dart';
import 'package:flutter_firestore_todos/screens/screens.dart';
import 'package:user_repository/user_repository.dart';

void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();
  runApp(TodosApp());
}

class TodosApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthenticationBloc>(
          create: (context) {
            return AuthenticationBloc(
              userRepository: FirebaseUserRepository(),
            )..add(AppStarted());
          },
        ),
        BlocProvider<TodosBloc>(
          create: (context) {
            return TodosBloc(
              todosRepository: FirebaseTodosRepository(),
            )..add(LoadTodos());
          },
        )
      ],
      child: MaterialApp(
        title: 'Firestore Todos',
        routes: {
          '/': (context) {
            return BlocBuilder<AuthenticationBloc, AuthenticationState>(
              builder: (context, state) {
                if (state is Authenticated) {
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
                }
                if (state is Unauthenticated) {
                  return Center(
                    child: Text('Could not authenticate with Firestore'),
                  );
                }
                return Center(child: CircularProgressIndicator());
              },
            );
          },
          '/addTodo': (context) {
            return AddEditScreen(
              onSave: (task, note) {
                BlocProvider.of<TodosBloc>(context).add(
                  AddTodo(Todo(task, note: note)),
                );
              },
              isEditing: false,
            );
          },
        },
      ),
    );
  }
}
```

Основным отличием, которое следует отметить является тот факт, что мы завернули все наше приложение в `MultiBlocProvider`, который инициализирует и предоставляет `AuthenticationBloc` и `TodosBloc`. Затем мы только визуализируем приложение todos если для `AuthenticationState` установлено `Authenticated` с использованием `BlocBuilder`. Все остальное остается тем же, что и в предыдущем `учебнике todos`.

Вот и все, что нужно сделать! Теперь мы успешно внедрили приложение todos для Firestore во Flutter, используя пакеты [bloc](https://pub.dev/packages/bloc) и [flutter_bloc](https://pub.dev/packages/flutter_bloc) и мы успешно отделили уровень представления от бизнес-логики, а также создали приложение, которое обновляется в режиме реального времени.

Полный исходный код этого примера можно найти [здесь](https://github.com/felangel/Bloc/tree/master/examples/flutter_firestore_todos).

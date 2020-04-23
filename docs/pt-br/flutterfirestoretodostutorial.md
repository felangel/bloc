# Tutorial Flutter Firestore Todos

![avançado](https://img.shields.io/badge/level-advanced-red.svg)

> No tutorial a seguir, criaremos um aplicativo Todos reativo que se conecta ao Firestore. Vamos construir no topo do exemplo [flutter todos](https://bloclibrary.dev/#/fluttertodostutorial) para não entrarmos na interface do usuário, pois tudo será o mesmo.

![demo](../assets/gifs/flutter_firestore_todos.gif)

As únicas coisas que vamos refatorar em nosso exemplo de [todos](https://github.com/felangel/Bloc/tree/master/examples/flutter_todos) são a camada de repositório e as partes da camada de bloc.

Começaremos na camada de repositório com o `TodosRepository`.

## Todos Repository

Crie um novo pacote no nível raiz do nosso aplicativo chamado `todos_repository`.

?> **Nota:** O motivo para tornar o repositório um pacote independente é ilustrar que o repositório deve ser dissociado do aplicativo e pode ser reutilizado em vários aplicativos.

Dentro do nosso `todos_repository`, crie a seguinte estrutura de pastas/arquivos.

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

### Dependências

O `pubspec.yaml` deve se parecer com:

```yaml
name: todos_repository

version: 1.0.0+1

environment:
  sdk: ">=2.6.0 <3.0.0"

dependencies:
  flutter:
    sdk: flutter
  cloud_firestore: ^0.12.10+2
  rxdart: ^0.23.0
  equatable: ^1.0.0
  firebase_core: ^0.4.0+8
```

?> **Nota:** Podemos ver imediatamente que nosso `todos_repository` depende de `firebase_core` e `cloud_firestore`.

### Pacote Raiz

O `todos_repository.dart` diretamente dentro do `lib` deve se parecer com:

```dart
library todos_repository;

export 'src/firebase_todos_repository.dart';
export 'src/models/models.dart';
export 'src/todos_repository.dart';
```

?> É aqui que todas as nossas classes públicas são exportadas. Se queremos que uma classe seja privada do pacote, devemos nos omitir.

### Entidades

> Entities represent the data provided by our data provider.

O arquivo `entity.dart` é um arquivo barrel que exporta o arquivo` todo_entity.dart`.

```dart
export 'todo_entity.dart';
```

Nosso `TodoEntity` é a representação do nosso `Todo` dentro do Firestore.

Crie `todo_entity.dart` e vamos implementá-lo.

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

O `toJson` e o `fromJson` são métodos padrão para converter de/para json.
O `fromSnapshot` e o `toDocument` são específicos do Firestore.

?> **Nota:** O Firestore criará automaticamente o ID do documento quando o inserirmos. Como tal, não queremos duplicar dados armazenando o id em um campo de id.

### Modelos

> Os modelos conterão classes dart simples com as quais trabalharemos em nosso aplicativo Flutter. A separação entre modelos e entidades nos permite alternar nosso provedor de dados a qualquer momento e apenas precisamos alterar a conversão `toEntity` e `fromEntity` em nossa camada de modelo.

Nosso `models.dart` é outro arquivo barrel.
Dentro do `todo.dart` vamos colocar o seguinte código.

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

### Repositório Todos

> `TodosRepository` é a nossa classe base abstrata que podemos estender sempre que quisermos integrar com um` TodosProvider` diferente.

Vamos criar `todos_repository.dart`

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

?> **Nota:** Como temos essa interface, é fácil adicionar outro tipo de armazenamento de dados. Se, por exemplo, quisermos usar algo como [sembast](https://pub.dev/flutter/packages?q=sembast), tudo o que precisamos fazer é criar um repositório separado para lidar com o código específico da sembast.

#### Repositório Firebase Todos

> `FirebaseTodosRepository` gerencia a integração com o Firestore e implementa nossa interface `TodosRepository`.

Vamos abrir o `firebase_todos_repository.dart` e implementá-lo!

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

É isso para o nosso `TodosRepository`, depois precisamos criar um simples `UserRepository` para gerenciar a autenticação de nossos usuários.

## Repositório User

Crie um novo pacote na raiz do nosso aplicativo chamado `user_repository`.

Dentro do nosso `user_repository`, crie a seguinte estrutura de pastas/arquivos.

```sh
├── lib
│   ├── src
│   │   └── user_repository.dart
│   └── user_repository.dart
└── pubspec.yaml
```

### Dependencies

O `pubspec.yaml` deve se parecer com:

```yaml
name: user_repository

version: 1.0.0+1

environment:
  sdk: ">=2.6.0 <3.0.0"

dependencies:
  flutter:
    sdk: flutter
  firebase_auth: ^0.15.0+1
```

?> **Nota:** Podemos ver imediatamente que nosso `user_repository` depende de `firebase_auth`.

### Package Raiz

O `user_repository.dart` diretamente dentro de `lib` deve se parecer com:

```dart
library user_repository;

export 'src/user_repository.dart';
```

### Repositório User

> `UserRepository` é nossa classe base abstrata que podemos estender sempre que quisermos integrar com um provedor diferente`.

Vamos criar `user_repository.dart`

```dart
abstract class UserRepository {
  Future<bool> isAuthenticated();

  Future<void> authenticate();

  Future<String> getUserId();
}
```

#### Firebase User Repository

> `FirebaseUserRepository` gerencia a integração com o Firebase e implementa nossa interface `UserRepository`.

Vamos abrir o `firebase_user_repository.dart` e implementá-lo!

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

É isso para o nosso `UserRepository`, depois precisamos configurar nosso aplicativo Flutter para usar nossos novos repositórios.

## Flutter App

### Setup

Vamos criar um novo aplicativo Flutter chamado `flutter_firestore_todos`. Podemos substituir o conteúdo do `pubspec.yaml` pelo seguinte:

```yaml
name: flutter_firestore_todos
description: A new Flutter project.

version: 1.0.0+1

environment:
  sdk: ">=2.6.0 <3.0.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^4.0.0
  todos_repository:
    path: todos_repository
  user_repository:
    path: user_repository
  equatable: ^1.0.0

flutter:
  uses-material-design: true
```

?> **Nota:** Estamos adicionando nosso `todos_repository` e `user_repository` como dependências externas.

### Authentication Bloc

Como queremos poder entrar em nossos usuários, precisamos criar um `AuthenticationBloc`.

?> Se você ainda não viu o [tutorial de login do flutter firebase](https://bloclibrary.dev/#/flutterfirebaselogintutorial), eu recomendo dar uma olhada agora, porque simplesmente vamos reutilizar o mesmo `AuthenticationBloc`.

#### Authentication Events

```dart
import 'package:equatable/equatable.dart';

abstract class AuthenticationEvent extends Equatable {}

class AppStarted extends AuthenticationEvent {
  @override
  List<Object> get props => [];
}
```

#### Authentication States

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

#### Authentication Bloc

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

Agora que nosso `AuthenticationBloc` foi concluído, precisamos modificar o `TodosBloc` do [Todos Tutorial](https://bloclibrary.dev/#/fluttertodostutorial) para consumir o novo `TodosRepository`.

### Todos Bloc

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

A principal diferença entre o nosso novo `TodosBloc` e o original está no fato de que no novo tudo é baseado em `Stream` e não em `Future`.

```dart
Stream<TodosState> _mapLoadTodosToState() async* {
  _todosSubscription?.cancel();
  _todosSubscription = _todosRepository.todos().listen(
      (todos) => add(TodosUpdated(todos)),
    );
}
```

?> Quando carregamos nosso Todos, estamos assinando o `TodosRepository` e toda vez que um novo Todo entra, adicionamos um evento `TodosUpdated`. Em seguida, lidamos com todos os `TodosUpdates` via:

```dart
Stream<TodosState> _mapTodosUpdateToState(TodosUpdated event) async* {
  yield TodosLoaded(event.todos);
}
```

## Juntando tudo

A última coisa que precisamos modificar é o nosso `main.dart`.

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

As principais diferenças a serem observadas são o fato de envolvermos todo o nosso aplicativo em um `MultiBlocProvider` que inicializa e fornece o `AuthenticationBloc` e o `TodosBloc`. Em seguida, renderizamos o aplicativo Todos apenas se o `AuthenticationState` for `Authenticated` usando o `BlocBuilder`. Todo o resto permanece o mesmo que no `todos tutorial` anterior.

Isso é tudo! Agora implementamos com sucesso um aplicativo firestore todos no flutter usando os pacotes [bloc](https://pub.dev/packages/bloc) e [flutter_bloc](https://pub.dev/packages/flutter_bloc) e nós separamos com êxito a camada de apresentação da lógica de negócios e também criamos um aplicativo que é atualizado em tempo real.

O código fonte completo deste exemplo pode ser encontrada [aqui](https://github.com/felangel/Bloc/tree/master/examples/flutter_firestore_todos).

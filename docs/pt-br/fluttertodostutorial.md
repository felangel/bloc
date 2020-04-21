# Flutter Todos Tutorial

![avançado](https://img.shields.io/badge/level-advanced-red.svg)

> No tutorial a seguir, criaremos um aplicativo de Todos com Flutter usando a biblioteca Bloc.

![demo](../assets/gifs/flutter_todos.gif)

## Setup

Começaremos criando um novo projeto Flutter

```bash
flutter create flutter_todos
```

Podemos então substituir o conteúdo de `pubspec.yaml` por

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

e instale todas as dependências

```bash
flutter packages get
```

?> **Nota:** Substituímos algumas dependências porque as reutilizaremos em [Exemplos de arquitetura de Brian Egan](https://github.com/brianegan/flutter_architecture_samples).

## App Keys

Antes de pularmos para o código do aplicativo, vamos criar `flutter_todos_keys.dart`. Este arquivo conterá chaves que usaremos para identificar exclusivamente widgets importantes. Posteriormente, podemos escrever testes que encontram widgets baseados em chaves.

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

Iremos fazer referência a essas chaves no restante do tutorial.

?> **Nota:** Você pode verificar os testes de integração para o aplicativo [aqui](https://github.com/brianegan/flutter_architecture_samples/tree/master/integration_tests). You can also check out unit and widget tests [here](https://github.com/brianegan/flutter_architecture_samples/tree/master/bloc_library/test).

## Localização

Um último conceito que abordaremos antes de entrar no aplicativo em si é a localização. Crie `localization.dart` e criaremos a base para o suporte em vários idiomas.

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

Agora podemos importar e fornecer nosso `FlutterBlocLocalizationsDelegate` ao nosso `MaterialApp` (mais adiante neste tutorial).

Para mais informações sobre localização, consulte a [documentação oficial](https://flutter.dev/docs/development/accessibility-and-localization/internationalization).

## Todos Repository

Neste tutorial, não entraremos nos detalhes da implementação do `TodosRepository` porque ele foi implementado por [Brian Egan](https://github.com/brianegan) e é compartilhado entre todos os [Exemplos](https://github.com/brianegan/flutter_architecture_samples). Em um nível alto, o `TodosRepository` irá expor um método para `loadTodos` e `saveTodos`. Isso é tudo o que precisamos saber, para o restante do tutorial, focaremos nas camadas Bloc e Presentation.

## Todos Bloc

> Nosso `TodosBloc` será responsável por converter o `TodosEvents` em `TodosStates` e gerenciará a lista de todos.

### Modelo

A primeira coisa que precisamos fazer é definir o nosso modelo Todo. Cada tarefa precisará ter um ID, uma tarefa, uma nota opcional e um sinalizador concluído opcional.

Vamos criar um diretório `models` e criar `todo.dart`.

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

?> **Nota:** Estamos utilizando o pacote [Equatable](https://pub.dev/packages/equatable) para que possamos comparar instâncias de `Todos` sem precisar substituir manualmente `== `e` hashCode`.

Em seguida, precisamos criar o `TodosState` que nossa camada de apresentação receberá.

### States

Vamos criar `blocs/todos/todos_state.dart` e definir os diferentes estados que precisaremos lidar.

Os três estados que implementaremos são:

- `TodosLoadInProgress` - o estado enquanto nosso aplicativo está buscando todos no repositório.
- `TodosLoadSuccess` - o estado do nosso aplicativo depois que todos foram carregados com sucesso.
- `TodosLoadFailure` - o estado do nosso aplicativo se todos não foram carregados com sucesso.

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

Em seguida, vamos implementar os eventos que precisaremos manipular.

### Events

Os eventos que precisaremos tratar no nosso `TodosBloc` são:

- `TodosLoaded` - diz ao bloc que ele precisa carregar o todos do `TodosRepository`.
- `TodoAdded` - diz ao bloc que ele precisa adicionar um novo todo à lista de todos.
- `TodoUpdated` - informa ao bloc que ele precisa atualizar um todo existente.
- `TodoDeleted` - informa ao bloc que ele precisa remover um todo existente.
- `ClearCompleted` - informa ao bloc que ele precisa remover todos os todos concluídos.
- `ToggleAll` - informa ao bloc que ele precisa alternar o estado concluído de todos os todos.

Crie `blocs/todos/todos_event.dart` e vamos implementar os eventos que descrevemos acima.

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

Agora que temos nossos `TodosStates` e `TodosEvents` implementados, podemos implementar nosso `TodosBloc`.

### Bloc

Vamos criar `blocs/todos/todos_bloc.dart` e começar! Nós apenas precisamos implementar `initialState` e `mapEventToState`.

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

!> Quando produzimos um estado nos manipuladores privados `mapEventToState`, estamos sempre produzindo um novo estado em vez de alterar o `state`. Isso ocorre porque toda vez que damos um yield, o bloc comparará o `state` com o `nextState` e acionará apenas uma mudança de estado (`transição`) se os dois estados **não forem iguais**. Se apenas mudarmos e produzirmos a mesma instância de estado, o `state == nextState` será avaliado como verdadeiro e nenhuma alteração de estado ocorrerá.

Nosso `TodosBloc` dependerá do `TodosRepository` para que possa carregar e salvar todos. Ele terá um estado inicial de `TodosLoadInProgress` e define os manipuladores privados para cada um dos eventos. Sempre que o `TodosBloc` altera a lista de todos, ele chama o método` saveTodos` no `TodosRepository` para manter tudo persistido localmente.

### Arquivo Barrel

Agora que terminamos o nosso `TodosBloc`, podemos criar um arquivo barrel para exportar todos os nossos arquivos de bloc e facilitar a importação mais tarde.

Crie `blocs/todos/todos.dart` e exporte o bloc, eventos e estados:

```dart
export './todos_bloc.dart';
export './todos_event.dart';
export './todos_state.dart';
```

## Filtered Todos Bloc

> O `FilteredTodosBloc` será responsável por reagir às alterações de estado no `TodosBloc` que acabamos de criar e manterá o estado de todos filtrados em nosso aplicativo.

### Modelo

Antes de começarmos a definir e implementar o `TodosStates`, precisaremos implementar um modelo `VisibilityFilter` que determine quais todos os nossos `FilteredTodosState` conterão. Nesse caso, teremos três filtros:

- `all` - mostra todos Todos (padrão)
- `active` - mostra apenas Todos que não foram concluídos
- 'concluído' mostra apenas Todos os que foram concluídos

Podemos criar `models/visible_filter.dart` e definir nosso filtro como uma enumeração:

```dart
enum VisibilityFilter { all, active, completed }
```

### Estados

Assim como fizemos com o `TodosBloc`, precisaremos definir os diferentes estados para o nosso `FilteredTodosBloc`.

Nesse caso, temos apenas dois estados:

- `FilteredTodosLoadInProgress` - o estado enquanto estamos buscando todos
- `FilteredTodosLoadSuccess` - o estado em que não estamos mais buscando todos

Vamos criar `blocs/filtrado_todos/filtrado_todos_state.dart` e implementar os dois estados.

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

?> **Nota:** O estado `FilteredTodosLoadSuccess` contém a lista de todos filtrados, bem como o filtro de visibilidade ativo.

### Eventos

Vamos implementar dois eventos para o nosso `FilteredTodosBloc`:

- `FilterUpdated` - que notifica o bloc que o filtro de visibilidade foi alterado
- `TodosUpdated` - que notifica o bloc de que a lista de todos mudou

Crie `blocs/filtrado_todos/filtrado_todos_event.dart` e vamos implementar os dois eventos.

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

Estamos prontos para implementar nosso `FilteredTodosBloc` a seguir!

### Bloc

Nosso `FilteredTodosBloc` será semelhante ao nosso `TodosBloc`; no entanto, em vez de depender do `TodosRepository`, ele dependerá do próprio `TodosBloc`. Isso permitirá que o `FilteredTodosBloc` atualize seu estado em resposta a alterações de estado no `TodosBloc`.

Crie `blocs/filtrado_todos/filtrado_todos_bloc.dart` e vamos começar.

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

!> Criamos um `StreamSubscription` para o fluxo do `TodosStates` para que possamos ouvir as alterações de estado no `TodosBloc`. Substituímos o método de fechamento do bloc e cancelamos a assinatura para que possamos limpar depois que o bloc for fechado.

### Arquivo Barrel

Assim como antes, podemos criar um arquivo barrel para facilitar a importação das várias classes todos filtradas.

Crie `blocs/filtrado_todos/filtrado_todos.dart` e exporte os três arquivos:

```dart
export './filtered_todos_bloc.dart';
export './filtered_todos_event.dart';
export './filtered_todos_state.dart';
```

Em seguida, vamos implementar o `StatsBloc`.

## Stats Bloc

> O `StatsBloc` será responsável por manter as estatísticas do número de todos ativos e do número de todos concluídos. Da mesma forma, para o `FilteredTodosBloc`, ele terá uma dependência do `TodosBloc` para que possa reagir a alterações no estado do `TodosBloc`.

### Estado

Nosso `StatsBloc` terá dois estados nos quais ele pode estar:

- `StatsLoadInProgress` - o estado em que as estatísticas ainda não foram calculadas.
- `StatsLoadSuccess` - o estado em que as estatísticas foram calculadas.

Crie `blocs/stats/stats_state.dart` e vamos implementar nosso` StatsState`.

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

Em seguida, vamos definir e implementar os `StatsEvents`.

### Eventos

Haverá apenas um único evento que nosso `StatsBloc` responderá a:` StatsUpdated`. Este evento será adicionado sempre que o estado do `TodosBloc` mudar, para que o nosso `StatsBloc` possa recalcular as novas estatísticas.

Crie `blocs/stats/states_event.dart` e vamos implementá-lo.

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

Agora estamos prontos para implementar nosso `StatsBloc`, que será muito parecido com o `FilteredTodosBloc`.

### Bloc

Nosso `StatsBloc` terá uma dependência do `TodosBloc`, o que lhe permitirá atualizar seu estado em resposta a alterações de estado no `TodosBloc`.

Crie `blocs/stats/stats_bloc.dart` e vamos começar.

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

Isso é tudo! Nosso `StatsBloc` recalcula seu estado, que contém o número de todos ativos e o número de todos concluídos em cada alteração de estado do nosso `TodosBloc`.

Agora que terminamos o `StatsBloc`, temos apenas um último bloc para implementar: o `TabBloc`.

## Tab Bloc

> O `TabBloc` será responsável por manter o estado das guias em nossa aplicação. Ele usará o `TabEvents` como entrada e a saída do `AppTabs`.

### Modelo/Estado

Precisamos definir um modelo `AppTab` que também usaremos para representar o `TabState`. O `AppTab` será apenas um `enum` que representa a guia ativa em nosso aplicativo. Como o aplicativo que estamos construindo terá apenas duas guias: todos e estatísticas, precisamos apenas de dois valores.

Crie `models/app_tab.dart`:

```dart
enum AppTab { todos, stats }
```

### Evento

Nosso `TabBloc` será responsável por manipular um único `TabEvent`:

- `TabUpdated` - que notifica o bloc que a guia ativa atualizou

Crie `blocs/tab/tab_event.dart`:

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

### Bloc

Nossa implementação do `TabBloc` será super simples. Como sempre, precisamos apenas implementar `initialState` e `mapEventToState`.

Crie `blocs/tab/tab_bloc.dart` e vamos fazer a implementação rapidamente.

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

Eu te disse que seria simples. Tudo o que o `TabBloc` está fazendo é definir o estado inicial na guia todos e manipular o evento `TabUpdated`, produzindo uma nova instância do `AppTab`.

### Arquivo Barrel

Por fim, criaremos outro arquivo barrel para nossas exportações do `TabBloc`. Crie `blocs/tab/tab.dart` e exporte os dois arquivos:

```dart
export './tab_bloc.dart';
export './tab_event.dart';
```

## Bloc Delegate

Antes de avançarmos para a camada de apresentação, implementaremos nosso próprio `BlocDelegate`, o que nos permitirá lidar com todas as alterações e erros de estado em um único local. É realmente útil para coisas como logs ou análises do desenvolvedor.

Crie `blocs/simple_bloc_delegate.dart` e vamos começar.

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

Tudo o que estamos fazendo neste caso é imprimir todas as alterações de estado (`transições`) e erros no console, para que possamos ver o que está acontecendo quando estamos executando nosso aplicativo. Você pode conectar seu `BlocDelegate` ao google analytics, sentry, crashlytics, etc ...

## Barrel de Blocs

Agora que temos todos os nossos blocs implementados, podemos criar um arquivo barrel.

Crie `blocs/blocs.dart` e exporte todos os nossos blocs para que possamos importar convenientemente qualquer código de bloc com uma única importação.

```dart
export './filtered_todos/filtered_todos.dart';
export './stats/stats.dart';
export './tab/tab.dart';
export './todos/todos.dart';
export './simple_bloc_delegate.dart';
```

A seguir, focaremos na implementação das principais telas em nosso aplicativo Todos.

## Screens

### Home Screen

> Nosso `HomeScreen` será responsável por criar o `Scaffold` do nosso aplicativo. Ele manterá os widgets `AppBar`,`BottomNavigationBar`, bem como os widgets `Stats`/`FilteredTodos` (dependendo da guia ativa).

Vamos criar um novo diretório chamado `screens` onde colocaremos todos os nossos novos widgets de tela e depois criaremos` screens/home_screen.dart`.

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

O `HomeScreen` acessa o `TabBloc` usando o `BlocProvider.of<TabBloc>(context)`, que será disponibilizado no nosso widget raiz `TodosApp` (veremos mais adiante neste tutorial).

Em seguida, implementaremos o `DetailsScreen`.

### Details Screen

> O `DetailsScreen` exibe todos os detalhes do trabalho selecionado e permite que o usuário edite ou exclua o trabalho.

Crie `screens/details_screen.dart` e vamos construí-lo.

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

?> **Nota:** O `DetailsScreen` requer um ID de todo o trabalho para que ele possa obter os detalhes do todo a partir do `TodosBloc` e para que ele possa ser atualizado sempre que os detalhes de um todo forem alterados (o ID de um todo não pode ser alterado).

As principais coisas a serem observadas são que existe um `IconButton` que adiciona um evento `TodoDeleted`, bem como uma caixa de seleção que adiciona um evento `TodoUpdated`.

Há também outro `FloatingActionButton` que navega o usuário para o `AddEditScreen` com o `isEditing` definido como `true`. Vamos dar uma olhada no `AddEditScreen` a seguir.

### Add/Edit Screen

> O widget `AddEditScreen` permite ao usuário criar um novo trabalho ou atualizar um trabalho existente com base no sinalizador `isEditing` que é passado pelo construtor.

Crie `screens/add_edit_screen.dart` e vamos dar uma olhada na implementação.

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

Não há nada específico de bloc neste widget. É simplesmente apresentar um formulário e:

- se `isEditing` for verdadeiro, o formulário é preenchido com os detalhes de tarefas existentes.
- caso contrário, as entradas estarão vazias para que o usuário possa criar um novo todo.

Ele usa uma função de retorno de chamada `onSave` para notificar seu pai do todo atualizado ou recém-criado.

É o caso das telas em nosso aplicativo. Antes de esquecermos, vamos criar um arquivo barrel para exportá-las.

### Barrel de Screens

Crie `screens/screens.dart` e exporte todos os três.

```dart
export './add_edit_screen.dart';
export './details_screen.dart';
export './home_screen.dart';
```

Em seguida, vamos implementar todos os "widgets" (qualquer coisa que não seja uma tela).

## Widgets

### Botão de Filtrar

> O widget `FilterButton` será responsável por fornecer ao usuário uma lista de opções de filtro e notificará o `FilteredTodosBloc` quando um novo filtro for selecionado.

Vamos criar um novo diretório chamado `widgets` e colocar nossa implementação `FilterButton` em `widgets/filter_button.dart`.

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

O `FilterButton` precisa responder às alterações de estado no `FilteredTodosBloc`, para que ele use o `BlocProvider` para acessar o `FilteredTodosBloc` no `BuildContext`. Ele então usa o `BlocBuilder` para renderizar novamente sempre que o `FilteredTodosBloc` mudar de estado.

O restante da implementação é puro Flutter e não há muita coisa acontecendo para que possamos avançar para o widget `ExtraActions`.

### Ações Extra

> Da mesma forma que o `FilterButton`, o widget `ExtraActions` é responsável por fornecer ao usuário uma lista de opções extras: Alternar Todos e Limpando Todos.

Como este widget não se importa com os filtros, ele irá interagir com o `TodosBloc` em vez do `FilteredTodosBloc`.

Vamos criar o modelo `ExtraAction` em `models/extra_action.dart`.

```dart
enum ExtraAction { toggleAllComplete, clearCompleted }
```

E não esqueça de exportá-lo no arquivo barrel `models/models.dart`.

A seguir, vamos criar `widgets/extra_actions.dart` e implementá-lo.

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

Assim como no `FilterButton`, usamos o `BlocProvider` para acessar o `TodosBloc` no `BuildContext` e no `BlocBuilder` para responder às alterações de estado no `TodosBloc`.

Com base na ação selecionada, o widget adiciona um evento ao `TodosBloc` para os estados de conclusão `ToggleAll` todos ou para todos os `ClearCompleted`.

A seguir, veremos o widget `TabSelector`.

### Tab Selector

> O widget `TabSelector` é responsável por exibir as guias na `BottomNavigationBar` e manipular a entrada do usuário.

Vamos criar `widgets/tab_selector.dart` e implementá-lo.

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

Você pode ver que não há dependência de blocs neste widget; apenas chama `onTabSelected` quando uma guia é selecionada e também recebe uma `activeTab` como entrada para que ele saiba qual guia está atualmente selecionada.

A seguir, veremos o widget `FilteredTodos`.

### Filtered Todos

> O widget `FilteredTodos` é responsável por mostrar uma lista de todos com base no filtro ativo atual.

Crie `widgets/filter_todos.dart` e vamos implementá-lo.

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

Assim como os widgets anteriores que escrevemos, o widget `FilteredTodos` usa o `BlocProvider` para acessar os blocs (neste caso, o `FilteredTodosBloc` e o `TodosBloc` são necessários).

?> O `FilteredTodosBloc` é necessário para nos ajudar a renderizar todos corretos com base no filtro atual

?> O `TodosBloc` é necessário para permitir adicionar/excluir todos em resposta a interações do usuário, como passar um item individual em um todo.

No widget `FilteredTodos`, o usuário pode navegar para a `DetailsScreen`, onde é possível editar ou excluir o todo selecionado. Como nosso widget `FilteredTodos` renderiza uma lista de widgets `TodoItem`, vamos dar uma olhada nos próximos.

### Todo Item

> `TodoItem` é um widget sem estado que é responsável por processar um único todo e manipular as interações do usuário (toques/swipes).

Crie `widgets/todo_item.dart` e vamos construí-lo.

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

Novamente, observe que o `TodoItem` não possui código específico de bloc. Ele é renderizado com base no todo que passamos pelo construtor e chama as funções de retorno de chamada injetadas sempre que o usuário interage com o todo.

Em seguida, criaremos o `DeleteTodoSnackBar`.

### Delete Todo SnackBar

> O `DeleteTodoSnackBar` é responsável por indicar ao usuário que um todo foi excluído e permite que o usuário desfaça sua ação.

Crie `widgets/delete_todo_snack_bar.dart` e vamos implementá-lo.

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

Você provavelmente está percebendo um padrão: esse widget também não possui código específico do bloc. Ele simplesmente recebe um todo para renderizar a tarefa e chama uma função de retorno de chamada chamada `onUndo` se um usuário pressionar o botão desfazer.

Estamos quase terminando; faltam apenas mais dois widgets!

### Loading Indicator

> O widget `LoadingIndicator` é um widget sem estado que é responsável por indicar ao usuário que algo está em andamento.

Crie `widgets/loading_indicator.dart` e vamos escrever.

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

Não há muito o que discutir aqui; estamos apenas usando um `CircularProgressIndicator` envolvido em um widget` Center` (novamente sem código específico de bloc).

Por fim, precisamos criar nosso widget `Stats`.

### Stats

> O widget `Stats` é responsável por mostrar ao usuário quantos todos estão ativos (em andamento) vs concluídos.

Vamos criar `widgets/stats.dart` e dar uma olhada na implementação.

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

Estamos acessando o `StatsBloc` usando o `BlocProvider` e o `BlocBuilder` para reconstruir em resposta a alterações de estado no estado `StatsBloc`.

## Juntando tudo

Vamos criar o `main.dart` e o nosso widget TodosApp. Precisamos criar uma função `main` e executar nosso `TodosApp`.

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

?> **Nota:** Estamos configurando o delegate do nosso BlocSupervisor para o `SimpleBlocDelegate` que criamos anteriormente, para que possamos nos conectar a todas as transições e erros.

?> **Nota:** Também estamos envolvendo nosso widget `TodosApp` em um `BlocProvider` que gerencia a inicialização, o fechamento e o fornecimento de `TodosBloc` para toda a nossa árvore de widgets a partir de [flutter_bloc](https://pub.dev/packages/flutter_bloc). Nós adicionamos imediatamente o evento `TodosLoaded` para solicitar os mais recentes.

Em seguida, vamos implementar nosso widget `TodosApp`.

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

Nosso `TodosApp` é um `StatelessWidget` que acessa o `TodosBloc` fornecido através do `BuildContext`.

O `TodosApp` possui duas rotas:

- `Home` - que renderiza uma `HomeScreen`
- `TodoAdded` - que renderiza um `AddEditScreen` com `isEditing` definido como `false`.

O `TodosApp` também disponibiliza o `TabBloc`, `FilteredTodosBloc` e `StatsBloc` para os widgets em sua subárvore, usando o widget `MultiBlocProvider` do [flutter_bloc](https://pub.dev/packages/flutter_bloc) .

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

é equivalente a escrever

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

Você pode ver como o uso do MultiBlocProvider ajuda a reduzir os níveis de aninhamento e facilita a leitura e a manutenção do código.

Todo o `main.dart` deve ficar assim:

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

Isso é tudo! Agora, implementamos com sucesso um aplicativo de Todos no flutter usando os pacotes [bloc](https://pub.dev/packages/bloc) e [flutter_bloc](https://pub.dev/packages/flutter_bloc) e nós separamos com êxito nossa camada de apresentação de nossa lógica de negócios.

O código fonte completo deste exemplo pode ser encontrada [aqui](https://github.com/felangel/Bloc/tree/master/examples/flutter_todos).

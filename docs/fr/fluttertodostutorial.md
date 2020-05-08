# Flutter Todos Tutorial

![advanced](https://img.shields.io/badge/level-advanced-red.svg)

> Dans ce tutoriel, nous allons construire une application Todos (Liste de choses à faire) en utilisant la librairie Bloc !
?> **Note:** Pour des raisons de sens, je ne vais toujours tout traduire donc voici une liste des mots anglais et leur équivalent français que vous allez retrouver tout au long du tutorial : state -> état / Todos -> Choses à faires / Overriding -> Réécrire du code par dessus un code déjà existant et similaire / Input -> valeur d'entrée / Output -> valeur de sortie

![demo](../assets/gifs/flutter_todos.gif)

## Configuration

Commençons par créer un tout nouveau projet Flutter

```bash
flutter create flutter_todos
```
Ensuite, remplaçons le contenu de `pubspec.yaml` avec

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

et ensuite nous allons installer toutes les dépendances

```bash
flutter packages get
```

?> **Note:** Nous allons overriding quelques dépendances car nous allons les réutiliser depuis [Brian Egan's Flutter Architecture Samples](https://github.com/brianegan/flutter_architecture_samples).

## App Keys (Clefs d'application)

Avant de sauter dans le code de l'application, créons `flutter_todos_keys.dart`. Ce fichier contiendra des clefs (keys) qui seront utilisés pour identifier uniquement les widgets importants. Plus tard, nous pourrons écrire des tests qui trouvent les widgets en se basant sur les keys.

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
Nous allons référencer ces clefs tout au long du reste du tutoriel.

?> **Note:** Vous pouvvez vérifier les tests d'intégrations de votre appli [ici](https://github.com/brianegan/flutter_architecture_samples/tree/master/integration_tests). Et également checker les tests unitaires et de widgets [ici](https://github.com/brianegan/flutter_architecture_samples/tree/master/bloc_library/test).

## Localisation

Le dernier concept que nous allons apporter avant de rentrer dans le vif de l'application est la localisation. Créons `localization.dart` et nous allons créer la fondation pour un support multi-langage.

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
Nous pouvons maintenant importer et fournir notre `FlutterBlocLocalizationsDelegate` à notre `MaterialApp` (plus tard dans ce tutoriel).
Pour plus d'informations sur la localisation, visitez [la doc officiel Flutter](https://flutter.dev/docs/development/accessibility-and-localization/internationalization).

## Todos Repository (Répertoire Todos)

Dans ce tutoriel, nous n'allons pas aller dans les détails de l'implémentation du `TodosRepository` car il a été implémenté par [Brian Egan](https://github.com/brianegan) et il partagé parmi la [Todo Architecture Samples](https://github.com/brianegan/flutter_architecture_samples). A un plus haut niveau, le `TodosRepository` va exposer une méthode pour `loadTodos` et pour `saveTodos`. C'est à peu prèt tout ce que nous avons de savoir pour le reste du tutorial et nous allons pouvoir se focus sur le Bloc et la Presentation de notre application.

## Le Bloc Todos

> Notre `TodosBloc` va être responsable de convertir les `TodosEvents` en `TodosStates` et va gérer la liste des todos.

### Modèle

La première chose que nous avons besoin de définir est notre modèle `Todo`. Chaque todo aura besoin d'un id, d'une tâche (task), optionnellement d'une note et d'un drapeau complété optionnel lui aussi.
Créons un dossier `models` et créons `todo.dart`.

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

?> **Note:** Nous utilisons le package [Equatable](https://pub.dev/packages/equatable) pour que l'on puisse comparer les instances de `Todos` sans avoir a manuellement override `==` et `hashCode`.

Ensuite, nousa avons besoin de créer le `TodosState` qui sera interprété par notre couche de présentation.

### States (états)

Créons `blocs/todos/todos_state.dart` et définissons les différents states que nous allons devoir gérer.

Les trois states que nous allons implémenter sont:

- `TodosLoadInProgress` - le state pendant que notre application va chercher (fetching) les todos depuis notre répertoire (repository). 
- `TodosLoadSuccess` - le state de notre application une fois que la liste des todos a chargé avec succès.
- `TodosLoadFailure` - le state de notre application si la liste n'a pas été correctement chargé.

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

Ensuite, nous allons implémenter les événements que nous allons devoir gérer.

### Events (événements)

Les événements qui nous allons devoir gérer dans notre `TodosBloc` sont:

- `TodosLoadSuccess` - dis au bloc qu'il est nécessaire de charger les todos depuis `TodosRepository`.
- `TodoAdded` - dis au bloc qu'il est nécessaire d'ajouter un nouveau todo à la liste des todos.
- `TodoUpdated` - dis au bloc qu'il est nécessaire d'actualiser un todo existant.
- `TodoDeleted` - dis au bloc qu'il est nécessaire de supprimer un todo existant.
- `ClearCompleted` - dis au bloc qu'il est nécessaire de supprimer tous les todos complétés.
- `ToggleAll` - dis au bloc qu'il est nécessaire de basculer (toggle) le state completed de tous les todos.

Créons `blocs/todos/todos_event.dart` et implémentons les événements décris au dessus.

```dart
import 'package:equatable/equatable.dart';
import 'package:flutter_todos/models/models.dart';

abstract class TodosEvent extends Equatable {
  const TodosEvent();

  @override
  List<Object> get props => [];
}

class TodosLoadSuccess extends TodosEvent {}

class TodoAdded extends TodosEvent {
  final Todo todo;

  const TodoAdded(this.todo);

  @override
  List<Object> get props => [todo];

  @override
  String toString() => 'TodoAdded { todo: $todo }';
}

class TodoUpdated extends TodosEvent {
  final Todo todo;

  const TodoUpdated(this.todo);

  @override
  List<Object> get props => [todo];

  @override
  String toString() => 'TodoUpdated { todo: $todo }';
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

Maintenant que nous avons `TodosStates` et `TodosEvents` d'implémenter, nous puvons implémenter notre `TodosBloc`.

### Bloc

Créons `blocs/todos/todos_bloc.dart` et commençons! Nous avons juste besoin d'implémenter `initialState` et `mapEventToState`.

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
    if (event is TodosLoadSuccess) {
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

!> Quand nous "yieldons" un state dans le gestionnaire privé (private handlers) `mapEventToState`, nous sommes toujours entrain de yield un nouveau state plutôt de muter le `state`. Cela s'explique car à chaque fois que nous yieldons, le bloc va comparer le `state` au `nextState` et va déclencher un changement de state (`transition`) si les deux states **ne sont pas égaux**. Si nous faisons juste muter et yield la même instance de notren state, alors `state == nextState` renverra vrai (true) et aucun changement de state n'aurait lieu.

Notre `TodosBloc` aura une dépendance sur le `TodosRepository` pour qu'il puisse charger et sauvegarder les todos. Il aura un state initial de `TodosLoadInProgress` et définira le private handlers pour chacun des événements. Peu importe quand le `TodosBloc` change la liste des todos, il appelle la méthode `saveTodos` dans le `TodosRepository` dans le but de tout garder localement.

### Barrel File (Fichier baril)

Maintenant que nous en avons terminé avec notre `TodosBloc`, nous pouvons créer un barrel file pour exporter tous les fichiers de notre et faciliter leur import plus tard.

Créons `blocs/todos/todos.dart` et exportons le bloc, les événements (events) et les states:

```dart
export './todos_bloc.dart';
export './todos_event.dart';
export './todos_state.dart';
```

## Filtrés Todos Bloc

> Le `FilteredTodosBloc` sera responsable de réagir aux changements de states dans le `TodosBloc` que nous venons de créer et il maintiendra le state de filtrage des todos dans notre application.

### Modèle

Avant que nous commençons à définir et à implémenter le `TodosStates`, nous allons implémenter le modèle `VisibilityFilter` qui déterminera quel todo notre `FilteredTodosState` contiendra. Dans ce cas, nous aurons trois filtres:

- `all` - va afficher tous les Todos (par défaut)
- `active` - affichera seulement les Todos qui ne sont pas complétés
- `completed` affichera seulement les Todos complétés

Nous pouvons créer `models/visibility_filter.dart` aet définir notre filtre comme un enum:

```dart
enum VisibilityFilter { all, active, completed }
```

### States (états)

Comme nous l'avons fais dans `TodosBloc`, nous allons définir les différents states pour notre `FilteredTodosBloc`.

Dans ce cas, nous aurons uniquement deux states:

- `FilteredTodosLoadInProgress` - le state pendant que nous récupérons les todos
- `FilteredTodosLoadSuccess` - le state quand nous avons fini de récupérer les todos

Créons `blocs/filtered_todos/filtered_todos_state.dart` et implémentons les deux states.

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

?> **Note:** Le state `FilteredTodosLoadSuccess` contient la liste des todos filtrés ainsi que le filtre de visibilité activé.

### Events (événements)

Nous allons implémenter deux événements pour notre `FilteredTodosBloc`:

- `FilterUpdated` - qui notifiera le bloc que la visibilité du filtre a changé
- `TodosUpdated` - qui notifiera le bloc que la list des todos a changé

Créons `blocs/filtered_todos/filtered_todos_event.dart` et implémentons les deux événements.

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

Nous sommes prêts pour implémenter `FilteredTodosBloc`!

### Bloc

Notre `FilteredTodosBloc` sera similaire à celui `TodosBloc`; toutefois, au lieu d'avoir une dépendance sur `TodosRepository`, il aura une dépendance sur le bloc `TodosBloc`. Cela nous permettra au `FilteredTodosBloc` d'actualiser son propre state en réponse aux changements du state dans le `TodosBloc`.

Créons `blocs/filtered_todos/filtered_todos_bloc.dart` et commençons.

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
      yield* _mapUpdateFilterToState(event);
    } else if (event is TodosUpdated) {
      yield* _mapTodosUpdatedToState(event);
    }
  }

  Stream<FilteredTodosState> _mapUpdateFilterToState(
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

!> Nous créons un `StreamSubscription` pour le stream de `TodosStates` pour que l'on puisse écouter les changements du state dans le `TodosBloc`. On override la méthode de fermeture du bloc et annulons la souscription pour que l'on puisse nettoyer(clean) après que le bloc soit fermé.

### Barrel File (fichier baril)

Comme avant, nous pouvons créer un fichier baril pour permettre l'import des classes de filtrage des todos.

Créons `blocs/filtered_todos/filtered_todos.dart` et exportons les trois fichiers:

```dart
export './filtered_todos_bloc.dart';
export './filtered_todos_event.dart';
export './filtered_todos_state.dart';
```

Ensuite, nous allons implémenter le `StatsBloc`.

## Stats Bloc (Bloc de statistiques)

> Le `StatsBloc` sera responsable de maintenir les statistiques du nombre de todos actifs et du nombres de todos complétés.
Comme pour le `FilteredTodosBloc`, il aura une dépendance sur le `TodosBloc` pour qu'il puisse réagir aux changements dans le `TodosBloc` state.

### State

Notre `StatsBloc` pourra être dans deux states:

- `StatsLoadInProgress` - soit le state quand les statistiques n'ont pas encore été calculées.
- `StatsLoadSuccess` -  ques les statistiques ont été calculées.

Créons `blocs/stats/stats_state.dart` et implémentons notre `StatsState`.

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

Ensuite, définissons et implémentons `StatsEvents`.

### Events

Il y aura qu'un seul événement dans notre `StatsBloc` il répondra à: `StatsUpdated`. Cet événement sera ajouté peu importe quand le state de `TodosBloc` changera pour que notre `StatsBloc` puisse recalculer les nouvelles statistiques.

Créons `blocs/stats/states_event.dart` et implémentons le.

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
Maintenant nous sommes prêts à implémenter notre `StatsBloc` which will look very similar to the `FilteredTodosBloc`.

### Bloc

Notre `StatsBloc` aura une dépendance avec `TodosBloc` ce qui lui permettra d'actualiser son state en réponse aux changements du state dans le `TodosBloc`.

Créons `blocs/stats/stats_bloc.dart` et commençons.

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

C'est tout ce dont nous avons besoin! Notre `StatsBloc` recalculera son state qui contient le nombre de todos actifs et le nombre de todos complétés à chaque fois que le state de notre bloc `TodosBloc` changera.

Maintenant que nous avons terminé avec le `StatsBloc` il ne faut plus qu'implémenter notre dernier bloc : le `TabBloc`.

## Tab Bloc

> Le `TabBloc` sera responsable de maintenir le state des différentes fenêtres (tabs) dans notre application. Il prendra `TabEvents` comme input et son output sera `AppTabs`.

### Model / State (Modèle / état)

Nous avons besoin de définir un modèle `AppTab` que nous utiliserons pour représenter le `TabState`. Le `AppTab` sera juste un `enum` qui représente la fenêtre active dans notre application. Comme notre application ne contiendra que deux fenêtres à savoir les todos et les statistiques, nous avons besoin d'y ajouter 2 valeurs.

Créons `models/app_tab.dart`:

```dart
enum AppTab { todos, stats }
```

### Event 

Notre `TabBloc` sera responsable de gérer un seul événement `TabEvent`:

- `TabUpdated` - il notifiera le bloc que la fenêtre active a été mise à jour

Créons `blocs/tab/tab_event.dart`:

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

Dans notre `TabBloc` l'implémentation sera super simple. Comme toujours, nous avons juste besoin d'implémenter `initialState` et `mapEventToState`.

Créons `blocs/tab/tab_bloc.dart` et implémentons le rapidement.

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

Je vous avais prévenu que ce serait simple! Tout ce que `TabBloc` va faire est de définir le state initial à la fenêtre des todos (cela veut dire que par défaut l'application s'ouvrira sur cette fenêtre) et gérer l'événement `TabUpdated` en "yieldant" une nouvelle instance `AppTab`.

### Barrel File (Fichier baril)

Enfin, nous allons créer un autre fichier baril pour exporter notre `TabBloc`. Créons `blocs/tab/tab.dart` et exportons les deux fichiers:

```dart
export './tab_bloc.dart';
export './tab_event.dart';
```

## Bloc Delegate

Avant de passer à la couche de présentation, nous allons implémenter notre propre `BlocDelegate` qui nous permettra de gérer tous les changements de state et les erreurs dans une seule place. C'est très pratique pour des choses comme avoir les développeurs logs ou les analyses (analytics).

Créons `blocs/simple_bloc_delegate.dart` et commençons.

```dart
import 'package:bloc/bloc.dart';

class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onEvent(Bloc bloc, Object event) {
    print(event);
    super.onEvent(bloc, event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    print(transition);
    super.onTransition(bloc, transition);
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stackTrace) {
    print(error);
    super.onError(bloc, error, stackTrace);
  }
}
```
Tout ce que nous faisons dans ce cas est d'afficher (en console) tous les changements de states (`transitions`) et les erreurs pour que l'on puisse voir ce qu'il se passe quand nous utilisons notre application. Vous pourriez même relier `BlocDelegate` à votre Google analytics, sentry, crashlytics, etc...

## Blocs Barrel (Baril de blocs)

Maintenant que nous avons tous nos blocs d'implémentés, nous pouvons créer un fichier baril.
Créons `blocs/blocs.dart` et exportons tous nos blocs pour pouvoir importer de manière conventionnel nos blocs dans n'importe quel fichier avec un simple import.

```dart
export './filtered_todos/filtered_todos.dart';
export './stats/stats.dart';
export './tab/tab.dart';
export './todos/todos.dart';
export './simple_bloc_delegate.dart';
```

Ensuite, nous allons nous concentrer sur la manière dont nous allons implémenter la plus part de nos écrans (screens) dans notre Todos application.

## Screens (écrans)

### Home Screen (Ecran d'accueil)

> Notre `HomeScreen` sera responsable de la créaton du `Scaffold` de notre application. Il contiendra notre `AppBar`, `BottomNavigationBar`, mais aussi nos widgets `Stats`/`FilteredTodos` (en fonction de la fenêtre active).

Créons un nouveau dossier appelé `screens` où nous mettrons tous nos nouveaux screen widgets et ensuite créons `screens/home_screen.dart`.

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

Le `HomeScreen` a accès au `TabBloc` en utilisant `BlocProvider.of<TabBloc>(context)` qui va devenir disponible depuis la racine(root) de notre widget `TodosApp` (nous y reviendrons un peu plus tard dans ce tutoriel).

Ensuite, nous allons implémenter notre `DetailsScreen`.

### Details Screen

> L'écran `DetailsScreen` affichera tous les détails du todo que nous l'utilisateur aura sélectionné et lui permettra de soit l'éditer ou alors de le supprimer.

Créons et construisons `screens/details_screen.dart`.

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

?> **Note:** Le `DetailsScreen` requiert un id d'un todo pour qu'il puisse afficher les détail du todo sélectionné à partir du `TodosBloc` et pour qu'il puisse la mettre à jour peu importe quand les détails d'unb todo ont été changés (l'id d'un todo ne peut pas être modifié).

Les choses à remarqués ici sont l'icône `IconButton` qui ajoute un événement `TodoDeleted` ainsi qu'une checkbox qui ajoute un événement `TodoUpdated`.

Il y aussi un autre `FloatingActionButton` qui fait naviguer l'utilisateur à `AddEditScreen` avec `isEditing` qui prend `true` comme valeur. Nous allons examiner l'écran `AddEditScreen` juste après.

### Add/Edit Screen (Ecran d'ajout/de modification)

> Le widget `AddEditScreen` permet à l'utilisateur de soit créer un nouveau todo ou alors d'actualiser un todo existant en se basant sur le flag (drapeau) `isEditing` qui lui est passé via le constructeur.

Créons `screens/add_edit_screen.dart` et regardons comment l'implémenter.

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

Il n'y a rien de specific au bloc dans ce widget, il s'agit simplement d'un formulaire et:

- si `isEditing` est true le formulaire est rempli avec les détails existantes du todo.
- sinon les inputs sont vides pour que l'utilisateur puisse créer un nouveau todo.

On utilise une fonction de rappel (callback) `onSave` pour notifier le parent de l'actualisation ou la création d'un todo.

C'est tout pour les écrans dans notre application, mais avant d'oublier, créons notre fichier baril.

### Screens Barrel (Baril d'écrans)

Créons `screens/screens.dart` et exportons les trois fichiers.

```dart
export './add_edit_screen.dart';
export './details_screen.dart';
export './home_screen.dart';
```

Ensuite, implémentons tous les "widgets" (tout ce qui n'est pas un screen).

## Widgets

### Filter Button (Boutton pour filtrer)

> Le widget `FilterButton` sera responsable de fournir à l'utilisateur unbe liste des options de filtrage et il notifiera le `FilteredTodosBloc` quand un filtre a été selectionné.

Créons un nouveau fichier appelé `widgets` et mettons-y l'implémentation de `FilterButton` dans `widgets/filter_button.dart`.

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

Le `FilterButton` a besoin de répondre aux changements d'états (states) dans le `FilteredTodosBloc` donc il utilise un `BlocProvider` pour accèder au `FilteredTodosBloc` depuis `BuildContext`. Ensuite, il utilise `BlocBuilder` pour ré-affichier peu importe quand le state de `FilteredTodosBloc` change.

Le reste de l'implémentation est du Flutter pur et il n'y a rien de spécial qui se passe, nous pouvons donc passer au widget `ExtraActions`.

### Extra Actions

> Comme pour `FilterButton`, le widget `ExtraActions` est responsable de founir à l'utilisateur une liste d'options supplémentaires :  Toggling Todos et nettoyer (clear) les todos complétés.

Puisque ce widget s'en fiche des filters, il va intéragir directement avec `TodosBloc` plutôt que `FilteredTodosBloc`.

Créons le modèle `ExtraAction` dans `models/extra_action.dart`.

```dart
enum ExtraAction { toggleAllComplete, clearCompleted }
```

Et n'oubliez pas de l'exporter dans le fichier baril `models/models.dart`.

Ensuite, créons `widgets/extra_actions.dart` et implémentons le.

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

Comme pouir le `FilterButton`, on utilise un `BlocProvider` pour accèder au `TodosBloc` à partir de  `BuildContext` et `BlocBuilder` to en réponse aux changements de states dans le bloc `TodosBloc`.

En fonction des actions sélectionnées, le widget ajoutera un événement soit au `TodosBloc` ou alors à `ToggleAll` aux todos ayant un state de complété ou pour clear `ClearCompleted` les todos.

Ensuite nous travaillerons sur le widget `TabSelector`.

### Tab Selector (Sélectionner la fenêtre)

> Le widget `TabSelector` a pour rôle d'afficher les fenêtres dans le `BottomNavigationBar` et de gérer les input des utilisateurs.

Créons `widgets/tab_selector.dart` et implémentons le.

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
Vous pouvez voir qu'il n'y aucune dépendance sur les blocs dans ce widget; il appel juste `onTabSelected` quand une fenêtre est sélectionné et il prend aussi `activeTab` comme input afin de savoir quelle fenêtre est actuellement sélectionné.
Ensuite, nous allons regarder le widget `FilteredTodos`.

### Filtered Todos (Filtrés les todos)

> Le widget `FilteredTodos` est reponsable d'afficher une liste de todos en fonction des filtres actifs.
Créons `widgets/filtered_todos.dart` et implémentons le.

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

Comme pour les widgets précédemment écrits, le widget `FilteredTodos` utilise `BlocProvider` pour accèder au bloc (dans ce cas les deux blocs `FilteredTodosBloc` et `TodosBloc` son nécessaires).

?> Le `FilteredTodosBloc` est nécessaire pour nous aider à afficher correment les todos en fonction de leur filtre actuel

?> Le `TodosBloc` est nécessaire pour nous permettre d'ajouter/supprimer des todos en réponse aux intéractions de l'utilisateur comme swiper sur un todo individuel.

Depuis le widget `FilteredTodos`, l'utilisateur peut naviguer sur l'écran `DetailsScreen` où il est possible de soit supprimer ou éditer un todo sélectionné. Puisque notre widget `FilteredTodos` affiche une liste de widgets `TodoItem`, nous allons nous y intéresser prochainement.

### Todo Item

> `TodoItem` est un stateless widget qui est reponsable d'afficher un seul todo et de gérer les intéractions de l'utilisateurs (taps/swipes).

Créons `widgets/todo_item.dart` et construisons le.

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

Encore une fois, notez que le `TodoItem` n'a pas de relation avec un bloc specific dans ce code. Il va simplement afficher via le todo passé dans le constructeur et ensuite appelé les fonctions de rappels (callback) injectés quand l'utilisateur va intéragir avec le todo.
Ensuite, nous allons construire le widget `DeleteTodoSnackBar`.

### Delete Todo SnackBar (Supprimer un todo)

> Le `DeleteTodoSnackBar` sera responsable d'afficher à l'utilisateur que le todo a été supprimé et va permettre à l'utilisateur d'annuler son action.

Créons `widgets/delete_todo_snack_bar.dart` et implémentons le.

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

Maintenant, vous avez probablement repérer le pattern: ce widget lui aussi ne possède pas de bloc-specific code. Il va simplement prendre un todo dans le but d'afficher la tâche et d'appeler une fonction callback appelé `onUndo` si un utilisateur appuie sur le boutton undo.

Nous y sommes presque; plus que deux widgets restants!

### Loading Indicator (Indicateur de chargement)

> Le widget `LoadingIndicator` est stateless widget qui est responsable d'indiquer à l'utilisateur que quelque chose est en progrès.

Créons `widgets/loading_indicator.dart` et écrivons le.

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
Il n'y a rien de spécial à dire ici; nous utilisons un standard `CircularProgressIndicator` enveloppé dans un widget `Center` (encore une fois rien de spécific à du code Bloc).

Lastly, we need to build our `Stats` widget.

### Stats

> Le widget `Stats` est responsable de montrer à l'utilisateur combien de todos sont actifs (en progrès donc) vs combien sont complétés.
Créons `widgets/stats.dart` et regardons comme l'implémenter.

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

Nous accèdons à `StatsBloc` en utilisant `BlocProvider` et `BlocBuilder` pour reconstruire la réponse aux changements de state dans le state `StatsBloc`.

## Assemblons le tout !

Créons `main.dart` dans notre widget `TodosApp`. Nous avons besoin de créer une fonction `main` pour lancer notre `TodosApp`.

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
        )..add(TodosLoadSuccess());
      },
      child: TodosApp(),
    ),
  );
}
```

?> **Note:** Le BlocSupervisor's delegate prend la valeur de `SimpleBlocDelegate` que nous avons créé plutôt pour qu'on puisse récupérer toutes les transitions et les erreurs.

?> **Note:** Nous enveloppons aussi notre widget `TodosApp` dans un `BlocProvider` qui va gérer l'initialisation, la fermeture et de fournir le bloc `TodosBloc` à l'arbre entier de notre widget depuis [flutter_bloc](https://pub.dev/packages/flutter_bloc). Cela permet d'y avoir accès dans tous les widgets enfants. Nous ajoutons aussi immédiatement l'événement `TodosLoadSuccess` dans le but de "demander" les todos les plus récents.

Ensuite nous implémentons notre widget `TodosApp`.

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

Notre `TodosApp` est un `StatelessWidget` qui accède le bloc `TodosBloc` fourni par le `BuildContext`.

Le `TodosApp` possède deux routes:

- `Home` - qui affiche `HomeScreen`
- `TodoAdded` - qui affiche `AddEditScreen` avec `isEditing` qui a pour valeur `false`.

Le `TodosApp` rend `TabBloc`, `FilteredTodosBloc`, et `StatsBloc` disponible pour les widgets dans le sous-arbre en utilisant le widget `MultiBlocProvider` de [flutter_bloc](https://pub.dev/packages/flutter_bloc).

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

revient à écrire

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

Vous pouvez voir à quel point `MultiBlocProvider` aide à réduire les niveaux  reduce the levels de nesting et donne un code plus facile à lire et à maintenir.

Notre `main.dart` en entier devrait ressmebler à ceci :

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
        )..add(TodosLoadSuccess());
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
C'est tout ce qu'il nous faut! Nous avons réussi à implémenter une todo app dans flutter en utilisant les packages [bloc] https://pub.dev/packages/bloc) et [flutter_bloc](https://pub.dev/packages/flutter_bloc) et nous avons  and we’ve séparés avec succès notre présentation (screens et widgets) de notre business logic.

Le code source en entier est disponible [ici](https://github.com/felangel/Bloc/tree/master/examples/flutter_todos)!

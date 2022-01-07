# Flutter Todos Tutorial

![advanced](https://img.shields.io/badge/level-advanced-red.svg)

> In the following tutorial, we're going to build a Todos App in Flutter using the Bloc library.

![demo](./assets/gifs/flutter_todos.gif)

## Key Topics

- [Bloc and Cubit](/coreconcepts?id=cubit-vs-bloc) to manage the various feature states.
- [Layered Architecture](/architecture) for separation of concerns and to facilitate reusability.
- [BlocObserver](/coreconcepts?id=blocobserver) to observe state changes.
- [BlocProvider](/flutterbloccoreconcepts?id=blocprovider), a Flutter widget which provides a bloc to its children.
- [BlocBuilder](/flutterbloccoreconcepts?id=blocbuilder), a Flutter widget that handles building the widget in response to new states.
- [BlocListener](/flutterbloccoreconcepts?id=bloclistener), a Flutter widget that handlers performing side-effects in response to state changes.
- [RespositoryProvider](/flutterbloccoreconcepts?id=respositoryprovider), a Flutter widget to provide a repository to its children.
- [Equatable](/faqs?id=when-to-use-equatable) to prevent unnecessary rebuilds.
- [MultiBlocListener](/flutterbloccoreconcepts?id=multibloclistener), a Flutter widget that reduces nesting when using multiple BlocListeners.

## Overview

[INSERT LAYERED ARCHITECTURE DIAGRAM HERE]

## todos_api

The `todos_api` package will export a generic interface for interacting/managing todos. Later we'll implement the `TodosApi` using `shared_preferences` but having an abstraction will make it easy to support other implementations without having to change any other part of our application. For example, we can later add a `FirestoreTodosApi` which uses `cloud_firestore` instead of `shared_preferences` with minimal code changes to the rest of the application. 

[pubspec.yaml](https://raw.githubusercontent.com/felangel/bloc/docs/flutter-todos-v8.0.0/examples/flutter_todos/packages/todos_api/pubspec.yaml ':include')

[todos_api.dart](https://raw.githubusercontent.com/felangel/bloc/docs/flutter-todos-v8.0.0/examples/flutter_todos/packages/todos_api/lib/src/todos_api.dart ':include')

### Todo model

Now is a good time to introduce the model for a `Todo`.

The first thing of note is that the `Todo` model doesn't live in our app -- it's part of the `todos_api` package. This is because the `TodosApi` defines APIs that returns/accept `Todo` objects and the model is a Dart representation of the raw Todo object that will be stored/retrieved.

The `Todo` model uses [json_serializable](https://pub.dev/packages/json_serializable) to handle the json (de)serialization. If you are following along you will have to run the [code generation step](https://pub.dev/packages/json_serializable#running-the-code-generator) to resolve the compiler errors.

[todo.dart](https://raw.githubusercontent.com/felangel/bloc/docs/flutter-todos-v8.0.0/examples/flutter_todos/packages/todos_api/lib/src/models/todo.dart ':include')

`json_map.dart` provides a `typedef` for code checking and linting.

[json_map.dart](https://raw.githubusercontent.com/felangel/bloc/docs/flutter-todos-v8.0.0/examples/flutter_todos/packages/todos_api/lib/src/models/json_map.dart ':include')

The model of the `Todo` is defined in: `todos_api/models/todo.dart` and is exported by `package:todos_api/todos_api.dart`.
### Streams vs Futures

In a previous version of this tutorial, the `TodosApi` was `Future`-based rather than `Stream`-based.

For an example of a `Future`-based API see [Brian Egan's implementation in his Architecture Samples](https://github.com/brianegan/flutter_architecture_samples/tree/master/todos_repository_core).

A `Future`-based implementation could consist of two methods: `loadTodos` and `saveTodos` (note the plural). This means, a full list of Todos must be provided to the method each time.

- One limitation of this approach is that the standard CRUD (Create, Read, Update, and Delete) operation requires sending the full list of Todos with each call. For example, on an Add Todo screen, one cannot just send the added todo item. Instead, we must keep track of the entire list and provide the entire new list of todos when persisting the updated list.
- A second limitation is that `loadTodos` is a one-time delivery of data. The app must contain logic to ask for updates periodically. This is okay if an app is for a single-user, on a single device, and not connected to the cloud; however, many modern apps support
  - a single user signed in on multiple devices at once
  - multiple users adding to the same data-set (like a group todo-list)

As a result, in the current implementation, the `TodosApi` exposes a `Stream<List<Todo>>` via `getTodos()` which will report real-time updates to all subscribers when the list of todos has changed.

In addition, Todos can be created, deleted, or updated individually. For example, both deleting and saving a Todo are done with only the `todo` as the argument. It's not necessary to provide the newly updated list of todos each time.

## local_storage_todos_api

This package implements the `todos_api` using the [`shared_preferences`](https://pub.dev/packages/shared_preferences) package.

[pubspec.yaml](https://raw.githubusercontent.com/felangel/bloc/docs/flutter-todos-v8.0.0/examples/flutter_todos/packages/local_storage_todos_api/pubspec.yaml ':include')

[local_storage_todos_api.dart](https://raw.githubusercontent.com/felangel/bloc/docs/flutter-todos-v8.0.0/examples/flutter_todos/packages/local_storage_todos_api/lib/src/local_storage_todos_api.dart ':include')

## todos_repository

A [repository](/architecture?id=repository) is part of the "business layer". A repository depends on one or more data providers that have no business value, and composes their public API into APIs that represent business value. In addition, having a repository layer helps abstract data-acquisition from the rest of the application allowing us to change where/how data is being stored without affecting other parts of the app.

[todos_repository.dart](https://raw.githubusercontent.com/felangel/bloc/docs/flutter-todos-v8.0.0/examples/flutter_todos/packages/todos_repository/lib/src/todos_repository.dart ':include')

Instantiating or constructing the repository requires specifying a `TodosApi`, which we discussed earlier in this tutorial, so we added it as a dependency in our `pubspec.yaml`:

[pubspec.yaml](https://raw.githubusercontent.com/felangel/bloc/docs/flutter-todos-v8.0.0/examples/flutter_todos/packages/todos_repository/pubspec.yaml ':include')

### Library Exports.

In addition to exporting the `TodosRepository` class, we also export the `Todo` model from the `todos_api` package from the `todos_repository` in order to prevent tight coupling between the application and the data providers.

[todos_repository.dart](https://raw.githubusercontent.com/felangel/bloc/docs/flutter-todos-v8.0.0/examples/flutter_todos/packages/todos_repository/lib/todos_repository.dart ':include')

We decided to re-export the same `Todo` model from the `todos_api` rather than re-defining a separate model in the `todos_repository` because in this case we are in complete control of the data model. In many cases, the data provider will not be something that you as a developer can control and in those cases it becomes increasingly important to maintain your own model definitions in the repository layer in order to maintain full control of the interface and API contract.

## App

We'll start off by creating a brand new Flutter project using the [`very_good_cli`](https://pub.dev/packages/very_good_cli). We'll use the default `very_good_core` template:

```sh
very_good create flutter_todos --desc "An example todos app that showcases bloc state management patterns."
```

?> **💡 Tip**: you can install `very_good_cli` via `dart pub global activate very_good_cli`.

We can then replace the contents of `pubspec.yaml` with:

[pubspec.yaml](https://raw.githubusercontent.com/felangel/bloc/docs/flutter-todos-v8.0.0/examples/flutter_todos/pubspec.yaml ':include')

and then install all the dependencies:

```sh
very_good packages get --recursive
```

### App widget

`App` and `AppView` are near top-level widgets.

`App` wraps a `RepositoryProvider` widget that provides the repository to all children/descendents. Since both `EditTodoPage` subtree and the `HomePage` subtree's are descendents, all the blocs and cubits can access the repository.

`AppView` creates the `MaterialApp` and configures the theme and localizations.

[app.dart](https://raw.githubusercontent.com/felangel/bloc/docs/flutter-todos-v8.0.0/examples/flutter_todos/lib/app/app.dart ':include')

### Theme

This provides theme definition for light and dark mode.

[theme.dart](https://raw.githubusercontent.com/felangel/bloc/docs/flutter-todos-v8.0.0/examples/flutter_todos/lib/theme/theme.dart ':include')

### Bootstrapping

`bootstrap.dart` loads our `BlocObserver` and creates the instance of `TodosRepository`.

[bootstrap.dart](https://raw.githubusercontent.com/felangel/bloc/docs/flutter-todos-v8.0.0/examples/flutter_todos/lib/bootstrap.dart ':include')

### Main

Our app's entrypoint is `main.dart`. In this case, there are three versions:

The most notable thing is that this is where the concrete implementation of the `todos_api` is instantiated -- in our case it's the `local_storage_todos_api`.

#### `main_development.dart`

[main_development.dart](https://raw.githubusercontent.com/felangel/bloc/docs/flutter-todos-v8.0.0/examples/flutter_todos/lib/main_development.dart ':include')

#### `main_staging.dart`

[main_staging.dart](https://raw.githubusercontent.com/felangel/bloc/docs/flutter-todos-v8.0.0/examples/flutter_todos/lib/main_staging.dart ':include')

#### `main_production.dart`

[main_production.dart](https://raw.githubusercontent.com/felangel/bloc/docs/flutter-todos-v8.0.0/examples/flutter_todos/lib/main_production.dart ':include')

### TodosOverview

#### TodosOverviewEvent

Although it is typical to start with describing the underlying `Todo` model, it is instructive to wait. We can understand `TodosOverviewEvents` without understanding the underlying structure of a `Todo`. This way, if we change our `Todo` model, we don't have to change the associated Events.

Let's create `todos_overview/bloc/todos_overview_event.dart` and define the events.

[todos_overview_event.dart.md](_snippets/flutter_todos_tutorial/lib/todos_overview_event.dart.md ':include') [//]: # (HCTOKEN)

Here is a discussion of events grouped by function:
- Startup events (no arguments)
  - `TodosOverviewSubscriptionRequested` - This is the startup event. The intention is to have the bloc get a subscription to the `TodosRepository`. In this case, that will be a `Stream`.
- Modifying a single Todo (these take a Todo as an argument)
  - `TodosOverviewTodoSaved` - This saves a Todo. Note: The Todo could be either a new Todo (create) or an existing Todo (update).
  - `TodosOverviewTodoDeleted` - This deletes a Todo.
  - `TodosOverviewTodoCompletionToggled` - This toggles a Todo's completed. It also takes `isCompleted` as a second argument. <!--- 'HCcomment, the event maybe should be renamed TodosOverviewTodoCompletionSet. A toggle wouldn't take the 2nd argument' -->
- Modifying multiple Todos (these operate on multiple Todos, no arguments)
  - `TodosOverviewToggleAllRequested` - Toggles completion for all. Like "Mark all as Done". If all Todos are marked as done, then this event will toggle them to not done.
  - `TodosOverviewClearCompletedRequested` - Deletes all completed Todos.
- Special
  - `TodosOverviewUndoDeletionRequested` - This undoes a Todo delete, e.g. an accidental deletion. Note: As implemented, this doesn't provide a Todo as an argument. So, this suggests that the `TodosOverviewState` will have to keep track of the most recently deleted Todo.
  - `TodosOverviewFilterChanged` - This takes a `TodosViewFilter` as an argument and changes the view by applying a filter. This suggests that `TodosOverviewState` will keep track of the current view filter.

#### TodosOverviewState

Let's create `todos_overview/bloc/todos_overview_state.dart` and define the different states we'll need to handle.

[todos_overview_state.dart.md](_snippets/flutter_todos_tutorial/lib/todos_overview_state.dart.md ':include') [//]: # (HCTOKEN)

!> As discussed when explaining the events, `TodosOverviewState` will keep track of a list of Todos, but also the view filter state, the `lastDeletedTodo`, and the status.

Looking at the annotated default constructor below, we see the elements of the state.

```dart
const TodosOverviewState({
  this.status = TodosOverviewStatus.initial,
  this.todos = const [],
  this.filter = TodosViewFilter.all,
  this.lastDeletedTodo,
});

final TodosOverviewStatus status;   // The status
final List<Todo> todos;             // The list of Todos.
final TodosViewFilter filter;       // A filter for the view
final Todo? lastDeletedTodo;        // A Todo of the last deleted item, used for Undo
```

`TodosOverviewStatus` has the following four options/statuses. Because we are using Streams and async calls to the TodosRepository, this keeps track of the lifecycle of async calls. The instantiation (during app startup) sets it to `initial`. The business logic of the bloc will use the other statuses.

```dart
enum TodosOverviewStatus { initial, loading, success, failure }
```

Lastly, notice that in addition to the default getters and setters, we have a custom getter called `filteredTodos`. 

```dart
Iterable<Todo> get filteredTodos => filter.applyAll(todos);
```

- Thinking ahead to widgets and views using `BlocBuilder`, we can use either `state.filteredTodos` or `state.todos`. The UI doesn't have to understand the filtering logic.

#### TodosOverviewBloc

Let's create `todos_overview/bloc/todos_overview_bloc.dart` and get started defining the business logic!

[todos_overview_bloc.dart.md](_snippets/flutter_todos_tutorial/lib/todos_overview_bloc.dart.md ':include') [//]: # (HCTOKEN)

> To review, this bloc is like all blocs: `TodosOverviewBloc` will:

1. Respond to UI events.
2. Emit states.
3. Listen to non-UI messages, like input data `Streams` (sinks).
4. Implement the business logic of what to do.

Breaking the code down, we first have the constructor.

```dart
class TodosOverviewBloc extends Bloc<TodosOverviewEvent, TodosOverviewState> {
  TodosOverviewBloc({
    required TodosRepository todosRepository,
  })  : _todosRepository = todosRepository,
        super(const TodosOverviewState()) {
    on<TodosOverviewSubscriptionRequested>(_onSubscriptionRequested);
    on<TodosOverviewTodoSaved>(_onTodoSaved);
    on<TodosOverviewTodoCompletionToggled>(_onTodoCompletionToggled);
    on<TodosOverviewTodoDeleted>(_onTodoDeleted);
    on<TodosOverviewUndoDeletionRequested>(_onUndoDeletionRequested);
    on<TodosOverviewFilterChanged>(_onFilterChanged);
    on<TodosOverviewToggleAllRequested>(_onToggleAllRequested);
    on<TodosOverviewClearCompletedRequested>(_onClearCompletedRequested);
  }

  final TodosRepository _todosRepository;
```

The constructor creates handlers for the UI events. Notice that the events in the earlier section [TodosOverviewEvent](#todos_overview_event.dart) exactly match the `on` handlers here. They are then mapped to private callback methods for the class.

Another thing to notice is that `TodosRepository` needs to be passed as an argument when the `TodosOverviewBloc` is created, like in a `BlocProvider` widget. The bloc is not handling the initial connection to the Repository. Instead, the startup process of the app (or something that happens before loading this bloc) will create the repository connection.

The next section to discuss is the `_onSubscriptionRequested` method:

```dart
  Future<void> _onSubscriptionRequested(
    TodosOverviewSubscriptionRequested event,
    Emitter<TodosOverviewState> emit,
    ) async {
  emit(state.copyWith(status: () => TodosOverviewStatus.loading));

  await emit.forEach<List<Todo>>(
    _todosRepository.getTodos(),
    onData: (todos) => state.copyWith(
      status: () => TodosOverviewStatus.success,
      todos: () => todos,
    ),
    onError: (_, __) => state.copyWith(
      status: () => TodosOverviewStatus.failure,
    ),
  );
}
```

The first statement emits a state of `loading`. The UI widget can then create an appropriate loading state, like a CircleProgressIndicator.

The second statement is `emit.forEach<List<Todo>>( ... )`. This sets up the listener for the data stream (i.e. a "sink" for the bloc). This is the data stream from the repository.

!> `emit.forEach()` is not the `forEach()` used by lists. This forEach is for a Stream. It can be thought of as "forEach item yielded by the stream, do these tasks...". It has nothing to do with traversing the list of Todos.

!> The `await` here can be confusing. It's designed to not complete. The `await` is needed to keep the subscription alive. _onSubscriptionRequest doesn't complete until the stream is closed by the repository or the event handler is closed, for example when the bloc is closed.

> You don't see `stream.listen` called directly in this tutorial. Using `await emit.forEach()` is a newer standard canonical pattern for subscribing to a stream.

> Even though the callback is named `_onSubscriptionRequested()` suggesting this code only runs on startup, the effect is long lasting. It creates the subscription but also processes future items generated by the subscription.

The result of the _onSubscriptionRequested event is that the callback set to `onData` is called each time the list of Todos in the `TodosRepository` changes. The `onData` callback emits a the new state and the Flutter framework determines what widgets need to be re-rendered.

---

Now that the subscription is handled, we handle the other events, like adding, modifying, and deleting Todos.

```dart
  Future<void> _onTodoSaved(
    TodosOverviewTodoSaved event,
    Emitter<TodosOverviewState> emit,
    ) async {
  await _todosRepository.saveTodo(event.todo);
}
```

`onTodoSaved()` simply fires a `_todosRepository.saveTodo(event.todo)`.  

> Notice that no `emit` happens to set the new state. This raises the question, how does the state get updated? If the state isn't updated, the UI won't update.

!> The answer is that the repository will send/stream an updated `List<Todo>`. That update is handled in the `await emit.forEach<List<Todo>>()` in `_onSubscriptionRequested()`. When that happens, then the `emit()` occurs.

!> In fact, *none* of the other event handlers emit states with modified `List<Todos>` directly. The pattern is always that (1) the handlers change the Todo list with the `TodosRepository`, and then (2) the new state is streamed from `TodosRepository` , to `TodosOverviewBloc._onSubscriptionRequested` and then finally to the UI via BlocBuilders and BlocListeners.

<!--- consider adding a TodosOverviewStatus.processing status that is set until the handlers are completed. -->

Let's now cover the other methods for Undo and ViewFiltering.

##### Undo

The undo feature allows undeleting the last deleted item. This business logic is not handled by the repository. This is handled via the bloc.

Review the `TodosOverviewState`, re-annotated below. List<Todo> is handled via the repository. Notice that the other 3 parts of the state need to be handled by the bloc.

```dart
const TodosOverviewState({
...
});

final TodosOverviewStatus status;   // handled via the bloc
final List<Todo> todos;             // handled via the repository
final TodosViewFilter filter;       // handled via the bloc
final Todo? lastDeletedTodo;        // handled via the bloc
```

`_onTodoDeleted` in the bloc does two things. First, it emits a new state in line `//1` with the Todo to be deleted. Then, it deletes the Todo in line `//2` via the repository. 
```dart
  Future<void> _onTodoDeleted(
    TodosOverviewTodoDeleted event,
    Emitter<TodosOverviewState> emit,
  ) async {
    emit(state.copyWith(lastDeletedTodo: () => event.todo)); // 1
    await _todosRepository.deleteTodo(event.todo.id);        // 2
  }
```

Eventually (and outside of this code), the state is emitted via the Stream. For more details on this, see a discussion of [event flow](#commentary-event-flow)

---

When the undeletion request event comes from the UI, `_onUndoDeletionRequested()` is run.

- Temporarily saves a copy of the last deleted Todo. 
- Updates the state by removing the lastDeletedTodo from the state. 
- Finally, does the undos the deletion.


```dart
  Future<void> _onUndoDeletionRequested(
    TodosOverviewUndoDeletionRequested event,
    Emitter<TodosOverviewState> emit,
  ) async {
    assert(
      state.lastDeletedTodo != null,
      'Last deleted todo can not be null.',
    );

    final todo = state.lastDeletedTodo!;
    emit(state.copyWith(lastDeletedTodo: () => null));
    await _todosRepository.saveTodo(todo);
  }
```

!> Notice: like in other bloc event handler methods, the undeletion doesn't directly modify the List. <!--- like via a TodosOverviewState.todos.remove(todo); --> It goes through the repository, which then updates via the stream.

##### ViewFilter

View filtering is handled via `_onFilterChanged()`. The code below emits a new state with the new event filter. Note that the list in `TodosOverviewState.todos` is not modified and the bloc doesn't send a filtered list as part of the state. It merely provides the information. The UI decides what needs to be displayed in line with UI=f(state).

```dart
  void _onFilterChanged(
    TodosOverviewFilterChanged event,
    Emitter<TodosOverviewState> emit,
  ) {
    emit(state.copyWith(filter: () => event.filter));
  }
```

#### Models

!> Note: You might be expecting a model for a list of Todos or for `TodosOverview` here. They aren't here. Why? Because we are using bloc, the overall "model" for ToolsOverview is the bloc for ToolsOverview, specifically [ToolsOverviewState](#TodosOverview-States), which holds the Todo list and 3 other state variables.

There is one model file and that deals with the view filtering.

`todos_view_filter.dart` enums the 3 view filters and the methods to apply the filter.

[todos_view_filter.dart.md](_snippets/flutter_todos_tutorial/lib/todos_view_filter.dart.md ':include') [//]: # (HCTOKEN)

`models.dart` is the barrel file for exports.

[models.dart.md](_snippets/flutter_todos_tutorial/lib/models.dart.md ':include') [//]: # (HCTOKEN)

The full `todos_overview_page.dart` is first presented and then discussed below.

[todos_overview_page.dart.md](_snippets/flutter_todos_tutorial/lib/todos_overview_page.dart.md ':include') [//]: # (HCTOKEN)

It is instructive to look at the structure using Flutter Inspector. This is the widget subtree:

![TodosOverviewPage_widget_tree.png](_snippets/flutter_todos_tutorial/images/TodosOverviewPage_widget_tree.png)

Notice where `BlocProvider<TodosOverviewBloc>` is.
- Every widget below this one will have access to the `TodosOverviewBloc`.
- Any other widget (for example, the main MaterialApp widget, or different subtrees) will not have access to it. 

> Notably, `EditTodoPage`, described later, won't have access to `TodosOverviewBloc`.  `EditTodoPage` will use the repository to adjust with the list of Todos. And the repository's stream will talk to the `TodosOverviewBloc`, which then will tell `TodosOverviewPage` to re-render. The key is using the Stream. See a discussion of [event flow](#commentary-event-flow).

`BlocProvider<TodosOverviewBloc>` is accessed three times under `MultiBlocListener`
1. The first is a `BlocListener` dealing with errors, as shown below. `listenWhen` restricts this listener will be called. <br>
   It won't be called for all state changes, only those that correspond to line `//1`.
   Also, the `SnackBar` is only displayed when TodosOverviewStatus.failure at line `//2`. (User Challenge: Add a success snackBar by modifying the if statement.)

```dart
          BlocListener<TodosOverviewBloc, TodosOverviewState>(
            listenWhen: (previous, current) =>
                previous.status != current.status,   //1
            listener: (context, state) {
              if (state.status == TodosOverviewStatus.failure) { //2
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(l10n.todosOverviewErrorSnackbarText),
                    ),
                  );
              }
            },
```

2. The second is a `BlocListener` dealing with deletions, as shown below. `listenWhen` restricts listening so we don't react to unnecessary state changes, like added Todo items or changes of the view. It shows a snack bar and if Undo is selected, it will send a message of `TodosOverviewUndoDeletionRequested` to the bloc.

```dart
         BlocListener<TodosOverviewBloc, TodosOverviewState>(
            listenWhen: (previous, current) =>
                previous.lastDeletedTodo != current.lastDeletedTodo &&
                current.lastDeletedTodo != null,
            listener: (context, state) {
              final deletedTodo = state.lastDeletedTodo!;
              final messenger = ScaffoldMessenger.of(context);
              messenger
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  TodoDeletionConfirmationSnackBar(
                    todo: deletedTodo,
                    onUndo: () {
                      messenger.hideCurrentSnackBar();
                      context
                          .read<TodosOverviewBloc>()
                          .add(const TodosOverviewUndoDeletionRequested());
                    },
                  ),
                );
            },
          ),
```

3. The third is a `BlocBuilder` which builds the ListView that displays the Todos. In focusing on the bloc pattern, notice how and when the  `TodosOverviewTodoCompletionToggled()` and `TodosOverviewTodoDeleted()` events are sent to the bloc.

```dart
                    TodoListTile(
                      todo: todo,
                      onToggleCompleted: (isCompleted) {
                        context.read<TodosOverviewBloc>().add(
                              TodosOverviewTodoCompletionToggled(
                                todo: todo,
                                isCompleted: isCompleted,
                              ),
                            );
                      },
                      onDismissed: (_) {
                        context
                            .read<TodosOverviewBloc>()
                            .add(TodosOverviewTodoDeleted(todo));
                      },
                      onTap: () {
                        Navigator.of(context).push(
                          EditTodoPage.route(initialTodo: todo),
                        );
                      },
                    )
```

The `AppBar` of this scaffold also has two actions which are the top-right dropdowns. These are covered below in Widgets.
```dart
        actions: const [
          TodosOverviewFilterButton(),
          TodosOverviewOptionsButton(),
        ],
```

`view.dart` is the export barrel file.

[view.dart3.md todos_overview](_snippets/flutter_todos_tutorial/lib/view.dart3.md ':include') [//]: # (HCTOKEN)


#### Widgets

`widgets.dart` is a barrel file.

[widgets.dart.md](_snippets/flutter_todos_tutorial/lib/widgets.dart.md ':include') [//]: # (HCTOKEN)

`todo_deletion_confirmation_snack_bar.dart` is the deletion snack bar that also implements undelete.

[todo_deletion_confirmation_snack_bar.dart.md](_snippets/flutter_todos_tutorial/lib/todo_deletion_confirmation_snack_bar.dart.md ':include') [//]: # (HCTOKEN)

`todo_list_tile.dart` is the ListTile for each Todo.

[todo_list_tile.dart.md](_snippets/flutter_todos_tutorial/lib/todo_list_tile.dart.md ':include') [//]: # (HCTOKEN)

`todos_overview_options_button.dart` exposes two options. Paying attention to the bloc pattern, notice how events are passed to the bloc in `onSelected`.

[todos_overview_options_button.dart.md](_snippets/flutter_todos_tutorial/lib/todos_overview_options_button.dart.md ':include') [//]: # (HCTOKEN)

`todos_overview_filter_button.dart` exposes three filter options. Paying attention to the bloc pattern, notice how events are passed to the bloc in `onSelected`.

[todos_overview_filter_button.dart.md](_snippets/flutter_todos_tutorial/lib/todos_overview_filter_button.dart.md ':include') [//]: # (HCTOKEN)

## Stats

### StatsState

`StatsState` keeps track of summary information and the current `StatsStatus`.

[stats_state.dart.md](_snippets/flutter_todos_tutorial/lib/stats_state.dart.md ':include') [//]: # (HCTOKEN)

### StatsEvent

`StatsEvent` has only one event, the subscription event. 

[stats_event.dart.md](_snippets/flutter_todos_tutorial/lib/stats_event.dart.md ':include') [//]: # (HCTOKEN)

### StatsBloc

`StatsBloc` does connect to `TodosRepository`, just like `TodosOverviewBloc`. It subscribes via `_todosRepository.getTodos()`.

> How does StatsBloc know to update? Updates are triggered by the stream, not by any UI event. See a discussion of [event flow](#commentary-event-flow).

> How will the the Stats UI know to update? It gets a state change notification via the `onData` in `emit.forEach()`. When state changes, the `BlocBuilder<StatsBloc>` in [stats_page.dart](#stats-view) knows to rebuild. See a discussion of [event flow](#commentary-event-flow).

[stats_bloc.dart.md](_snippets/flutter_todos_tutorial/lib/stats_bloc.dart.md ':include') [//]: # (HCTOKEN)

### Stats View

`view.dart` manages the export.

[view.dart4.md stats](_snippets/flutter_todos_tutorial/lib/view.dart4.md ':include') [//]: # (HCTOKEN)

`stats_page.dart` is the UI page view.

[stats_page.dart.md](_snippets/flutter_todos_tutorial/lib/stats_page.dart.md ':include') [//]: # (HCTOKEN)

It is instructive to look at the structure using Flutter Inspector. This is the widget subtree:

![StatsPage_widget_tree.png](_snippets/flutter_todos_tutorial/images/StatsPage_widget_tree.png)

Notice how it does not directly get any information from the `List<Todos>` which lives in `TodosOverviewState`. The UI gets all the information from the `StatsBloc` and the `StatsState`. 

!> The commonality between `TodosOverviewBloc` and `StatsBloc` is that they both communicate with the `TodosRepository`. There is no direct communication between the blocs. See a discussion of [event flow](#commentary-event-flow).

## EditTodo

### EditTodoState

`EditTodoState` keeps track of the information needed when editing a Todo. It has the following properties:

1. `status` - Tracks the status, mindful of the async possibilities that the repository or data providers are offline.
2. `initialTodo` - The initial Todo that we are editing.  

  > NOTE: This bloc will also handled creation of a new Todo. In that case, the initial Todo could be null, hence the nullable `Todo?` in the code below.

3. `title` - The title of the Todo. Note: This will be continuosly updated as the UI is updated. Hence we avoid needing to use a TextEditingController.
4. `description` - The description of the Todo.

[edit_todo_state.dart.md](_snippets/flutter_todos_tutorial/lib/edit_todo_state.dart.md ':include') [//]: # (HCTOKEN)

### EditTodoEvent

1. `EditTodoEvent` - When the UI starts an edit (or a new Todo). Note: No arguments. The Todo's information is provided to the state of the bloc.
2. `EditTodoTitleChanged` - When the title changes, even if by one character. Note: requires one argument, the title from the UI. The bloc will later change the state and emit a new state.
3. `EditTodoDescriptionChanged` - When the description changes, even if by one character. Note: requires one argument, the title from the UI. The bloc will later change the state and emit a new state.
4. `EditTodoSubmitted` - Submitting, when editing is complete. Note: No arguments. The Todo's edits are stored in the state of the bloc.

[edit_todo_event.dart.md](_snippets/flutter_todos_tutorial/lib/edit_todo_event.dart.md ':include') [//]: # (HCTOKEN)

### EditTodoBloc

`EditTodoBloc` does connect to `TodosRepository`, just like `TodosOverviewBloc` and `StatsBloc`. 

!> Unlike the other Blocs, `EditTodoBloc` does not subscribe to `_todosRepository.getTodos()`. It is a "write-only" bloc. It doesn't need to read any information from the repository.

[edit_todo_bloc.dart.md](_snippets/flutter_todos_tutorial/lib/edit_todo_bloc.dart.md ':include') [//]: # (HCTOKEN)

#### Event Flow

> How will the the Stats UI and the main list of Todos UI know to update? Where in the code does it tell the other screens to redraw?

 The other parts of the UI gets a state change notification because of their subscription to `TodosRepository`.  There is no direct bloc-to-bloc communication. EditTodosBloc has zero logic about what needs to be done elsewhere. Everything goes through the repository.

This is best explained with the help of a widget tree diagram:

![EditTodoSubmitted_widget_tree_flow.png](_snippets/flutter_todos_tutorial/images/EditTodoSubmitted_widget_tree_flow.png)

This is the flow when the UI submits a `EditTodoSubmitted` event. 

1. The `EditTodoBloc` handles the business logic to update the `TodosRepository`. (In the diagram, the arrow and the Blue box labelled 1. It starts in the bottom left.)
2. `TodosRepository` then notifies `TodosOverviewBloc`. (Blue box 2 and arrow.)
3. `TodosOverviewBloc` notifies the listeners which then re-render widgets. (Blue box 3 and arrow.)
4. `TodosRepository` also notifies `StatsBloc`. (Blue box 4 and arrow.) The listening widgets will also re-render.

### EditTodoPage

[edit_todo_page.dart.md](_snippets/flutter_todos_tutorial/lib/edit_todo_page.dart.md ':include') [//]: # (HCTOKEN)

This page uses `BlocListener` rather than `BlocBuilder` for a very specific reason. `BlocListener` here is restricting re-rendering to after we submit via `current.status == EditTodoStatus.success` in the code snippet below.

```dart
return BlocListener<EditTodoBloc, EditTodoState>(
  listenWhen: (previous, current) =>
    previous.status != current.status &&
    current.status == EditTodoStatus.success,
// ...
```

> What happens if we use `BlocBuilder` instead? Our UI will re-render with every keystroke. For example, if we type "LUNCH", it will re-render 5 times. Each modification generates a new `EditTodoState` which stores the current working string.
 The 5 changes are for "L", "LU", "LUN", "LUNC", and "LUNCH".

> Another common approach is to use a TextEditingController to store the local state, but that [requires a StatefulWidget](https://stackoverflow.com/questions/59652639/why-is-texteditingcontroller-always-used-in-stateful-widgets). In this tutorial, we construct zero stateful widgets to demonstrate that bloc can eliminate most needs to use a stateful widget directly. (Stateful widgets are still used in the underlying abstraction layers (aka packages), like [provider](https://pub.dev/documentation/provider/latest/). But those low-level details are abstracted away by bloc.)


It is instructive to look at the structure using Flutter Inspector. This is the widget tree:

![EditTodosPage_widget_tree.png](_snippets/flutter_todos_tutorial/images/EditTodosPage_widget_tree.png)

Notice how `EditTodosPage` is in the bottom half of the displayed widget tree. It is a sibling to `HomePage`. 

!> Does `EditTodosPage` need access to the whole list of Todos or other state? It has no access to the list of Todos provided by `ToolsOverviewBloc` because it isn't under the `BlocProvider<ToolsOverviewBloc>`. (Not displayed in the widget tree, because it is under `TodosOverviewPage`)
But, importantly, because of the [architectural decisions](#commentary), it doesn't need any access to that.


## Home

### HomeState

There are only two states associated with the two screens: `todos` and `stats`. EditTodo is not a screen controlled by the Home Cubit.

[home_state.dart.md](_snippets/flutter_todos_tutorial/lib/home_state.dart.md ':include') [//]: # (HCTOKEN)

### HomeCubit

A cubit is appropriate due to the simplicity of the business logic. We have one function `setTab` to change the tab.

[home_cubit.dart.md](_snippets/flutter_todos_tutorial/lib/home_cubit.dart.md ':include') [//]: # (HCTOKEN)

### HomeView

`view.dart` manages the export.

[view.dart2.md edit](_snippets/flutter_todos_tutorial/lib/view.dart2.md ':include') [//]: # (HCTOKEN)

`home_page.dart` is the UI page view.

[home_page.dart.md](_snippets/flutter_todos_tutorial/lib/home_page.dart.md ':include') [//]: # (HCTOKEN)

It is instructive to look at the structure using Flutter Inspector. This is the widget tree:

![HomePage_widget_tree.png](_snippets/flutter_todos_tutorial/images/HomePage_widget_tree.png)

`HomePage` is near the top, followed by `BlocProvider<HomeCubit>`. The next widget, `Homeview` uses the `HomeCubit` state via the following line:

```dart
Widget build(BuildContext context) {
  final selectedTab = context.select((HomeCubit cubit) => cubit.state.tab);
  //...
```

BlocBuilders and BlocListeners could be used, but they are unnecessary. The `context.select` will listen for any changes and trigger a rebuild.

---

`BottomAppBar` is several steps below. The key line for is when the cubit function call is sent from the UI to the cubit. 

```dart
    onPressed: () => context.read<HomeCubit>().setTab(value),
```

This is the key line, and uses a `context.read`.

!> `context.read` doesn't listen for changes, but this is just used to access to `HomeCubit` to call the `setTab`, so no updating is needed.


## Full Source

The full source for this example can be found [here](https://github.com/felangel/Bloc/tree/master/examples/flutter_todos).
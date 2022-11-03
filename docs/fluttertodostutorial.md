# Flutter Todos Tutorial

![advanced](https://img.shields.io/badge/level-advanced-red.svg)

> In the following tutorial, we're going to build a todos app in Flutter using the Bloc library.

![demo](./assets/gifs/flutter_todos.gif)

## Key Topics

- [Bloc and Cubit](/coreconcepts?id=cubit-vs-bloc) to manage the various feature states.
- [Layered Architecture](/architecture) for separation of concerns and to facilitate reusability.
- [BlocObserver](/coreconcepts?id=blocobserver) to observe state changes.
- [BlocProvider](/flutterbloccoreconcepts?id=blocprovider), a Flutter widget which provides a bloc to its children.
- [BlocBuilder](/flutterbloccoreconcepts?id=blocbuilder), a Flutter widget that handles building the widget in response to new states.
- [BlocListener](/flutterbloccoreconcepts?id=bloclistener), a Flutter widget that handlers performing side effects in response to state changes.
- [RepositoryProvider](/flutterbloccoreconcepts?id=repositoryprovider), a Flutter widget to provide a repository to its children.
- [Equatable](/faqs?id=when-to-use-equatable) to prevent unnecessary rebuilds.
- [MultiBlocListener](/flutterbloccoreconcepts?id=multibloclistener), a Flutter widget that reduces nesting when using multiple BlocListeners.

## Setup

We'll start off by creating a brand new Flutter project using the [very_good_cli](https://pub.dev/packages/very_good_cli).

```sh
very_good create flutter_todos --desc "An example todos app that showcases bloc state management patterns."
```

?> **💡 Tip**: You can install `very_good_cli` via `dart pub global activate very_good_cli`.

Next we'll create the `todos_api`, `local_storage_todos_api`, and `todos_repository` packages using `very_good_cli`:

```sh
# create package:todos_api under packages/todos_api
very_good create todos_api -o packages -t dart_pkg --desc "The interface and models for an API providing access to todos."

# create package:local_storage_todos_api under packages/local_storage_todos_api
very_good create local_storage_todos_api -o packages -t flutter_pkg --desc "A Flutter implementation of the TodosApi that uses local storage."

# create package:todos_repository under packages/todos_repository
very_good create todos_repository -o packages -t dart_pkg --desc "A repository that handles todo related requests."
```

We can then replace the contents of `pubspec.yaml` with:

[pubspec.yaml](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_todos/pubspec.yaml ':include')

Finally, we can install all the dependencies:

```sh
very_good packages get --recursive
```

## Project Structure

Our application project structure should look like:

```sh
├── lib
├── packages
│   ├── local_storage_todos_api
│   ├── todos_api
│   └── todos_repository
└── test
```

We split the project into multiple packages in order to maintain explicit dependencies for each package with clear boundaries that enforce the [single responsibility principle](https://en.wikipedia.org/wiki/Single-responsibility_principle).
Modularizing our project like this has many benefits including but not limited to:
- easy to reuse packages across multiple projects
- CI/CD improvements in terms of efficiency (run checks on only the code that has changed)
- easy to maintain the packages in isolation with their dedicated test suites, semantic versioning, and release cycle/cadence

## Architecture

![Todos Architecture Diagram](_snippets/flutter_todos_tutorial/images/todos_architecture_light.png)

> Layering our code is incredibly important and helps us iterate quickly and with confidence. Each layer has a single responsibility and can be used and tested in isolation. This allows us to keep changes contained to a specific layer in order to minimize the impact on the entire application. In addition, layering our application allows us to easily reuse libraries across multiple projects (especially with respect to the data layer).

Our application consists of three main layers:

- data layer
- domain layer
- feature layer
  - presentation/UI (widgets)
  - business logic (blocs/cubits)

**Data Layer**

This layer is the lowest layer and is responsible for retrieving raw data from external sources such as a databases, APIs, and more. Packages in the data layer generally should not depend on any UI and can be reused and even published on [pub.dev](https://pub.dev) as a standalone package. In this example, our data layer consists of the `todos_api` and `local_storage_todos_api` packages.

**Domain Layer**

This layer combines one or more data providers and applies "business rules" to the data. Each component in this layer is called a repository and each repository generally manages a single domain. Packages in the repository layer should generally only interact with the data layer. In this example, our repository layer consists of the `todos_repository` package.

**Feature Layer**

This layer contains all of the application-specific features and use cases. Each feature generally consists of some UI and business logic. Features should generally be independent of other features so that they can easily be added/removed without impacting the rest of the codebase. Within each feature, the state of the feature along with any business logic is managed by blocs. Blocs interact with zero or more repositories. Blocs react to events and emit states which trigger changes in the UI. Widgets within each feature should generally only depend on the corresponding bloc and render UI based on the current state. The UI can notify the bloc of user input via events. In this example, our application will consist of the `home`, `todos_overview`, `stats`, and `edit_todos` features.

Now that we've gone over the layers at a high level, let's start building our application starting with the data layer!

## Data Layer

The data layer is the lowest layer in our application and consists of raw data providers. Packages in this layer are primarily concerned with where/how data is coming from. In this case our data layer will consist of the `TodosApi`, which is an interface, and the `LocalStorageTodosApi`, which is an implementation of the `TodosApi` backed by `shared_preferences`.

### TodosApi

The `todos_api` package will export a generic interface for interacting/managing todos. Later we'll implement the `TodosApi` using `shared_preferences`. Having an abstraction will make it easy to support other implementations without having to change any other part of our application. For example, we can later add a `FirestoreTodosApi`, which uses `cloud_firestore` instead of `shared_preferences`, with minimal code changes to the rest of the application. 

[pubspec.yaml](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_todos/packages/todos_api/pubspec.yaml ':include')

[todos_api.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_todos/packages/todos_api/lib/src/todos_api.dart ':include')

#### Todo model

Next we'll define our `Todo` model.

The first thing of note is that the `Todo` model doesn't live in our app — it's part of the `todos_api` package. This is because the `TodosApi` defines APIs that return/accept `Todo` objects. The model is a Dart representation of the raw Todo object that will be stored/retrieved.

The `Todo` model uses [json_serializable](https://pub.dev/packages/json_serializable) to handle the json (de)serialization. If you are following along, you will have to run the [code generation step](https://pub.dev/packages/json_serializable#running-the-code-generator) to resolve the compiler errors.

[todo.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_todos/packages/todos_api/lib/src/models/todo.dart ':include')

`json_map.dart` provides a `typedef` for code checking and linting.

[json_map.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_todos/packages/todos_api/lib/src/models/json_map.dart ':include')

The model of the `Todo` is defined in `todos_api/models/todo.dart` and is exported by `package:todos_api/todos_api.dart`.

#### Streams vs Futures

In a previous version of this tutorial, the `TodosApi` was `Future`-based rather than `Stream`-based.

For an example of a `Future`-based API see [Brian Egan's implementation in his Architecture Samples](https://github.com/brianegan/flutter_architecture_samples/tree/master/todos_repository_core).

A `Future`-based implementation could consist of two methods: `loadTodos` and `saveTodos` (note the plural). This means, a full list of todos must be provided to the method each time.

- One limitation of this approach is that the standard CRUD (Create, Read, Update, and Delete) operation requires sending the full list of todos with each call. For example, on an Add Todo screen, one cannot just send the added todo item. Instead, we must keep track of the entire list and provide the entire new list of todos when persisting the updated list.
- A second limitation is that `loadTodos` is a one-time delivery of data. The app must contain logic to ask for updates periodically. 

In the current implementation, the `TodosApi` exposes a `Stream<List<Todo>>` via `getTodos()` which will report real-time updates to all subscribers when the list of todos has changed.

In addition, todos can be created, deleted, or updated individually. For example, both deleting and saving a todo are done with only the `todo` as the argument. It's not necessary to provide the newly updated list of todos each time.

### LocalStorageTodosApi

This package implements the `todos_api` using the [`shared_preferences`](https://pub.dev/packages/shared_preferences) package.

[pubspec.yaml](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_todos/packages/local_storage_todos_api/pubspec.yaml ':include')

[local_storage_todos_api.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_todos/packages/local_storage_todos_api/lib/src/local_storage_todos_api.dart ':include')

## Repository Layer

A [repository](/architecture?id=repository) is part of the business layer. A repository depends on one or more data providers that have no business value, and combines their public API into APIs that provide business value. In addition, having a repository layer helps abstract data acquisition from the rest of the application, allowing us to change where/how data is being stored without affecting other parts of the app.

### TodosRepository


[todos_repository.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_todos/packages/todos_repository/lib/src/todos_repository.dart ':include')

Instantiating the repository requires specifying a `TodosApi`, which we discussed earlier in this tutorial, so we added it as a dependency in our `pubspec.yaml`:

[pubspec.yaml](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_todos/packages/todos_repository/pubspec.yaml ':include')

#### Library Exports

In addition to exporting the `TodosRepository` class, we also export the `Todo` model from the `todos_api` package. This step prevents tight coupling between the application and the data providers.

[todos_repository.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_todos/packages/todos_repository/lib/todos_repository.dart ':include')

We decided to re-export the same `Todo` model from the `todos_api`, rather than redefining a separate model in the `todos_repository`, because in this case we are in complete control of the data model. In many cases, the data provider will not be something that you can control. In those cases, it becomes increasingly important to maintain your own model definitions in the repository layer to maintain full control of the interface and API contract.

## Feature Layer

### Entrypoint

Our app's entrypoint is `main.dart`. In this case, there are three versions:

#### `main_development.dart`

[main_development.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_todos/lib/main_development.dart ':include')

#### `main_staging.dart`

[main_staging.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_todos/lib/main_staging.dart ':include')

#### `main_production.dart`

[main_production.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_todos/lib/main_production.dart ':include')

The most notable thing is the concrete implementation of the `local_storage_todos_api` is instantiated within each entrypoint.

### Bootstrapping

`bootstrap.dart` loads our `BlocObserver` and creates the instance of `TodosRepository`.

[bootstrap.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_todos/lib/bootstrap.dart ':include')

### App

`App` wraps a `RepositoryProvider` widget that provides the repository to all children. Since both the `EditTodoPage` and `HomePage` subtrees are descendents, all the blocs and cubits can access the repository.

`AppView` creates the `MaterialApp` and configures the theme and localizations.

[app.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_todos/lib/app/app.dart ':include')

### Theme

This provides theme definition for light and dark mode.

[theme.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_todos/lib/theme/theme.dart ':include')

### Home

The home feature is responsible for managing the state of the currently-selected tab and displays the correct subtree.

#### HomeState

There are only two states associated with the two screens: `todos` and `stats`.

?> **Note**: `EditTodo` is a separate route therefore it isn't part of the `HomeState`.

[home_state.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_todos/lib/home/cubit/home_state.dart ':include')

#### HomeCubit

A cubit is appropriate in this case due to the simplicity of the business logic. We have one method `setTab` to change the tab.

[home_cubit.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_todos/lib/home/cubit/home_cubit.dart ':include')

#### HomeView

`view.dart` is a barrel file that exports all relevant UI components for the home feature.

[view.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_todos/lib/home/view/view.dart ':include')

`home_page.dart` contains the UI for the root page that the user will see when the app is launched.

[home_page.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_todos/lib/home/view/home_page.dart ':include')

A simplified representation of the widget tree for the `HomePage` is:

```
├── HomePage
│   └── BlocProvider<HomeCubit>
│       └── HomeView
│           ├── context.select<HomeCubit, HomeTab>
│           └── BottomAppBar
│               └── HomeTabButton(s)
│                   └── context.read<HomeCubit>
```

The `HomePage` provides an instance of `HomeCubit` to `HomeView`. `HomeView` uses `context.select` to selectively rebuild whenever the tab changes.
This allows us to easily widget test `HomeView` by providing a mock `HomeCubit` and stubbing the state.

The `BottomAppBar` contains `HomeTabButton` widgets which call `setTab` on the `HomeCubit`. The instance of the cubit is looked up via `context.read` and the appropriate method is invoked on the cubit instance.

!> `context.read` doesn't listen for changes, it is just used to access to `HomeCubit` and call `setTab`.

### TodosOverview

The todos overview feature allows users to manage their todos by creating, editing, deleting, and filtering todos.

#### TodosOverviewEvent

Let's create `todos_overview/bloc/todos_overview_event.dart` and define the events.

[todos_overview_event.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_todos/lib/todos_overview/bloc/todos_overview_event.dart ':include')

- `TodosOverviewSubscriptionRequested`: This is the startup event. In response, the bloc subscribes to the stream of todos from the `TodosRepository`.
- `TodosOverviewTodoDeleted`: This deletes a Todo.
- `TodosOverviewTodoCompletionToggled`: This toggles a todo's completed status.
- `TodosOverviewToggleAllRequested`: This toggles completion for all todos.
- `TodosOverviewClearCompletedRequested`: This deletes all completed todos.
- `TodosOverviewUndoDeletionRequested`: This undoes a todo deletion, e.g. an accidental deletion.
- `TodosOverviewFilterChanged`: This takes a `TodosViewFilter` as an argument and changes the view by applying a filter.

#### TodosOverviewState

Let's create `todos_overview/bloc/todos_overview_state.dart` and define the state.

[todos_overview_state.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_todos/lib/todos_overview/bloc/todos_overview_state.dart ':include')

`TodosOverviewState` will keep track of a list of todos, the active filter, the `lastDeletedTodo`, and the status.

?> **Note**: In addition to the default getters and setters, we have a custom getter called `filteredTodos`. The UI uses `BlocBuilder` to access either `state.filteredTodos` or `state.todos`.

#### TodosOverviewBloc

Let's create `todos_overview/bloc/todos_overview_bloc.dart`.

[todos_overview_bloc.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_todos/lib/todos_overview/bloc/todos_overview_bloc.dart ':include')

?> **Note**: The bloc does not create an instance of the `TodosRepository` internally. Instead, it relies on an instance of the repository to be injected via constructor.

##### onSubscriptionRequested

When `TodosOverviewSubscriptionRequested` is added, the bloc starts by emitting a `loading` state. In response, the UI can then render a loading indicator.

Next, we use `emit.forEach<List<Todo>>( ... )` which creates a subscription on the todos stream from the `TodosRepository`.

!> `emit.forEach()` is not the same `forEach()` used by lists. This `forEach` enables the bloc to subscribe to a `Stream` and emit a new state for each update from the stream.

?> **Note**: `stream.listen` is never called directly in this tutorial. Using `await emit.forEach()` is a newer pattern for subscribing to a stream which allows the bloc to manage the subscription internally.

Now that the subscription is handled, we will handle the other events, like adding, modifying, and deleting todos.

##### onTodoSaved

`_onTodoSaved` simply calls `_todosRepository.saveTodo(event.todo)`.

?> **Note**: `emit` is never called from within `onTodoSaved` and many other event handlers. Instead, they notify the repository which emits an updated list via the todos stream. See the [data flow](#data-flow) section for more information.

##### Undo

The undo feature allows users to restore the last deleted item.

`_onTodoDeleted` does two things. First, it emits a new state with the `Todo` to be deleted. Then, it deletes the `Todo` via a call to the repository.

`_onUndoDeletionRequested` runs when the undo deletion request event comes from the UI.

`_onUndoDeletionRequested` does the following:

- Temporarily saves a copy of the last deleted todo. 
- Updates the state by removing the `lastDeletedTodo`. 
- Reverts the deletion.

##### Filtering

`_onFilterChanged` emits a new state with the new event filter.

#### Models

There is one model file that deals with the view filtering.

`todos_view_filter.dart` is an enum that represents the three view filters and the methods to apply the filter.

[todos_view_filter.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_todos/lib/todos_overview/models/todos_view_filter.dart ':include')

`models.dart` is the barrel file for exports.

[models.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_todos/lib/todos_overview/models/models.dart ':include')

Next, let's take a look at the `TodosOverviewPage`.

#### TodosOverviewPage

[todos_overview_page.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_todos/lib/todos_overview/view/todos_overview_page.dart ':include')

A simplified representation of the widget tree for the `TodosOverviewPage` is:

```
├── TodosOverviewPage
│   └── BlocProvider<TodosOverviewBloc>
│       └── TodosOverviewView
│           ├── BlocListener<TodosOverviewBloc>
│           └── BlocListener<TodosOverviewBloc>
│               └── BlocBuilder<TodosOverviewBloc>
│                   └── ListView
```

Just as with the `Home` feature, the `TodosOverviewPage` provides an instance of the `TodosOverviewBloc` to the subtree via `BlocProvider<TodosOverviewBloc>`. This scopes the `TodosOverviewBloc` to just the widgets below `TodosOverviewPage`.

There are three widgets that are listening for changes in the `TodosOverviewBloc`.

1. The first is a `BlocListener` that listens for errors. The `listener` will only be called when `listenWhen` returns `true`. If the status is `TodosOverviewStatus.failure`, a `SnackBar` is displayed.

2. We created a second `BlocListener` that listens for deletions. When a todo has been deleted, a `SnackBar` is displayed with an undo button. If the user taps undo, the `TodosOverviewUndoDeletionRequested` event will be added to the bloc.

3. Finally, we use a `BlocBuilder` to builds the ListView that displays the todos.

The `AppBar`contains two actions which are dropdowns for filtering and manipulating the todos.

?> **Note**: `TodosOverviewTodoCompletionToggled` and `TodosOverviewTodoDeleted` are added to the bloc via `context.read`.

`view.dart` is the barrel file that exports `todos_overview_page.dart`.

[view.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_todos/lib/todos_overview/view/view.dart ':include')

#### Widgets

`widgets.dart` is another barrel file that exports all the components used within the `todos_overview` feature.

[widgets.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_todos/lib/todos_overview/widgets/widgets.dart ':include')

`todo_list_tile.dart` is the `ListTile` for each todo item.

[todo_list_tile.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_todos/lib/todos_overview/widgets/todo_list_tile.dart ':include')

`todos_overview_options_button.dart` exposes two options for manipulating todos:
  - `toggleAll`
  - `clearCompleted`

[todos_overview_options_button.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_todos/lib/todos_overview/widgets/todos_overview_options_button.dart ':include')

`todos_overview_filter_button.dart` exposes three filter options:
  - `all`
  - `activeOnly`
  - `completedOnly`

[todos_overview_filter_button.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_todos/lib/todos_overview/widgets/todos_overview_filter_button.dart ':include')

### Stats

The stats feature displays statistics about the active and completed todos.

#### StatsState

`StatsState` keeps track of summary information and the current `StatsStatus`.

[stats_state.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_todos/lib/stats/bloc/stats_state.dart ':include')

#### StatsEvent

`StatsEvent` has only one event called `StatsSubscriptionRequested`: 

[stats_event.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_todos/lib/stats/bloc/stats_event.dart ':include')

#### StatsBloc

`StatsBloc` depends on the `TodosRepository` just like `TodosOverviewBloc`. It subscribes to the todos stream via `_todosRepository.getTodos`.

[stats_bloc.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_todos/lib/stats/bloc/stats_bloc.dart ':include')

#### Stats View

`view.dart` is the barrel file for the `stats_page`.

[view.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_todos/lib/stats/view/view.dart ':include')

`stats_page.dart` contains the UI for the page that displays the todos statistics.

[stats_page.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_todos/lib/stats/view/stats_page.dart ':include')

A simplified representation of the widget tree for the `StatsPage` is:

```
├── StatsPage
│   └── BlocProvider<StatsBloc>
│       └── StatsView
│           ├── context.watch<StatsBloc>
│           └── Column
```

!> The `TodosOverviewBloc` and `StatsBloc` both communicate with the `TodosRepository`, but it is important to note there is no direct communication between the blocs. See the [data flow](#data-flow) section for more information.

### EditTodo

The `EditTodo` feature allows users to edit an existing todo item and save the changes.

#### EditTodoState

`EditTodoState` keeps track of the information needed when editing a todo.

[edit_todo_state.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_todos/lib/edit_todo/bloc/edit_todo_state.dart ':include')

#### EditTodoEvent

The different events the bloc will react to are:

- `EditTodoTitleChanged`
- `EditTodoDescriptionChanged`
- `EditTodoSubmitted`

[edit_todo_event.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_todos/lib/edit_todo/bloc/edit_todo_event.dart ':include')

#### EditTodoBloc

`EditTodoBloc` depends on the `TodosRepository`, just like `TodosOverviewBloc` and `StatsBloc`. 

!> Unlike the other Blocs, `EditTodoBloc` does not subscribe to `_todosRepository.getTodos`. It is a "write-only" bloc meaning it doesn't need to read any information from the repository.

[edit_todo_bloc.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_todos/lib/edit_todo/bloc/edit_todo_bloc.dart ':include')

##### Data Flow

Even though there are many features that depend on the same list of todos, there is no bloc-to-bloc communication. Instead, all features are independent of each other and rely on the `TodosRepository` to listen for changes in the list of todos, as well as perform updates to the list.

For example, the `EditTodos` doesn't know anything about the `TodosOverview` or `Stats` features.

When the UI submits a `EditTodoSubmitted` event:

- `EditTodoBloc` handles the business logic to update the `TodosRepository`.
- `TodosRepository` notifies `TodosOverviewBloc` and `StatsBloc`.
- `TodosOverviewBloc` and `StatsBloc` notify the UI which update with the new state.

#### EditTodoPage

[edit_todo_page.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_todos/lib/edit_todo/view/edit_todo_page.dart ':include')

Just like with the previous features, the `EditTodosPage` provides an instance of the `EditTodosBloc` via `BlocProvider`. Unlike the other features, the `EditTodosPage` is a separate route which is why it exposes a `static` `route` method. This makes it easy to push the `EditTodosPage` onto the navigation stack via `Navigator.of(context).push(...)`.

A simplified representation of the widget tree for the `EditTodosPage` is:

```
├── BlocProvider<EditTodosBloc>
│   └── EditTodosPage
│       └── BlocListener<EditTodosBloc>
│           └── EditTodosView
│               ├── TitleField
│               ├── DescriptionField
│               └── Floating Action Button
```

## Summary

That's it, we have completed the tutorial! 🎉

The full source code for this example, including unit and widget tests, can be found [here](https://github.com/felangel/bloc/tree/master/examples/flutter_todos).

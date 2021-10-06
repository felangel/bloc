# Recipes: Navigation

> In this recipe, we're going to take a look at how to use `BlocBuilder` and/or `BlocListener` to do navigation. We're going to explore three approaches: Direct Navigation, Route Navigation, and Declarative Navigation using Navigator 2.0.

## Direct Navigation

> In this example, we're going to take a look at how to use `BlocBuilder` to show a specific page (widget) in response to a state change in a bloc without the use of a route.

![demo](./assets/gifs/recipes_flutter_navigation_direct.gif)

### Bloc

Let's build `MyBloc` which will take `MyEvents` and convert them into `MyStates`.

#### MyEvent

For simplicity, our `MyBloc` will only respond to two `MyEvents`: `EventA` and `EventB`.

[my_event.dart](_snippets/recipes_flutter_navigation/my_event.dart.md ':include')

#### MyState

Our `MyBloc` can have one of two different `DataStates`:

- `StateA` - the state of the bloc when `PageA` is rendered.
- `StateB` - the state of the bloc when `PageB` is rendered.

[my_state.dart](_snippets/recipes_flutter_navigation/my_state.dart.md ':include')

#### MyBloc

Our `MyBloc` should look something like this:

[my_bloc.dart](_snippets/recipes_flutter_navigation/my_bloc.dart.md ':include')

### UI Layer

Now let's take a look at how to hook up our `MyBloc` to a widget and show a different page based on the bloc state.

[main.dart](_snippets/recipes_flutter_navigation/direct_navigation/main.dart.md ':include')

?> We use the `BlocBuilder` widget in order to render the correct widget in response to state changes in our `MyBloc`.

?> We use the `BlocProvider` widget in order to make our instance of `MyBloc` available to the entire widget tree.

The full source for this recipe can be found [here](https://gist.github.com/felangel/386c840aad41c7675ab8695f15c4cb09).

## Route Navigation

> In this example, we're going to take a look at how to use `BlocListener` to navigate to a specific page (widget) in response to a state change in a bloc using a route.

![demo](./assets/gifs/recipes_flutter_navigation_routes.gif)

### Bloc

We're going to reuse the same `MyBloc` from the previous example.

### UI Layer

Let's take a look at how to route to a different page based on the state of `MyBloc`.

[main.dart](_snippets/recipes_flutter_navigation/route_navigation/main.dart.md ':include')

?> We use the `BlocListener` widget in order to push a new route in response to state changes in our `MyBloc`.

!> For the sake of this example, we are adding an event just for navigation. In a real application, you should not create explicit navigation events. If there is no "business logic" necessary in order to trigger navigation, you should always directly navigate in response to user input (in the `onPressed` callback, etc...). Only navigate in response to state changes if some "business logic" is required in order to determine where to navigate.

The full source for this recipe can be found [here](https://gist.github.com/felangel/6bcd4be10c046ceb33eecfeb380135dd).

## Navigation 2.0

> In this example, we're going to take a look at how to use the Navigator 2.0 pages API to handle routing in response to state changes in a bloc.

?> Note: We're going to use [package:flow_builder](https://pub.dev/packages/flow_builder) to make working with the Navigator 2.0 API simpler.

### Bloc

For the sake of showcasing Navigator's advantages, we will build a slightly more complex example. 
Let's build `BookBloc` which will take `BookEvents` and convert them into `BookStates`.

#### BookEvent

`BookEvent` will respond to two events: selecting a book, and deselecting a book. 

[book_event.dart](_snippets/recipes_flutter_navigation/navigation2/book_event.dart.md ':include')

#### BookState

`BookState` will contain the list of books and an optional selected book if the user taps a book.

[book_state.dart](_snippets/recipes_flutter_navigation/navigation2/book_state.dart.md ':include')

#### BookBloc

`BookBloc` will handle responding to each `BookEvent` and will emit the appropriate `BookState` in response:

[book_bloc.dart](_snippets/recipes_flutter_navigation/navigation2/book_bloc.dart.md ':include')

### UI Layer

Now let's hook up the bloc to our UI using `FlowBuilder`!

[main.dart](_snippets/recipes_flutter_navigation/navigation2/main.dart.md ':include')

The full source for this recipe can be found [here](https://gist.github.com/felangel/bd3cf504a10c0763a32f7a94e2649369).
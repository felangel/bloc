# Recipes: Show SnackBar with BlocListener

> In this recipe, we're going to take a look at how to use `BlocListener` to show a `SnackBar` in response to a state change in a bloc.

![demo](./assets/gifs/recipes_flutter_snack_bar.gif)

## Bloc

Let's build a basic `DataBloc` which will handle `DataEvents` and output `DataStates`.

### DataEvent

For simplicity, our `DataBloc` will only respond to a single `DataEvent` called `FetchData`.

[data_event.dart](../_snippets/recipes_flutter_show_snack_bar/data_event.dart.md ':include')

### DataState

Our `DataBloc` can have one of three different `DataStates`:

- `Initial` - the initial state before any events are added
- `Loading` - the state of the bloc while it is asynchronously "fetching data"
- `Success` - the state of the bloc when it has successfully "fetched data"

[data_state.dart](../_snippets/recipes_flutter_show_snack_bar/data_state.dart.md ':include')

### DataBloc

Our `DataBloc` should look something like this:

[data_bloc.dart](../_snippets/recipes_flutter_show_snack_bar/data_bloc.dart.md ':include')

?> **Note:** We're using `Future.delayed` to simulate latency.

## UI Layer

Now let's take a look at how to hook up our `DataBloc` to a widget and show a `SnackBar` in response to a success state.

[main.dart](../_snippets/recipes_flutter_show_snack_bar/main.dart.md ':include')

?> We use the `BlocListener` widget in order to **DO THINGS** in response to state changes in our `DataBloc`.

?> We use the `BlocBuilder` widget in order to **RENDER WIDGETS** in response to state changes in our `DataBloc`.

!> We should **NEVER** "do things" in response to state changes in the `builder` method of `BlocBuilder` because that method can be called many times by the Flutter framework. The `builder` method should be a [pure function](https://en.wikipedia.org/wiki/Pure_function) that just returns a widget in response to the state of the bloc.

The full source for this recipe can be found [here](https://gist.github.com/felangel/1e5b2c25b263ad1aa7bbed75d8c76c44).

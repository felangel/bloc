# Flutter Counter Tutorial

![beginner](https://img.shields.io/badge/level-beginner-green.svg)

> In the following tutorial, we're going to build a Counter in Flutter using the Bloc library.

![demo](../../assets/gifs/flutter_counter.gif)

## Setup

We'll start off by creating a brand new Flutter project

[script](../_snippets/flutter_counter_tutorial/flutter_create.sh.md ':include')

We can then go ahead and replace the contents of `pubspec.yaml` with

[pubspec.yaml](../_snippets/flutter_counter_tutorial/pubspec.yaml.md ':include')

and then install all of our dependencies

[script](../_snippets/flutter_counter_tutorial/flutter_packages_get.sh.md ':include')

Our counter app is just going to have two buttons to increment/decrement the counter value and a `Text` widget to display the current value. Let's get started designing the `CounterEvents`.

## Counter Events

[counter_event.dart](../_snippets/flutter_counter_tutorial/counter_event.dart.md ':include')

## Counter States

Since our counter's state can be represented by an integer we don't need to create a custom class!

## Counter Bloc

[counter_bloc.dart](../_snippets/flutter_counter_tutorial/counter_bloc.dart.md ':include')

?> **Note**: Just from the class declaration we can tell that our `CounterBloc` will be taking `CounterEvents` as input and outputting integers.

## Counter App

Now that we have our `CounterBloc` fully implemented, we can get started creating our Flutter application.

[main.dart](../_snippets/flutter_counter_tutorial/main.dart.md ':include')

?> **Note**: We are using the `BlocProvider` widget from `flutter_bloc` in order to make the instance of `CounterBloc` available to the entire subtree (`CounterPage`). `BlocProvider` also handles closing the `CounterBloc` automatically so we don't need to use a `StatefulWidget`.

## Counter Page

Finally, all that's left is to build our Counter Page.

[counter_page.dart](../_snippets/flutter_counter_tutorial/counter_page.dart.md ':include')

?> **Note**: We are able to access the `CounterBloc` instance using `BlocProvider.of<CounterBloc>(context)` because we wrapped our `CounterPage` in a `BlocProvider`.

?> **Note**: We are using the `BlocBuilder` widget from `flutter_bloc` in order to rebuild our UI in response to state changes (changes in the counter value).

?> **Note**: `BlocBuilder` takes an optional `bloc` parameter but we can specify the type of the bloc and the type of the state and `BlocBuilder` will find the bloc automatically so we don't need to explicity use `BlocProvider.of<CounterBloc>(context)`.

!> Only specify the bloc in `BlocBuilder` if you wish to provide a bloc that will be scoped to a single widget and isn't accessible via a parent `BlocProvider` and the current `BuildContext`.

That's it! We've separated our presentation layer from our business logic layer. Our `CounterPage` has no idea what happens when a user presses a button; it just adds an event to notify the `CounterBloc`. Furthermore, our `CounterBloc` has no idea what is happening with the state (counter value); it's simply converting the `CounterEvents` into integers.

We can run our app with `flutter run` and can view it on our device or simulator/emulator.

The full source for this example can be found [here](https://github.com/felangel/Bloc/tree/master/packages/flutter_bloc/example).

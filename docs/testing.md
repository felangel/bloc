# Testing

> Bloc was designed to be extremely easy to test.

For the sake of simplicity, let's write tests for the `CounterBloc` we created in [Core Concepts](coreconcepts.md).

To recap, the `CounterBloc` implementation looks like

[counter_bloc.dart](_snippets/testing/counter_bloc.dart.md ':include')

Before we start writing our tests we're going to need to add a testing framework to our dependencies.

We need to add [test](https://pub.dev/packages/test) and [bloc_test](https://pub.dev/packages/bloc_test) to our `pubspec.yaml`.

[pubspec.yaml](_snippets/testing/pubspec.yaml.md ':include')

Let's get started by creating the file for our `CounterBloc` Tests, `counter_bloc_test.dart` and importing the test package.

[counter_bloc_test.dart](_snippets/testing/counter_bloc_test_imports.dart.md ':include')

Next, we need to create our `main` as well as our test group.

[counter_bloc_test.dart](_snippets/testing/counter_bloc_test_main.dart.md ':include')

?> **Note**: groups are for organizing individual tests as well as for creating a context in which you can share a common `setUp` and `tearDown` across all of the individual tests.

Let's start by creating an instance of our `CounterBloc` which will be used across all of our tests.

[counter_bloc_test.dart](_snippets/testing/counter_bloc_test_setup.dart.md ':include')

Now we can start writing our individual tests.

[counter_bloc_test.dart](_snippets/testing/counter_bloc_test_initial_state.dart.md ':include')

?> **Note**: We can run all of our tests with the `pub run test` command.

At this point we should have our first passing test! Now let's write a more complex test using the [bloc_test](https://pub.dev/packages/bloc_test) package.

[counter_bloc_test.dart](_snippets/testing/counter_bloc_test_bloc_test.dart.md ':include')

We should be able to run the tests and see that all are passing.

That's all there is to it, testing should be a breeze and we should feel confident when making changes and refactoring our code.

You can refer to the [Todos App](https://github.com/brianegan/flutter_architecture_samples/tree/master/bloc_library) for an example of a fully tested application.

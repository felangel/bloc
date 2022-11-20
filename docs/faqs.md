# Frequently Asked Questions

## State Not Updating

❔ **Question**: I'm emitting a state in my bloc but the UI is not updating. What am I doing wrong?

💡 **Answer**: If you're using Equatable make sure to pass all properties to the props getter.

✅ **GOOD**

[my_state.dart](_snippets/faqs/state_not_updating_good_1.dart.md ':include')

❌ **BAD**

[my_state.dart](_snippets/faqs/state_not_updating_bad_1.dart.md ':include')

[my_state.dart](_snippets/faqs/state_not_updating_bad_2.dart.md ':include')

In addition, make sure you are emitting a new instance of the state in your bloc.

✅ **GOOD**

[my_bloc.dart](_snippets/faqs/state_not_updating_good_2.dart.md ':include')

[my_bloc.dart](_snippets/faqs/state_not_updating_good_3.dart.md ':include')

❌ **BAD**

[my_bloc.dart](_snippets/faqs/state_not_updating_bad_3.dart.md ':include')

!> `Equatable` properties should always be copied rather than modified. If an `Equatable` class contains a `List` or `Map` as properties, be sure to use `List.from` or `Map.from` respectively to ensure that equality is evaluated based on the values of the properties rather than the reference.

## When to use Equatable

❔**Question**: When should I use Equatable?

💡**Answer**:

[my_bloc.dart](_snippets/faqs/equatable_yield.dart.md ':include')

In the above scenario if `StateA` extends `Equatable` only one state change will occur (the second emit will be ignored).
In general, you should use `Equatable` if you want to optimize your code to reduce the number of rebuilds.
You should not use `Equatable` if you want the same state back-to-back to trigger multiple transitions.

In addition, using `Equatable` makes it much easier to test blocs since we can expect specific instances of bloc states rather than using `Matchers` or `Predicates`.

[my_bloc_test.dart](_snippets/faqs/equatable_bloc_test.dart.md ':include')

Without `Equatable` the above test would fail and would need to be rewritten like:

[my_bloc_test.dart](_snippets/faqs/without_equatable_bloc_test.dart.md ':include')

## Handling Errors

❔ **Question**: How can I handle an error while still showing previous data?

💡 **Answer**:

This highly depends on how the state of the bloc has been modeled. In cases where data should still be retained even in the presence of an error, consider using a single state class.

```dart
enum Status { initial, loading, success, failure }

class MyState {
  const MyState({
    this.data = Data.empty,
    this.error = '',
    this.status = Status.initial,
  });

  final Data data;
  final String error;
  final Status status;

  MyState copyWith({Data data, String error, Status status}) {
    return MyState(
      data: data ?? this.data,
      error: error ?? this.error,
      status: status ?? this.status,
    );
  }
}
```

This will allow widgets to have access to the `data` and `error` properties simultaneously and the bloc can use `state.copyWith` to retain old data even when an error has occurred.

```dart
on<DataRequested>((event, emit) {
  try {
    final data = await _repository.getData();
    emit(state.copyWith(status: Status.success, data: data));
  } on Exception {
    emit(state.copyWith(status: Status.failure, error: 'Something went wrong!'));
  }
});
```

## Bloc vs. Redux

❔ **Question**: What's the difference between Bloc and Redux?

💡 **Answer**:

BLoC is a design pattern that is defined by the following rules:

1. Input and Output of the BLoC are simple Streams and Sinks.
2. Dependencies must be injectable and Platform agnostic.
3. No platform branching is allowed.
4. Implementation can be whatever you want as long as you follow the above rules.

The UI guidelines are:

1. Each "complex enough" component has a corresponding BLoC.
2. Components should send inputs "as is".
3. Components should show outputs as close as possible to "as is".
4. All branching should be based on simple BLoC boolean outputs.

The Bloc Library implements the BLoC Design Pattern and aims to abstract RxDart in order to simplify the developer experience.

The three principles of Redux are:

1. Single source of truth
2. State is read-only
3. Changes are made with pure functions

The bloc library violates the first principle; with bloc state is distributed across multiple blocs.
Furthermore, there is no concept of middleware in bloc and bloc is designed to make async state changes very easy, allowing you to emit multiple states for a single event.

## Bloc vs. Provider

❔ **Question**: What's the difference between Bloc and Provider?

💡 **Answer**: `provider` is designed for dependency injection (it wraps `InheritedWidget`).
You still need to figure out how to manage your state (via `ChangeNotifier`, `Bloc`, `Mobx`, etc...).
The Bloc Library uses `provider` internally to make it easy to provide and access blocs throughout the widget tree.

## Navigation with Bloc

❔ **Question**: How do I do navigation with Bloc?

💡 **Answer**: Check out [Flutter Navigation](recipesflutternavigation.md)

## BlocProvider.of() Fails to Find Bloc

❔ **Question**: When using `BlocProvider.of(context)` it cannot find the bloc. How can I fix this?

💡 **Answer**: You cannot access a bloc from the same context in which it was provided so you must ensure `BlocProvider.of()` is called within a child `BuildContext`.

✅ **GOOD**

[my_page.dart](_snippets/faqs/bloc_provider_good_1.dart.md ':include')

[my_page.dart](_snippets/faqs/bloc_provider_good_2.dart.md ':include')

❌ **BAD**

[my_page.dart](_snippets/faqs/bloc_provider_bad_1.dart.md ':include')

## Project Structure

❔ **Question**: How should I structure my project?

💡 **Answer**: While there is really no right/wrong answer to this question, some recommended references are

- [Flutter Architecture Samples - Brian Egan](https://github.com/brianegan/flutter_architecture_samples/tree/master/bloc_library)
- [Flutter Shopping Card Example](https://github.com/felangel/bloc/tree/master/examples/flutter_shopping_cart)
- [Flutter TDD Course - ResoCoder](https://github.com/ResoCoder/flutter-tdd-clean-architecture-course)

The most important thing is having a **consistent** and **intentional** project structure.

## Adding Events within a Bloc

❔ **Question**: Is it okay to add events within a bloc?

💡 **Answer**: In most cases, events should be added externally but in some select cases it may make sense for events to be added internally.

The most common situation in which internal events are used is when state changes must occur in response to real-time updates from a repository. In these situations, the repository is the stimulus for the state change instead of an external event such as a button tap.

In the following example, the state of `MyBloc` is dependent on the current user which is exposed via the `Stream<User>` from the `UserRepository`. `MyBloc` listens for changes in the current user and adds an internal `_UserChanged` event whenever a user is emitted from the user stream.

```dart
class MyBloc extends Bloc<MyEvent, MyState> {
  MyBloc({required UserRepository userRepository}) : super(...) {
    on<_UserChanged>(_onUserChanged);
    _userSubscription = userRepository.user.listen(
      (user) => add(_UserChanged(user)),
    );
  }
```

By adding an internal event, we are also able to specify a custom `transformer` for the event to determine how multiple `_UserChanged` events will be processed -- by default they will be processed concurrently.

It's highly recommended that internal events are private. This is an explicit way of signaling that a specific event is used only within the bloc itself and prevents external components from knowing about the event.

```dart
abstract class MyEvent {}

// `EventA` is an external event.
class EventA extends MyEvent {}

// `EventB` is an internal event.
// We are explicitly making `EventB` private so that it can only be used
// within the bloc.
class _EventB extends MyEvent {}
```

We can alternatively define an external `Started` event and use the `emit.forEach` API to handle reacting to real-time user updates:

```dart
class MyBloc extends Bloc<MyEvent, MyState> {
  MyBloc({required UserRepository userRepository})
    : _userRepository = userRepository, super(...) {
    on<Started>(_onStarted);
  }

  Future<void> _onStarted(Started event, Emitter<MyState> emit) {
    return emit.forEach(
      _userRepository.user,
      onData: (user) => MyState(...)
    );
  }
}
```

The benefits of the above approach are:

- We do not need an internal `_UserChanged` event
- We do not need to manage the `StreamSubscription` manually
- We have full control over when the bloc subscribes to the stream of user updates

The drawbacks of the above approach are:

- We cannot easily `pause` or `resume` the subscription
- We need to expose a public `Started` event which must be added externally
- We cannot use a custom `transformer` to adjust how we react to user updates

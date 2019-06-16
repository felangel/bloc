<p align="center">
  <img src="https://github.com/felangel/hydrated_bloc/raw/master/doc/assets/hydrated_bloc_logo.png" width="50%" alt="logo" />
  <br/>
  <a href="https://circleci.com/gh/felangel/hydrated_bloc">
    <img alt="Build Status" src="https://circleci.com/gh/felangel/hydrated_bloc.svg?style=shield">
  </a>
  <a href="https://codecov.io/gh/felangel/hydrated_bloc">
    <img alt="Code Coverage" src="https://codecov.io/gh/felangel/hydrated_bloc/branch/master/graph/badge.svg" />
  </a>
  <a href="https://pub.dartlang.org/packages/hydrated_bloc">
    <img alt="Pub Package" src="https://img.shields.io/pub/v/hydrated_bloc.svg">
  </a>
  <a href="https://opensource.org/licenses/MIT">
    <img alt="MIT License" src="https://img.shields.io/badge/License-MIT-blue.svg">
  </a>  
</p>

---

An extension to the [bloc state management library](https://github.com/felangel/bloc) which automatically persists and restores bloc states.

# Usage

### 1. Use `HydratedBlocDelegate`

```dart
void main() async {
  BlocSupervisor.delegate = await HydratedBlocDelegate.build();
  runApp(App());
}
```

### 2. Extend `HydratedBloc`

```dart
enum CounterEvent { increment, decrement }

class CounterState {
  int value;

  CounterState(this.value);
}

class CounterBloc extends HydratedBloc<CounterEvent, CounterState> {
  @override
  CounterState get initialState {
    return super.initialState ?? CounterState(0);
  }

  @override
  Stream<CounterState> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.decrement:
        yield CounterState(currentState.value - 1);
        break;
      case CounterEvent.increment:
        yield CounterState(currentState.value + 1);
        break;
    }
  }

  @override
  CounterState fromJson(Map<String, dynamic> source) {
    return CounterState(source['value'] as int);
  }

  @override
  Map<String, int> toJson(CounterState state) {
    return {'value': state.value};
  }
}
```

Now our `CounterBloc` is a `HydratedBloc` and will automatically persist its state. We can increment the counter value, hot restart, kill the app, etc... and our `CounterBloc` will always retain its state.

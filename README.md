<img src="https://github.com/felangel/hydrated_bloc/raw/master/docs/assets/hydrated_bloc_logo.png" width="100%" alt="logo" />
<p align="center">
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

### 1. Extend `HydratedBlocDelegate`

```dart
class MyHydratedBlocDelegate extends HydratedBlocDelegate {
  MyHydratedBlocDelegate(HydratedBlocSharedPreferences prefs) : super(prefs);

  @override
  void onEvent(Bloc bloc, Object event) {
    super.onEvent(bloc, event);
    print('${bloc.runtimeType} $event');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print('${bloc.runtimeType} $transition');
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
    print('${bloc.runtimeType} $error');
  }
}
```

### 2. Use `HydratedBlocDelegate`

```dart
void main() async {
  final prefs = await HydratedBlocSharedPreferences.getInstance();
  BlocSupervisor.delegate = MyHydratedBlocDelegate(prefs);
  runApp(App());
}
```

### 3. Extend `HydratedBloc`

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
  fromJson(String source) {
    try {
      final dynamic j = json.decode(source);
      return CounterState(j['value']);
    } catch (_) {
      return null;
    }
  }

  @override
  String toJson(CounterState state) {
    Map<String, int> j = {'value': state.value};
    return json.encode(j);
  }
}
```

Now our `CounterBloc` is a `HydratedBloc` and will automatically persist its state. We can increment the counter value, hot restart, kill the app, etc... and our `CounterBloc` will always retain its state.

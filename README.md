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
  // https://github.com/flutter/flutter/pull/38464
  // Changes in Flutter v1.9.4 require you to call WidgetsFlutterBinding.ensureInitialized()
  // before using any plugins if the code is executed before runApp.
  // As a result, you may have to uncomment the following line if you're using Flutter >=1.9.4.
  //
  // WidgetsFlutterBinding.ensureInitialized();
  BlocSupervisor.delegate = await HydratedBlocDelegate.build();
  runApp(App());
}
```

### 2. Extend `HydratedBloc` and override initialState, fromJson and toJson methods

```dart
class CounterBloc extends HydratedBloc<CounterEvent, CounterState> {
  // Use previously cached initialState if it's available
  @override
  CounterState get initialState {
    return super.initialState ?? CounterState(0);
  }

  // Called when trying to read cached state from storage.
  // Be sure to handle any exceptions that can occur and return null
  // to indicate that there is no cached data.
  @override
  CounterState fromJson(Map<String, dynamic> source) {
    try {
      return CounterState(source['value'] as int);
    } catch (_) {
      return null;
    }
  }

  // Called on each state change (transition)
  // If it returns null, then no cache updates will occur.
  // Otherwise, the returned value will be cached.
  @override
  Map<String, int> toJson(CounterState state) {
    try {
      return { 'value': state.value };
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<CounterState> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.decrement:
        yield CounterState(state.value - 1);
        break;
      case CounterEvent.increment:
        yield CounterState(state.value + 1);
        break;
    }
  }
}

enum CounterEvent { increment, decrement }

class CounterState {
  int value;

  CounterState(this.value);
}

```

Now our `CounterBloc` is a `HydratedBloc` and will automatically persist its state. We can increment the counter value, hot restart, kill the app, etc... and our `CounterBloc` will always retain its state.

# How it works

## Overview

`hydrated_bloc` exports a `HydratedStorage` interface which means it can work with any storage provider. Out of the box, it comes with its own implementation: `HydratedBlocStorage`.

`HydratedBlocStorage` is built on top of [path_provider](https://pub.dev/packages/path_provider) for a platform-agnostic storage layer. The out-of-the-box storage implementation reads/writes to file using the `toJson`/`fromJson` methods on `HydratedBloc` and should perform very well for most use-cases (performance reports coming soon). `HydratedBlocStorage` is supported for desktop ([example](https://github.com/felangel/hydrated_bloc/tree/master/example)).

## Considerations

On mobile, all data is written to [temporary storage](https://github.com/flutter/plugins/blob/61c39d1e79e8f36030162a5f85fb491c65f4e51c/packages/path_provider/lib/path_provider.dart#L24) which means it can be wiped by the operating system at any point in time. As a result, `hydrated_bloc` is not intended to be used as a persistent database and should be viewed as a cache instead.

In addition, while the `HydratedBlocStorage` client doesn't automatically encrypt/decrypt the data, it is fairly straightforward to implement a custom `HydratedStorage` client which does support encryption.

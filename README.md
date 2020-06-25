<p align="center">
  <img src="https://github.com/felangel/hydrated_bloc/raw/master/doc/assets/hydrated_bloc_logo.png" height="240" alt="Hydrated Bloc">
</p>

<p align="center">
  <a href="https://pub.dev/packages/hydrated_bloc">
    <img src="https://img.shields.io/pub/v/hydrated_bloc.svg" alt="Pub Version">
  </a>
  <a href="https://circleci.com/gh/felangel/hydrated_bloc">
    <img src="https://circleci.com/gh/felangel/hydrated_bloc.svg?style=shield" alt="Build Status">
  </a>
  <a href="https://codecov.io/gh/felangel/hydrated_bloc">
    <img src="https://codecov.io/gh/felangel/hydrated_bloc/branch/master/graph/badge.svg" alt="Code Coverage">
  </a>
  <a href="https://pub.dev/packages/effective_dart">
    <img src="https://img.shields.io/badge/style-effective_dart-40c4ff.svg" alt="style: effective dart">
  </a>
  <a href="https://opensource.org/licenses/MIT">
    <img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="MIT License">
  </a>
  <a href="https://github.com/zepfietje/starware">
    <img src="https://img.shields.io/badge/Starware-⭐-black?labelColor=f9b00d" alt="Starware">
  </a>
</p>

An extension to the [bloc state management library](https://github.com/felangel/bloc) which automatically persists and restores bloc states.

## Overview

`hydrated_bloc` exports a `HydratedStorage` interface which means it can work with any storage provider. Out of the box, it comes with its own implementation: `HydratedBlocStorage`.

`HydratedBlocStorage` is built on top of [path_provider](https://pub.dev/packages/path_provider) for a platform-agnostic storage layer. The out-of-the-box storage implementation reads/writes to file using the `toJson`/`fromJson` methods on `HydratedBloc` and should perform very well for most use-cases (performance reports coming soon). `HydratedBlocStorage` is supported for desktop ([example](https://github.com/felangel/hydrated_bloc/tree/master/example)).

In addition, while the `HydratedBlocStorage` client doesn't automatically encrypt/decrypt the data, it is fairly straightforward to implement a custom `HydratedStorage` client which does support encryption.

## Usage

### 1. Use `HydratedBlocDelegate`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

## Custom Storage Directory

By default, all data is written to [temporary storage](https://github.com/flutter/plugins/blob/61c39d1e79e8f36030162a5f85fb491c65f4e51c/packages/path_provider/lib/path_provider.dart#L24) which means it can be wiped by the operating system at any point in time.

An optional `storageDirectory` can be provided to override the default temporary storage directory:

```dart
BlocSupervisor.delegate = await HydratedBlocDelegate.build(
  storageDirectory: await getApplicationDocumentsDirectory(),
);
```

## Custom Hydrated Storage

If the default `HydratedBlocStorage` doesn't meet your needs, you can always implement a custom `HydratedStorage` by simply implementing the `HydratedStorage` interface and initializing `HydratedBlocDelegate` with the custom `HydratedStorage`.

```dart
// my_hydrated_storage.dart

class MyHydratedStorage implements HydratedStorage {
  @override
  dynamic read(String key) {
    // TODO: implement read
  }

  @override
  Future<void> write(String key, dynamic value) async {
    // TODO: implement write
  }

  @override
  Future<void> delete(String key) async {
    // TODO: implement delete
  }

  @override
  Future<void> clear() async {
    // TODO: implement clear
  }
}
```

```dart
// my_hydrated_bloc_delegate.dart

class MyHydratedBlocDelegate extends HydratedBlocDelegate {
 MyHydratedBlocDelegate() : super(MyHydratedBlocStorage());
}
```

```dart
// main.dart

BlocSupervisor.delegate = MyHydratedBlocDelegate();
```

## Starware

Hydrated Bloc is Starware.  
This means you're free to use the project, as long as you star its GitHub repository.  
Your appreciation makes us grow and glow up. ⭐

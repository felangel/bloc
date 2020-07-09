<p align="center">
  <img src="https://github.com/felangel/bloc/raw/master/docs/assets/hydrated_bloc_logo.png" height="100" alt="Hydrated Bloc">
</p>

<p align="center">
  <a href="https://github.com/felangel/bloc/actions"><img src="https://github.com/felangel/bloc/workflows/build/badge.svg" alt="build"></a>
  <a href="https://codecov.io/gh/felangel/bloc"><img src="https://codecov.io/gh/felangel/Bloc/branch/master/graph/badge.svg" alt="codecov"></a>
  <a href="https://github.com/felangel/bloc"><img src="https://img.shields.io/github/stars/felangel/bloc.svg?style=flat&logo=github&colorB=deeppink&label=stars" alt="Star on Github"></a>
  <a href="https://github.com/tenhobi/effective_dart"><img src="https://img.shields.io/badge/style-effective_dart-40c4ff.svg" alt="style: effective dart"></a>
  <a href="https://flutter.dev/docs/development/data-and-backend/state-mgmt/options#bloc--rx"><img src="https://img.shields.io/badge/flutter-website-deepskyblue.svg" alt="Flutter Website"></a>
  <a href="https://github.com/Solido/awesome-flutter#standard"><img src="https://img.shields.io/badge/awesome-flutter-blue.svg?longCache=true" alt="Awesome Flutter"></a>
  <a href="http://fluttersamples.com"><img src="https://img.shields.io/badge/flutter-samples-teal.svg?longCache=true" alt="Flutter Samples"></a>
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
  <a href="https://discord.gg/Hc5KD3g"><img src="https://img.shields.io/discord/649708778631200778.svg?logo=discord&color=blue" alt="Discord"></a>
  <a href="https://github.com/felangel/bloc"><img src="https://tinyurl.com/bloc-library" alt="Bloc Library"></a>
</p>

An extension to the [bloc state management library](https://github.com/felangel/bloc) which automatically persists and restores bloc states and is built on top of [hydrated_cubit](https://pub.dev/packages/hydrated_cubit).

## Overview

`hydrated_bloc` exports a `Storage` interface which means it can work with any storage provider. Out of the box, it comes with its own implementation: `HydratedStorage`.

`HydratedStorage` is built on top of [path_provider](https://pub.dev/packages/path_provider) for a platform-agnostic storage layer. The out-of-the-box storage implementation reads/writes to file using the `toJson`/`fromJson` methods on `HydratedBloc` and should perform very well for most use-cases (performance reports coming soon). `HydratedStorage` is supported for desktop ([example](https://github.com/felangel/hydrated_bloc/tree/master/example)).

## Usage

### 1. Use `HydratedStorage`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build();
  runApp(App());
}
```

### 2. Extend `HydratedBloc` and override `fromJson`/`toJson`

```dart
enum CounterEvent { increment, decrement }

class CounterBloc extends HydratedBloc<CounterEvent, int> {
  CounterBloc() : super(0);

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.decrement:
        yield state - 1;
        break;
      case CounterEvent.increment:
        yield state + 1;
        break;
    }
  }

  @override
  int fromJson(Map<String, dynamic> json) => json['value'] as int;

  @override
  Map<String, int> toJson(int state) => { 'value': state };
}
```

Now our `CounterBloc` is a `HydratedBloc` and will automatically persist its state. We can increment the counter value, hot restart, kill the app, etc... and our `CounterBloc` will always retain its state.

## Custom Storage Directory

By default, all data is written to [temporary storage](https://github.com/flutter/plugins/blob/61c39d1e79e8f36030162a5f85fb491c65f4e51c/packages/path_provider/lib/path_provider.dart#L24) which means it can be wiped by the operating system at any point in time.

An optional `storageDirectory` can be provided to override the default temporary storage directory:

```dart
HydratedBloc.storage = await HydratedStorage.build(
  storageDirectory: await getApplicationDocumentsDirectory(),
);
```

## Custom Hydrated Storage

If the default `HydratedStorage` doesn't meet your needs, you can always implement a custom `Storage` by simply implementing the `Storage` interface and initializing `HydratedBloc` with the custom `Storage`.

```dart
// my_hydrated_storage.dart

class MyHydratedStorage implements Storage {
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
// main.dart

HydratedBloc.storage = MyHydratedStorage();
```

## Maintainers

- [Felix Angelov](https://github.com/felangel)

## Supporters

[<img src="https://raw.githubusercontent.com/felangel/bloc/master/docs/assets/vgv_logo.png" width="120" />](https://verygood.ventures)

## Starware

Hydrated Bloc is Starware.  
This means you're free to use the project, as long as you star its GitHub repository.  
Your appreciation makes us grow and glow up. ⭐

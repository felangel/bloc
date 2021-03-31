<p align="center"><img src="https://raw.githubusercontent.com/felangel/bloc/master/docs/assets/replay_bloc_logo_full.png" height="100" alt="ReplayBloc"></p>

<p align="center">
  <a href="https://pub.dev/packages/replay_bloc"><img src="https://img.shields.io/pub/v/replay_bloc.svg" alt="Pub"></a>
  <a href="https://github.com/felangel/bloc/actions"><img src="https://github.com/felangel/bloc/workflows/build/badge.svg" alt="build"></a>
  <a href="https://codecov.io/gh/felangel/bloc"><img src="https://codecov.io/gh/felangel/Bloc/branch/master/graph/badge.svg" alt="codecov"></a>
  <a href="https://github.com/felangel/bloc"><img src="https://img.shields.io/github/stars/felangel/bloc.svg?style=flat&logo=github&colorB=deeppink&label=stars" alt="Star on Github"></a>
  <a href="https://github.com/tenhobi/effective_dart"><img src="https://img.shields.io/badge/style-effective_dart-40c4ff.svg" alt="style: effective dart"></a>
  <a href="https://flutter.dev/docs/development/data-and-backend/state-mgmt/options#bloc--rx"><img src="https://img.shields.io/badge/flutter-website-deepskyblue.svg" alt="Flutter Website"></a>
  <a href="https://github.com/Solido/awesome-flutter#standard"><img src="https://img.shields.io/badge/awesome-flutter-blue.svg?longCache=true" alt="Awesome Flutter"></a>
  <a href="https://fluttersamples.com"><img src="https://img.shields.io/badge/flutter-samples-teal.svg?longCache=true" alt="Flutter Samples"></a>
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
  <a href="https://discord.gg/bloc"><img src="https://img.shields.io/discord/649708778631200778.svg?logo=discord&color=blue" alt="Discord"></a>
  <a href="https://github.com/felangel/bloc"><img src="https://tinyurl.com/bloc-library" alt="Bloc Library"></a>
</p>

An extension to [package:bloc](https://github.com/felangel/bloc) which adds automatic undo and redo support to bloc and cubit states. Built to work with [package:bloc](https://pub.dev/packages/bloc).

**Learn more at [bloclibrary.dev](https://bloclibrary.dev)!**

---

## Sponsors

Our top sponsors are shown below! [[Become a Sponsor](https://github.com/sponsors/felangel)]

<table>    
    <tbody>
        <tr>
            <td align="center">
                <a href="https://verygood.ventures"><img src="https://raw.githubusercontent.com/felangel/bloc/master/docs/assets/vgv_logo.png" width="120"/></a>
            </td>
            <td align="center">
                <a href="https://getstream.io/chat/?utm_source=github&utm_medium=bloc-flutter&utm_campaign=oss_sponsorship" target="_blank"><img width="250px" src="https://stream-blog.s3.amazonaws.com/blog/wp-content/uploads/fc148f0fc75d02841d017bb36e14e388/Stream-logo-with-background-.png"/></a><br/><span><a href="https://getstream.io/chat/flutter/tutorial/?utm_source=github&utm_medium=bloc-flutter&utm_campaign=oss_sponsorship" target="_blank">Try the Flutter Chat Tutorial &nbsp💬</a></span>
            </td>            
        </tr>
    </tbody>
</table>

---

## Creating a ReplayCubit

```dart
class CounterCubit extends ReplayCubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
}
```

## Using a ReplayCubit

```dart
void main() {
  final cubit = CounterCubit();

  // trigger a state change
  cubit.increment();
  print(cubit.state); // 1

  // undo the change
  cubit.undo();
  print(cubit.state); // 0

  // redo the change
  cubit.redo();
  print(cubit.state); // 1
}
```

## ReplayCubitMixin

If you wish to be able to use a `ReplayCubit` in conjuction with a different type of cubit like `HydratedCubit`, you can use the `ReplayCubitMixin`.

```dart
class CounterCubit extends HydratedCubit<int> with ReplayCubitMixin {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);

  @override
  int fromJson(Map<String, dynamic> json) => json['value'] as int;

  @override
  Map<String, int> toJson(int state) => {'value': state};
}
```

## Creating a ReplayBloc

```dart
class CounterEvent extends ReplayEvent {}

class Increment extends CounterEvent {}

class Decrement extends CounterEvent {}

class CounterBloc extends ReplayBloc<CounterEvent, int> {
  CounterBloc() : super(0);

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    if (event is Increment) {
      yield state + 1;
    } else if (event is Decrement) {
      yield state - 1;
    }
  }
}
```

## Using a ReplayBloc

```dart
void main() {
  // trigger a state change
  final bloc = CounterBloc()..add(Increment());

  // wait for state to update
  await bloc.first;
  print(bloc.state); // 1

  // undo the change
  bloc.undo();
  print(bloc.state); // 0

  // redo the change
  bloc.redo();
  print(bloc.state); // 1
}
```

## ReplayBlocMixin

If you wish to be able to use a `ReplayBloc` in conjuction with a different type of cubit like `HydratedBloc`, you can use the `ReplayBlocMixin`.

```dart
abstract class CounterEvent with ReplayEvent {}

class Increment extends CounterEvent {}

class Decrement extends CounterEvent {}

class CounterBloc extends HydratedBloc<CounterEvent, int> with ReplayBlocMixin {
  CounterBloc() : super(0);

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    if (event is Increment) {
      yield state + 1;
    } else if (event is Decrement) {
      yield state - 1;
    }
  }

  @override
  int fromJson(Map<String, dynamic> json) => json['value'] as int;

  @override
  Map<String, int> toJson(int state) => {'value': state};
}
```

## Dart Versions

- Dart 2: >= 2.12

## Maintainers

- [Felix Angelov](https://github.com/felangel)

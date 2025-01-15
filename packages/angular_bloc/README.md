<p align="center">
<img src="https://raw.githubusercontent.com/felangel/bloc/master/assets/logos/angular_bloc.png" height="100" alt="Angular Bloc Package" />
</p>

<p align="center">
<a href="https://pub.dev/packages/angular_bloc"><img src="https://img.shields.io/pub/v/angular_bloc.svg" alt="Pub"></a>
<a href="https://github.com/felangel/bloc/actions"><img src="https://github.com/felangel/bloc/workflows/build/badge.svg" alt="build"></a>
<a href="https://codecov.io/gh/felangel/bloc"><img src="https://codecov.io/gh/felangel/Bloc/branch/master/graph/badge.svg" alt="codecov"></a>
<a href="https://github.com/felangel/bloc"><img src="https://img.shields.io/github/stars/felangel/bloc.svg?style=flat&logo=github&colorB=deeppink&label=stars" alt="Star on Github"></a>
<a href="https://flutter.dev/docs/development/data-and-backend/state-mgmt/options#bloc--rx"><img src="https://img.shields.io/badge/flutter-website-deepskyblue.svg" alt="Flutter Website"></a>
<a href="https://github.com/Solido/awesome-flutter#standard"><img src="https://img.shields.io/badge/awesome-flutter-blue.svg?longCache=true" alt="Awesome Flutter"></a>
<a href="https://fluttersamples.com"><img src="https://img.shields.io/badge/flutter-samples-teal.svg?longCache=true" alt="Flutter Samples"></a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
<a href="https://discord.gg/bloc"><img src="https://img.shields.io/discord/649708778631200778.svg?logo=discord&color=blue" alt="Discord"></a>
<a href="https://github.com/felangel/bloc"><img src="https://tinyurl.com/bloc-library" alt="Bloc Library"></a>
</p>

---

A Dart package that helps implement the BLoC pattern in [AngularDart](https://pub.dev/packages/ngdart). Built to work with [package:bloc](https://pub.dev/packages/bloc).

**Learn more at [bloclibrary.dev](https://bloclibrary.dev)!**

---

## Sponsors

Our top sponsors are shown below! [[Become a Sponsor](https://github.com/sponsors/felangel)]

<table style="background-color: white; border: 1px solid black">
    <tbody>
        <tr>
            <td align="center" style="border: 1px solid black">
                <a href="https://shorebird.dev"><img src="https://raw.githubusercontent.com/felangel/bloc/master/assets/sponsors/shorebird.png" width="225"/></a>
            </td>
            <td align="center" style="border: 1px solid black">
                <a href="https://www.monterail.com/services/flutter-development/?utm_source=bloc&utm_medium=logo&utm_campaign=flutter"><img src="https://raw.githubusercontent.com/felangel/bloc/master/assets/sponsors/monterail.png" width="225"/></a>
            </td>
            <td align="center" style="border: 1px solid black">
                <a href="https://getstream.io/chat/flutter/tutorial/?utm_source=Github&utm_medium=Github_Repo_Content_Ad&utm_content=Developer&utm_campaign=Github_Jan2022_FlutterChat&utm_term=bloc"><img src="https://raw.githubusercontent.com/felangel/bloc/master/assets/sponsors/stream.png" width="225"/></a>
            </td>
        </tr>
        <tr>
            <td align="center" style="border: 1px solid black">
                <a href="https://www.miquido.com/flutter-development-company/?utm_source=github&utm_medium=sponsorship&utm_campaign=bloc-silver-tier&utm_term=flutter-development-company&utm_content=miquido-logo"><img src="https://raw.githubusercontent.com/felangel/bloc/master/assets/sponsors/miquido.png" width="225"/></a>
            </td>            
            <td align="center" style="border: 1px solid black">
                <a href="https://www.netguru.com/services/flutter-app-development?utm_campaign=%5BS%5D%5BMob%5D%20Flutter&utm_source=github&utm_medium=sponsorship&utm_term=bloclibrary"><img src="https://raw.githubusercontent.com/felangel/bloc/master/assets/sponsors/netguru.png" width="225"/></a>
            </td>
        </tr>
    </tbody>
</table>

---

## Angular Components

**BlocPipe** is an Angular pipe which helps bind `Bloc` state changes to the presentation layer. `BlocPipe` handles rendering the html element in response to new states. `BlocPipe` is very similar to `AsyncPipe` but is designed specifically for blocs.

## Cubit Usage

Lets take a look at how to use `BlocPipe` to hook up a `CounterPage` html template to a `CounterCubit`.

### `counter_cubit.dart`

```dart
import 'package:bloc/bloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
  void decrement() => emit(state — 1);
}
```

### `counter_page_component.dart`

```dart
import 'package:angular/angular.dart';
import 'package:angular_bloc/angular_bloc.dart';

import './counter_cubit.dart';

@Component(
  selector: 'counter-page',
  templateUrl: 'counter_page_component.html',
  pipes: [BlocPipe],
)
class CounterPageComponent implements OnInit, OnDestroy {
  late final CounterCubit counterCubit;

  @override
  void ngOnInit() {
    counterCubit = CounterCubit();
  }

  @override
  void ngOnDestroy() {
    counterCubit.close();
  }
}
```

### `counter_page_component.html`

```html
<div>
  <h1>Counter App</h1>
  <h2>Current Count: {{ $pipe.bloc(counterCubit) }}</h2>
  <button (click)="counterCubit.increment()">➕</button>
  <button (click)="counterCubit.decrement()">➖</button>
</div>
```

## Bloc Usage

Lets take a look at how to use `BlocPipe` to hook up a `CounterPage` html template to a `CounterBloc`.

### `counter_bloc.dart`

```dart
import 'package:bloc/bloc.dart';

sealed class CounterEvent {}
final class CounterIncrementPressed extends CounterEvent {}
final class CounterDecrementPressed extends CounterEvent {}

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0) {
    on<CounterIncrementPressed>((event, emit) => emit(state + 1));
    on<CounterDecrementPressed>((event, emit) => emit(state - 1));
  }
}
```

### `counter_page_component.dart`

```dart
import 'package:angular/angular.dart';
import 'package:angular_bloc/angular_bloc.dart';

import './counter_bloc.dart';

@Component(
  selector: 'counter-page',
  templateUrl: 'counter_page_component.html',
  pipes: [BlocPipe],
)
class CounterPageComponent implements OnInit, OnDestroy {
  late final CounterBloc counterBloc;

  @override
  void ngOnInit() {
    counterBloc = CounterBloc();
  }

  @override
  void ngOnDestroy() {
    counterBloc.close();
  }

  void increment() => counterBloc.add(CounterIncrementPressed());

  void decrement() => counterBloc.add(CounterDecrementPressed());
}
```

### `counter_page_component.html`

```html
<div>
  <h1>Counter App</h1>
  <h2>Current Count: {{ $pipe.bloc(counterBloc) }}</h2>
  <button (click)="increment()">+</button>
  <button (click)="decrement()">-</button>
</div>
```

At this point we have successfully separated our presentational layer from our business logic layer!

## Dart Versions

- Dart 2: >= 2.12.0

## Examples

- [Counter](https://github.com/felangel/bloc/tree/master/examples/angular_counter) - a complete example of how to create a `CounterBloc` and hook it up to an AngularDart app.
- [Github Search](https://github.com/felangel/bloc/tree/master/examples/github_search/angular_github_search) - an example of how to create a Github Search Application using the `bloc` and `angular_bloc` packages.

## Maintainers

- [Felix Angelov](https://github.com/felangel)

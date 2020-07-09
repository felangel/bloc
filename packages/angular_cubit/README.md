<p align="center"><img src="https://raw.githubusercontent.com/felangel/cubit/master/assets/angular_cubit_full.png" height="100" alt="Angular Cubit"></p>

<p align="center">
<a href="https://pub.dev/packages/angular_cubit"><img src="https://img.shields.io/pub/v/angular_cubit.svg" alt="Pub"></a>
<a href="https://github.com/felangel/cubit/actions"><img src="https://github.com/felangel/cubit/workflows/build/badge.svg" alt="build"></a>
<a href="https://github.com/felangel/cubit/actions"><img src="https://raw.githubusercontent.com/felangel/cubit/master/packages/angular_cubit/coverage_badge.svg" alt="coverage"></a>
<a href="https://github.com/felangel/cubit"><img src="https://img.shields.io/github/stars/felangel/cubit.svg?style=flat&logo=github&colorB=deeppink&label=stars" alt="Star on GitHub"></a>
<a href="https://discord.gg/Hc5KD3g"><img src="https://img.shields.io/discord/649708778631200778.svg?logo=discord&color=blue" alt="Discord"></a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
<a href="https://github.com/zepfietje/starware"><img src="https://img.shields.io/badge/Starware-%E2%AD%90-black?labelColor=%23f9b00d" alt="Starware"></a>
</p>

An [AngularDart](https://angulardart.dev) library built to expose components that integrate with cubits. Built to work with the [cubit](https://pub.dev/packages/cubit) and [bloc](https://pub.dev/packages/bloc) state management packages.

## Usage

Lets take a look at how to use `CubitPipe` to hook up a `CounterPage` html template to a `CounterCubit`.

### `counter_cubit.dart`

```dart
class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);
}
```

### `counter_page_component.html`

```html
<div class="counter-page-container">
  <h1>Counter App</h1>
  <h2>Current Count: {{ counterCubit | cubit }}</h2>
  <button class="counter-button" (click)="counterCubit.increment()">+</button>
  <button class="counter-button" (click)="counterCubit.decrement()">-</button>
</div>
```

### `counter_page_component.dart`

```dart
import 'package:angular/angular.dart';

import 'package:angular_cubit/angular_cubit.dart';

import './counter_cubit.dart';

@Component(
  selector: 'counter-page',
  templateUrl: 'counter_page_component.html',
  styleUrls: ['counter_page_component.css'],
  providers: [ClassProvider(CounterCubit)],
  pipes: [CubitPipe],
)
class CounterPageComponent implements OnDestroy {
  final CounterCubit counterCubit;

  CounterPageComponent(this.counterCubit) {}

  @override
  void ngOnDestroy() {
    counterCubit.close();
  }
}
```

At this point we have successfully separated our presentational layer from our business logic layer. Notice that the `CounterPage` component knows nothing about what happens when a user taps the button. The component simply invokes `increment` and `decrement` on the `CounterCubit` in response to button taps.

## Angular Components

**CubitPipe** is an Angular pipe which helps bind `Cubit` state changes to the presentation layer. `CubitPipe` handles rendering the html element in response to new states. `CubitPipe` is very similar to `AsyncPipe` but has a more simple API to reduce the amount of boilerplate code needed.

## Dart Versions

- Dart 2: >= 2.7.0

## Maintainers

- [Felix Angelov](https://github.com/felangel)

## Supporters

[![Very Good Ventures](https://raw.githubusercontent.com/felangel/cubit/master/assets/vgv_logo.png)](https://verygood.ventures)

## Starware

Angular Cubit is Starware.  
This means you're free to use the project, as long as you star its GitHub repository.  
Your appreciation makes us grow and glow up. ⭐

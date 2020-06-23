<img src="https://raw.githubusercontent.com/felangel/cubit/master/assets/angular_cubit_full.png" height="150" alt="Angular Cubit" />

[![Pub](https://img.shields.io/pub/v/angular_cubit.svg)](https://pub.dev/packages/angular_cubit)
[![build](https://github.com/felangel/cubit/workflows/build/badge.svg)](https://github.com/felangel/cubit/actions)
[![coverage](https://github.com/felangel/cubit/blob/master/packages/angular_cubit/coverage_badge.svg)](https://github.com/felangel/cubit/actions)

**WARNING: This is highly experimental**

An AngularDart library built to expose components that integrate with cubits. Built to work with the [cubit](https://pub.dev/packages/cubit) and [bloc](https://pub.dev/packages/bloc) state management packages.

## Angular Components

**CubitPipe** is an Angular pipe which helps bind `Cubit` state changes to the presentation layer. `CubitPipe` handles rendering the html element in response to new states. `CubitPipe` is very similar to `AsyncPipe` but has a more simple API to reduce the amount of boilerplate code needed.

## Usage

Lets take a look at how to use `CubitPipe` to hook up a `CounterPage` html template to a `CounterCubit`.

`counter_cubit.dart`

```dart
class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);
}
```

`counter_page_component.html`

```html
<div class="counter-page-container">
  <h1>Counter App</h1>
  <h2>Current Count: {{ counterCubit | cubit }}</h2>
  <button class="counter-button" (click)="counterCubit.increment()">+</button>
  <button class="counter-button" (click)="counterCubit.decrement()">-</button>
</div>
```

`counter_page_component.dart`

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

## Dart Versions

- Dart 2: >= 2.7.0

### Maintainers

- [Felix Angelov](https://github.com/felangel)

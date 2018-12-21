<img src="https://raw.githubusercontent.com/felangel/bloc/master/docs/assets/angular_bloc_logo_full.png" height="60" alt="Angular Bloc Package" />

[![Build Status](https://travis-ci.org/felangel/bloc.svg?branch=master)](https://travis-ci.org/felangel/bloc)
[![codecov](https://codecov.io/gh/felangel/Bloc/branch/master/graph/badge.svg)](https://codecov.io/gh/felangel/bloc)
[![Pub](https://img.shields.io/pub/v/angular_bloc.svg)](https://pub.dartlang.org/packages/angular_bloc)
[![Awesome Flutter](https://img.shields.io/badge/Awesome-Flutter-turquoise.svg?longCache=true)](https://github.com/Solido/awesome-flutter)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Gitter](https://img.shields.io/badge/gitter-bloc-yellow.svg)](https://gitter.im/bloc_package/Lobby)

---

An Angular package that helps implement the [Bloc pattern](https://www.youtube.com/watch?v=fahC3ky_zW0).

This package is built to work with [bloc](https://pub.dartlang.org/packages/bloc).

## Angular Components

**BlocPipe** is an Angular pipe which helps bind `Bloc` state changes to the presentation layer. `BlocPipe` handles rendering the html element in response to new states. `BlocPipe` is very similar to `AsyncPipe` but has a more simple API to reduce the amount of boilerplate code needed.

## Usage

Lets take a look at how to use `BlocPipe` to hook up a `CounterPage` html template to a `CounterBloc`.

counter_page_component.html
```html
<div class="counter-page-container">
    <h1>Counter App</h1>
    <h2>Current Count: {{ counterBloc | bloc }}</h2>
    <material-fab class="counter-fab-button" (trigger)="increment()">+</material-fab>
    <material-fab class="counter-fab-button" (trigger)="decrement()">-</material-fab>
</div>
```

counter_page_component.dart
```dart
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';

import 'package:angular_bloc/angular_bloc.dart';

import './counter_bloc.dart';

@Component(
  selector: 'counter-page',
  templateUrl: 'counter_page_component.html',
  styleUrls: ['counter_page_component.css'],
  directives: [MaterialFabComponent],
  pipes: [BlocPipe],
)
class CounterPageComponent implements OnInit, OnDestroy {
  CounterBloc counterBloc;

  @override
  void ngOnInit() {
    counterBloc = CounterBloc();
  }

  @override
  void ngOnDestroy() {
    counterBloc.dispose();
  }

  void increment() {
    counterBloc.dispatch(Increment());
  }

  void decrement() {
    counterBloc.dispatch(Decrement());
  }
}
```

At this point we have sucessfully separated our presentational layer from our business logic layer. Notice that the `CounterPage` component knows nothing about what happens when a user taps the button. The component simply tells the `CounterBloc` that the user has pressed the increment/decrement button.

## Dart Versions

- Dart 2: >= 2.0.0

## Examples

- [Simple Counter Example](https://github.com/felangel/Bloc/tree/master/examples/angular_counter) - a complete example of how to create a `CounterBloc` and hook it up to an AngularDart app.
- [Github Search](https://github.com/felangel/Bloc/tree/master/examples/angular_github_search) - an example of how to create a Github Search Application using the `bloc` and `angular_bloc` packages.

### Contributors

- [Felix Angelov](https://github.com/felangel)

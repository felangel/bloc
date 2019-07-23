<img src="https://raw.githubusercontent.com/felangel/bloc/master/docs/assets/angular_bloc_logo_full.png" height="60" alt="Angular Bloc Package" />

[![Pub](https://img.shields.io/pub/v/angular_bloc.svg)](https://pub.dev/packages/angular_bloc)
[![Build Status](https://travis-ci.org/felangel/bloc.svg?branch=master)](https://travis-ci.org/felangel/bloc)
[![codecov](https://codecov.io/gh/felangel/Bloc/branch/master/graph/badge.svg)](https://codecov.io/gh/felangel/bloc)
[![Flutter.io](https://img.shields.io/badge/Flutter-Website-deepskyblue.svg)](https://flutter.io/docs/development/data-and-backend/state-mgmt/options#bloc--rx)
[![Awesome Flutter](https://img.shields.io/badge/Awesome-Flutter-blue.svg?longCache=true)](https://github.com/Solido/awesome-flutter#standard)
[![Flutter Samples](https://img.shields.io/badge/Flutter-Samples-teal.svg?longCache=true)](http://fluttersamples.com)
[![Star on GitHub](https://img.shields.io/github/stars/felangel/bloc.svg?style=flat&logo=github&colorB=deeppink&label=Stars)](https://github.com/felangel/bloc)
[![Gitter](https://img.shields.io/badge/gitter-chat-hotpink.svg)](https://gitter.im/bloc_package/Lobby)
[![License: MIT](https://img.shields.io/badge/License-MIT-purple.svg)](https://opensource.org/licenses/MIT)

---

An Angular package that helps implement the [BLoC pattern](https://www.didierboelens.com/2018/08/reactive-programming---streams---bloc).

This package is built to work with [bloc](https://pub.dev/packages/bloc).

## Angular Components

**BlocPipe** is an Angular pipe which helps bind `Bloc` state changes to the presentation layer. `BlocPipe` handles rendering the html element in response to new states. `BlocPipe` is very similar to `AsyncPipe` but has a more simple API to reduce the amount of boilerplate code needed.

## Usage

Lets take a look at how to use `BlocPipe` to hook up a `CounterPage` html template to a `CounterBloc`.

`counter_bloc.dart`

```dart
enum CounterEvent { increment, decrement }

class CounterBloc extends Bloc<CounterEvent, int> {
  @override
  int get initialState => 0;

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.decrement:
        yield currentState - 1;
        break;
      case CounterEvent.increment:
        yield currentState + 1;
        break;
    }
  }
}
```

`counter_page_component.html`

```html
<div class="counter-page-container">
  <h1>Counter App</h1>
  <h2>Current Count: {{ counterBloc | bloc }}</h2>
  <material-fab class="counter-fab-button" (trigger)="increment()"
    >+</material-fab
  >
  <material-fab class="counter-fab-button" (trigger)="decrement()"
    >-</material-fab
  >
</div>
```

`counter_page_component.dart`

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
    counterBloc.dispatch(CounterEvent.increment);
  }

  void decrement() {
    counterBloc.dispatch(CounterEvent.decrement);
  }
}
```

At this point we have successfully separated our presentational layer from our business logic layer. Notice that the `CounterPage` component knows nothing about what happens when a user taps the button. The component simply tells the `CounterBloc` that the user has pressed the increment/decrement button.

## Dart Versions

- Dart 2: >= 2.0.0

## Examples

- [Counter](https://github.com/felangel/Bloc/tree/master/examples/angular_counter) - a complete example of how to create a `CounterBloc` and hook it up to an AngularDart app.
- [Github Search](https://github.com/felangel/Bloc/tree/master/examples/github_search/angular_github_search) - an example of how to create a Github Search Application using the `bloc` and `angular_bloc` packages.

### Maintainers

- [Felix Angelov](https://github.com/felangel)

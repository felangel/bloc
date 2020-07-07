<p align="center">
<img src="https://raw.githubusercontent.com/felangel/bloc/master/docs/assets/angular_bloc_logo_full.png" height="100" alt="Angular Bloc Package" />
</p>

<p align="center">
<a href="https://pub.dev/packages/angular_bloc"><img src="https://img.shields.io/pub/v/angular_bloc.svg" alt="Pub"></a>
<a href="https://github.com/felangel/bloc/actions"><img src="https://github.com/felangel/bloc/workflows/build/badge.svg" alt="build"></a>
<a href="https://codecov.io/gh/felangel/bloc"><img src="https://codecov.io/gh/felangel/Bloc/branch/master/graph/badge.svg" alt="codecov"></a>
<a href="https://github.com/felangel/bloc"><img src="https://img.shields.io/github/stars/felangel/bloc.svg?style=flat&logo=github&colorB=deeppink&label=stars" alt="Star on Github"></a>
<a href="https://github.com/tenhobi/effective_dart"><img src="https://img.shields.io/badge/style-effective_dart-40c4ff.svg" alt="style: effective dart"></a>
<a href="https://flutter.dev/docs/development/data-and-backend/state-mgmt/options#bloc--rx"><img src="https://img.shields.io/badge/flutter-website-deepskyblue.svg" alt="Flutter Website"></a>
<a href="https://github.com/Solido/awesome-flutter#standard"><img src="https://img.shields.io/badge/awesome-flutter-blue.svg?longCache=true" alt="Awesome Flutter"></a>
<a href="https://fluttersamples.com"><img src="https://img.shields.io/badge/flutter-samples-teal.svg?longCache=true" alt="Flutter Samples"></a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
<a href="https://discord.gg/Hc5KD3g"><img src="https://img.shields.io/discord/649708778631200778.svg?logo=discord&color=blue" alt="Discord"></a>
<a href="https://github.com/felangel/bloc"><img src="https://tinyurl.com/bloc-library" alt="Bloc Library"></a>
</p>

---

An Angular package that helps implement the [BLoC pattern](https://www.didierboelens.com/2018/08/reactive-programming---streams---bloc).

This package is built to work with [bloc](https://pub.dev/packages/bloc).

## Angular Components

**BlocPipe** is an Angular pipe which helps bind `Bloc` state changes to the presentation layer. `BlocPipe` handles rendering the html element in response to new states. `BlocPipe` is very similar to `AsyncPipe` but has a more simple API to reduce the amount of boilerplate code needed.

## Usage

Lets take a look at how to use `BlocPipe` to hook up a `CounterPage` html template to a `CounterBloc`.

### `counter_bloc.dart`

```dart
enum CounterEvent { increment, decrement }

class CounterBloc extends Bloc<CounterEvent, int> {
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
}
```

### `counter_page_component.html`

```html
<div class="counter-page-container">
  <h1>Counter App</h1>
  <h2>Current Count: {{ counterBloc | bloc }}</h2>
  <button class="counter-button" (click)="increment()">+</button>
  <button class="counter-button" (click)="decrement()">-</button>
</div>
```

### `counter_page_component.dart`

```dart
import 'package:angular/angular.dart';

import 'package:angular_bloc/angular_bloc.dart';

import './counter_bloc.dart';

@Component(
  selector: 'counter-page',
  templateUrl: 'counter_page_component.html',
  styleUrls: ['counter_page_component.css'],
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
    counterBloc.close();
  }

  void increment() {
    counterBloc.add(CounterEvent.increment);
  }

  void decrement() {
    counterBloc.add(CounterEvent.decrement);
  }
}
```

At this point we have successfully separated our presentational layer from our business logic layer. Notice that the `CounterPage` component knows nothing about what happens when a user taps the button. The component simply tells the `CounterBloc` that the user has pressed the increment/decrement button.

## Dart Versions

- Dart 2: >= 2.6.0

## Examples

- [Counter](https://github.com/felangel/Bloc/tree/master/examples/angular_counter) - a complete example of how to create a `CounterBloc` and hook it up to an AngularDart app.
- [Github Search](https://github.com/felangel/Bloc/tree/master/examples/github_search/angular_github_search) - an example of how to create a Github Search Application using the `bloc` and `angular_bloc` packages.

## Maintainers

- [Felix Angelov](https://github.com/felangel)

## Supporters

[<img src="https://raw.githubusercontent.com/felangel/bloc/master/docs/assets/vgv_logo.png" width="120" />](https://verygood.ventures)

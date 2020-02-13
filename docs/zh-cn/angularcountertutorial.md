# AngularDart Counter Tutorial

![beginner](https://img.shields.io/badge/level-beginner-green.svg)

> In the following tutorial, we're going to build a Counter in AngularDart using the Bloc library.

![demo](./assets/gifs/angular_counter.gif)

## Setup

We'll start off by creating a brand new AngularDart project with [stagehand](https://github.com/dart-lang/stagehand).

```bash
stagehand web-angular
```

!> Activate stagehand by running `pub global activate stagehand`

We can then go ahead and replace the contents of `pubspec.yaml` with:

```yaml
name: angular_counter
description: A web app that uses angular_bloc

environment:
  sdk: ">=2.6.0 <3.0.0"

dependencies:
  angular: ^5.3.0
  angular_components: ^0.13.0
  angular_bloc: ^3.0.0

dev_dependencies:
  angular_test: ^2.0.0
  build_runner: ">=1.6.2 <2.0.0"
  build_test: ^0.10.2
  build_web_compilers: ">=1.2.0 <3.0.0"
  test: ^1.0.0
```

and then install all of our dependencies

```bash
pub get
```

Our counter app is just going to have two buttons to increment/decrement the counter value and an element to display the current value. Let's get started designing the `CounterEvents`.

## Counter Events

```dart
enum CounterEvent { increment, decrement }
```

## Counter States

Since our counter's state can be represented by an integer we don't need to create a custom class!

## Counter Bloc

```dart
class CounterBloc extends Bloc<CounterEvent, int> {
  @override
  int get initialState => 0;

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

?> **Note**: Just from the class declaration we can tell that our `CounterBloc` will be taking `CounterEvents` as input and outputting integers.

## Counter App

Now that we have our `CounterBloc` fully implemented, we can get started creating our AngularDart App Component.

Our `app.component.dart` should look like:

```dart
import 'package:angular/angular.dart';

import 'package:angular_counter/src/counter_page/counter_page_component.dart';

@Component(
  selector: 'my-app',
  templateUrl: 'app_component.html',
  directives: [CounterPageComponent],
)
class AppComponent {}
```

and our `app.component.html` should look like:

```html
<counter-page></counter-page>
```

## Counter Page

Finally, all that's left is to build our Counter Page Component.

Our `counter_page_component.dart` should look like:

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
  providers: [ClassProvider(CounterBloc)],
  pipes: [BlocPipe],
)
class CounterPageComponent implements OnDestroy {
  final CounterBloc counterBloc;

  CounterPageComponent(this.counterBloc) {}

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

?> **Note**: We are able to access the `CounterBloc` instance using AngularDart's dependency injection system. Because we have registered it as a `Provider`, AngularDart can properly resolve `CounterBloc`.

?> **Note**: We are closing the `CounterBloc` in `ngOnDestroy`.

?> **Note**: We are importing the `BlocPipe` so that we can use it in our template.

Lastly, our `counter_page_component.html` should look like:

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

?> **Note**: We are using the `BlocPipe` so that we can display our counterBloc state as it is updated.

That's it! We've separated our presentation layer from our business logic layer. Our `CounterPageComponent` has no idea what happens when a user presses a button; it just adds an event to notify the `CounterBloc`. Furthermore, our `CounterBloc` has no idea what is happening with the state (counter value); it's simply converting the `CounterEvents` into integers.

We can run our app with `webdev serve` and can view it [locally](http://localhost:8080).

The full source for this example can be found [here](https://github.com/felangel/Bloc/tree/master/examples/angular_counter).

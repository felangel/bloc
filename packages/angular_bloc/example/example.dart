import 'dart:async';

import 'package:angular/angular.dart';

import 'package:angular_bloc/angular_bloc.dart';

import 'package:bloc/bloc.dart';

@Component(
  selector: 'my-app',
  template: '<counter-page></counter-page>',
  directives: [CounterPageComponent],
)
class AppComponent {}

abstract class CounterEvent {}

class Increment extends CounterEvent {
  @override
  String toString() => 'Increment';
}

class Decrement extends CounterEvent {
  @override
  String toString() => 'Decrement';
}

class CounterBloc extends Bloc<CounterEvent, int> {
  @override
  int get initialState => 0;

  @override
  void onTransition(Transition<CounterEvent, int> transition) {
    print(transition.toString());
  }

  @override
  Stream<int> mapEventToState(int state, CounterEvent event) async* {
    if (event is Increment) {
      yield state + 1;
    }
    if (event is Decrement) {
      yield state - 1;
    }
  }
}

const String template =
    '<div class="counter-page-container"><h1>Counter App</h1><h2>Current Count: {{ counterBloc | bloc }}</h2><button (click)="increment()">+</button><button (click)="decrement()">-</button></div>';

@Component(
  selector: 'counter-page',
  styleUrls: ['counter_page_component.css'],
  pipes: [BlocPipe],
  template: template,
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

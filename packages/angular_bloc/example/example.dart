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

enum CounterEvent { increment, decrement }

class CounterBloc extends Bloc<CounterEvent, int> {
  @override
  int get initialState => 0;

  @override
  void onTransition(Transition<CounterEvent, int> transition) {
    print(transition);
  }

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
    counterBloc.dispatch(CounterEvent.increment);
  }

  void decrement() {
    counterBloc.dispatch(CounterEvent.decrement);
  }
}

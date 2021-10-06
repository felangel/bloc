// This example is one-pager for the [angular_bloc](https://github.com/felangel/bloc/tree/master/examples/angular_counter) example.

import 'package:angular/angular.dart';
import 'package:angular_bloc/angular_bloc.dart';

@Component(
  selector: 'my-app',
  template: '<counter-page></counter-page>',
  directives: [CounterPageComponent],
)
class AppComponent {}

abstract class CounterEvent {}

class Increment extends CounterEvent {}

class Decrement extends CounterEvent {}

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0) {
    on<Increment>((event, emit) => emit(state + 1));
    on<Decrement>((event, emit) => emit(state - 1));
  }

  @override
  void onTransition(Transition<CounterEvent, int> transition) {
    super.onTransition(transition);
    print(transition);
  }
}

const String template =
    r'''<div><h1>Counter App</h1><h2>Current Count: {{ $pipe.bloc(counterBloc) }}</h2><button (click)="increment()">+</button><button (click)="decrement()">-</button></div>''';

@Component(
  selector: 'counter-page',
  pipes: [BlocPipe],
  template: template,
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

  void increment() => counterBloc.add(Increment());

  void decrement() => counterBloc.add(Decrement());
}

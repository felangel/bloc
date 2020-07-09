// This example is one-pager for the [angular_cubit](https://github.com/felangel/cubit/tree/master/examples/angular_counter) example.

import 'package:angular/angular.dart';

import 'package:angular_cubit/angular_cubit.dart';

import 'package:cubit/cubit.dart';

@Component(
  selector: 'my-app',
  template: '<counter-page></counter-page>',
  directives: [CounterPageComponent],
)
class AppComponent {}

enum CounterEvent { increment, decrement }

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  @override
  void onTransition(Transition<int> transition) {
    print(transition);
    super.onTransition(transition);
  }

  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);
}

const String template =
    '<div class="counter-page-container"><h1>Counter App</h1><h2>Current Count: {{ counterCubit | cubit }}</h2><button (click)="counterCubit.increment()">+</button><button (click)="counterCubit.decrement()">-</button></div>';

@Component(
  selector: 'counter-page',
  styleUrls: ['counter_page_component.css'],
  pipes: [CubitPipe],
  template: template,
)
class CounterPageComponent implements OnInit, OnDestroy {
  CounterCubit counterCubit;

  @override
  void ngOnInit() {
    counterCubit = CounterCubit();
  }

  @override
  void ngOnDestroy() {
    counterCubit.close();
  }
}

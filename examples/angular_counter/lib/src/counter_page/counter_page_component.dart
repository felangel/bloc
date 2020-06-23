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

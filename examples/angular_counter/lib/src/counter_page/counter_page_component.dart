import 'package:angular_bloc/angular_bloc.dart';
import 'package:angular_counter/src/counter_page/counter_bloc.dart';
import 'package:ngdart/angular.dart';

/// {@template counter_page}
/// Counter page component which renders a counter
/// and allows users to increment/decrement the counter.
/// {@endtemplate}
@Component(
  selector: 'counter-page',
  templateUrl: 'counter_page_component.html',
  styleUrls: ['counter_page_component.css'],
  providers: [ClassProvider(CounterBloc)],
  pipes: [BlocPipe],
)
class CounterPageComponent implements OnDestroy {
  /// {@macro counter_page}
  const CounterPageComponent(this.counterBloc);

  /// The associated [CounterBloc] which manages the count.
  final CounterBloc counterBloc;

  @override
  void ngOnDestroy() {
    counterBloc.close();
  }

  /// Increment the count.
  void increment() => counterBloc.add(CounterIncrementPressed());

  /// Decrement the count.
  void decrement() => counterBloc.add(CounterDecrementPressed());
}

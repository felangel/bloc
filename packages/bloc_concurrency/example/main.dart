// ignore_for_file: avoid_print
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

Future<void> tick() => Future<void>.delayed(Duration.zero);

Future<void> main() async {
  /// Create a `CounterBloc` instance.
  final bloc = CounterBloc();

  final subscription = bloc.stream.listen(print);

  /// Interact with the `bloc` to trigger `state` changes.
  bloc.add(CounterIncremented());
  await tick();
  bloc.add(CounterIncremented());
  await tick();
  bloc.add(CounterIncremented());
  await tick();

  await Future<void>.delayed(const Duration(seconds: 1));

  /// Close the `bloc` when it is no longer needed.
  await bloc.close();

  /// Cancel the subscription.
  await subscription.cancel();
}

/// The events which `CounterBloc` will react to.
abstract class CounterEvent {}

/// Notifies bloc to increment state.
class CounterIncremented extends CounterEvent {}

/// A `CounterBloc` which handles converting `CounterEvent`s into `int`s.
class CounterBloc extends Bloc<CounterEvent, int> {
  /// The initial state of the `CounterBloc` is 0.
  CounterBloc() : super(0) {
    /// When a `CounterIncremented` event is added,
    /// the current `state` of the bloc is accessed via the `state` property
    /// and a new state is emitted via `emit`.
    on<CounterIncremented>(
      (event, emit) async {
        await Future<void>.delayed(const Duration(seconds: 1));
        emit(state + 1);
      },

      /// Specify a custom event transformer
      /// in this case events will be processed sequentially.
      transformer: sequential(),
    );
  }
}

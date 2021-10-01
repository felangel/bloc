import 'package:bloc/bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';

import 'blocs/blocs.dart';

@immutable
class CounterState {
  const CounterState([this.counter]);

  final int? counter;

  CounterState copyWith(int? counter) => CounterState(counter);
}

class CounterExtBloc extends Bloc<CounterEvent, CounterState> {
  CounterExtBloc() : super(const CounterState()) {
    on<CounterEvent>((event, emit) {
      switch (event) {
        case CounterEvent.increment:
          if (state.counter == 2) {
            return emit(state.copyWith(null));
          }
          return emit(state.copyWith((state.counter ?? 0) + 1));
      }
    });
  }
}

void main() {
  group('blocTest', () {
    group('CounterExtBloc', () {
      blocTest<CounterExtBloc, CounterState>(
        'emits [1, 2] when CounterEvent.increment is called multiple times '
        'with async act',
        build: () => CounterExtBloc(),
        act: (bloc) async {
          bloc
            ..add(CounterEvent.increment)
            ..add(CounterEvent.increment)
            ..add(CounterEvent.increment)
            ..add(CounterEvent.increment);
        },
        map: (CounterState state) => state.counter,
        expect: () => const <int?>[1, 2, null, 1],
      );
    });
  });
}

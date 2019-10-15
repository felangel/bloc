import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

enum CounterEvent { increment }

class CounterBloc extends Bloc<CounterEvent, int> {
  @override
  int get initialState => 0;

  @override
  Stream<int> mapEventToState(
    CounterEvent event,
  ) async* {
    switch (event) {
      case CounterEvent.increment:
        yield state + 1;
        break;
    }
  }
}

// Mock Bloc
class MockCounterBloc extends Mock implements CounterBloc {}

void main() {
  test("Let's mock the CounterBloc's stream!", () {
    // Create Mock CounterBloc Instance
    final counterBloc = MockCounterBloc();

    // Stub the listen with a fake Stream
    whenListen(counterBloc, Stream.fromIterable([0, 1, 2, 3]));

    // Expect that the CounterBloc instance emitted the stubbed Stream of states
    expectLater(counterBloc, emitsInOrder(<int>[0, 1, 2, 3]));
  });
}

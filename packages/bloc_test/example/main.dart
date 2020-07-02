import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:test/test.dart';

enum CounterEvent { increment }

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0);

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.increment:
        yield state + 1;
        break;
    }
  }
}

// Mock Bloc
class MockCounterBloc extends MockBloc<CounterEvent, int>
    implements CounterBloc {}

void main() {
  group('whenListen', () {
    test("Let's mock the CounterBloc's stream!", () {
      // Create Mock CounterBloc Instance
      final counterBloc = MockCounterBloc();

      // Stub the listen with a fake Stream
      whenListen(counterBloc, Stream.fromIterable([0, 1, 2, 3]));

      // Expect that the CounterBloc instance emitted the stubbed Stream of
      // states
      expectLater(counterBloc, emitsInOrder(<int>[0, 1, 2, 3]));
    });
  });

  group('emitsExactly', () {
    test('emits [] when nothing is added', () async {
      final bloc = CounterBloc();
      await emitsExactly(bloc, []);
    });

    test('emits [1] when CounterEvent.increment is added', () async {
      final bloc = CounterBloc();
      bloc.add(CounterEvent.increment);
      await emitsExactly(bloc, [1]);
    });
  });

  group('blocTest', () {
    blocTest(
      'emits [] when nothing is added',
      build: () async => CounterBloc(),
      expect: [],
    );

    blocTest(
      'emits [1] when CounterEvent.increment is added',
      build: () async => CounterBloc(),
      act: (bloc) => bloc.add(CounterEvent.increment),
      expect: [1],
    );
  });
}

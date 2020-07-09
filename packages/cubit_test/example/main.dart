import 'dart:async';

import 'package:cubit/cubit.dart';
import 'package:cubit_test/cubit_test.dart';
import 'package:test/test.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
}

// Mock Cubit
class MockCounterCubit extends MockCubit<int> implements CounterCubit {}

void main() {
  group('whenListen', () {
    test("Let's mock the CounterCubit's stream!", () {
      // Create mock CounterCubit instance.
      final counterCubit = MockCounterCubit();

      // Stub the listen with a fake Stream.
      whenListen<CounterCubit, int>(
        counterCubit,
        Stream.fromIterable([0, 1, 2, 3]),
      );

      // Expect that the CounterCubit instance emits the stubbed states.
      expectLater(counterCubit, emitsInOrder(<int>[0, 1, 2, 3]));
    });
  });

  group('cubitTest', () {
    cubitTest<CounterCubit, int>(
      'emits [] when nothing is called',
      build: () async => CounterCubit(),
      expect: <int>[],
    );

    cubitTest<CounterCubit, int>(
      'emits [1] when increment is called',
      build: () async => CounterCubit(),
      act: (cubit) async => cubit.increment(),
      expect: <int>[1],
    );
  });
}

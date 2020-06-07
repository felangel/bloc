import 'dart:async';

import 'package:test/test.dart';

import 'cubits/counter_cubit.dart';

void main() {
  group('cubit', () {
    group('initial state', () {
      test('is correct', () {
        expect(CounterCubit().state, 0);
      });
    });

    group('emit', () {
      test('does nothing if cubit is closed', () async {
        final cubit = CounterCubit();
        await cubit.close();
        cubit.increment();
        await expectLater(cubit, emitsInOrder(<Matcher>[equals(0), emitsDone]));
      });

      test('emits states in the correct order', () async {
        final states = <int>[];
        final cubit = CounterCubit()
          ..listen(states.add)
          ..increment();
        await cubit.close();
        await Future<void>.delayed(Duration.zero);
        expect(states, [1]);
      });
    });

    group('listen', () {
      test('returns a StreamSubscription', () async {
        final cubit = CounterCubit();
        final subscription = cubit.listen((_) {});
        expect(subscription, isA<StreamSubscription<int>>());
        await subscription.cancel();
        await cubit.close();
      });

      test('recieves initialState immediately upon subscribing', () async {
        final states = <int>[];
        final cubit = CounterCubit()..listen(states.add);
        await cubit.close();
        expect(states, [equals(0)]);
      });

      test('can call listen multiple times', () async {
        final states = <int>[];
        final cubit = CounterCubit()..listen(states.add)..listen(states.add);
        await cubit.close();
        expect(states, [equals(0), equals(0)]);
      });
    });

    test('isBroadcast returns true', () {
      expect(CounterCubit().isBroadcast, isTrue);
    });
  });
}

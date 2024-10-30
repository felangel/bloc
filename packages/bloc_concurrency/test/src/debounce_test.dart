// ignore_for_file: avoid_redundant_argument_values

import 'package:bloc_concurrency/src/debounce.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  group('debounceFirst', () {
    test('should debounce all events', () async {
      final states = <int>[];
      final bloc = CounterBloc(
        debounce(duration: const Duration(milliseconds: 20)),
      )
        ..stream.listen(states.add)
        ..add(Increment())
        ..add(Increment())
        ..add(Increment());

      await tick();

      expect(
        bloc.onCalls,
        equals([]),
      );

      await wait();

      expect(
        bloc.onEmitCalls,
        equals([]),
      );

      expect(
        bloc.onCalls,
        equals([Increment()]),
      );

      await wait();

      expect(
        bloc.onEmitCalls,
        equals([Increment()]),
      );

      expect(states, equals([1]));

      await bloc.close();

      expect(
        bloc.onCalls,
        equals([Increment()]),
      );

      expect(
        bloc.onEmitCalls,
        equals([Increment()]),
      );

      expect(states, equals([1]));
    });

    test('should not debounce first event, and then debounce following events',
        () async {
      final states = <int>[];
      final bloc = CounterBloc(
        debounce(
          duration: const Duration(milliseconds: 20),
          leading: true,
        ),
      )
        ..stream.listen(states.add)
        ..add(Increment())
        ..add(Increment())
        ..add(Increment());

      await tick();

      expect(
        bloc.onCalls,
        equals([Increment()]),
      );

      await wait();

      expect(
        bloc.onEmitCalls,
        equals([Increment()]),
      );

      expect(
        bloc.onCalls,
        equals([Increment(), Increment()]),
      );

      await wait();

      expect(
        bloc.onEmitCalls,
        equals([Increment(), Increment()]),
      );

      expect(states, equals([1, 2]));

      await bloc.close();

      expect(
        bloc.onCalls,
        equals([Increment(), Increment()]),
      );

      expect(
        bloc.onEmitCalls,
        equals([Increment(), Increment()]),
      );

      expect(states, equals([1, 2]));
    });

    test('should throw assertion error when duration is negative', () {
      expect(
        () => CounterBloc(
          debounce(
            duration: const Duration(milliseconds: -20),
          ),
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}

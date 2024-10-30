// ignore_for_file: avoid_redundant_argument_values

import 'package:bloc_concurrency/src/concurrent.dart';
import 'package:bloc_concurrency/src/debounce.dart';
import 'package:bloc_concurrency/src/sequential.dart';
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

      expect(bloc.onCalls, isEmpty);
      expect(bloc.onEmitCalls, isEmpty);

      await wait();

      expect(bloc.onEmitCalls, isEmpty);
      expect(bloc.onCalls, hasLength(1));

      await wait();

      expect(bloc.onCalls, hasLength(1));
      expect(bloc.onEmitCalls, hasLength(1));
      expect(states, [1]);

      await bloc.close();
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

      expect(bloc.onCalls, hasLength(1));
      expect(bloc.onEmitCalls, isEmpty);

      await wait();

      expect(bloc.onCalls, hasLength(2));
      expect(bloc.onEmitCalls, hasLength(1));

      await wait();

      expect(bloc.onCalls, hasLength(2));
      expect(bloc.onEmitCalls, hasLength(2));
      expect(states, equals([1, 2]));

      await bloc.close();
    });

    group('transformer', () {
      test('concurrent should process events all at once', () async {
        final states = <int>[];
        final bloc = CounterBloc(
          debounce(
            duration: const Duration(milliseconds: 5),
            transformer: concurrent(),
          ),
        )
          ..stream.listen(states.add)
          ..add(Increment())
          ..add(Increment());

        expect(bloc.onCalls, isEmpty);
        expect(bloc.onEmitCalls, isEmpty);

        // Add events after debounce period
        await Future<void>.delayed(const Duration(milliseconds: 10));
        bloc
          ..add(Increment())
          ..add(Increment());
        await Future<void>.delayed(const Duration(milliseconds: 10));
        bloc
          ..add(Increment())
          ..add(Increment());
        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(bloc.onCalls, hasLength(3));
        expect(bloc.onEmitCalls, isEmpty);
        expect(states, isEmpty);

        await wait();

        expect(bloc.onEmitCalls, hasLength(3));
        expect(states, [1, 2, 3]);
      });

      test('sequential should process events one at a time', () async {
        final states = <int>[];
        final bloc = CounterBloc(
          debounce(
            duration: const Duration(milliseconds: 5),
            transformer: sequential(),
          ),
        )
          ..stream.listen(states.add)
          ..add(Increment())
          ..add(Increment());

        expect(bloc.onCalls, isEmpty);
        expect(bloc.onEmitCalls, isEmpty);

        // Add events after debounce period
        await Future<void>.delayed(const Duration(milliseconds: 10));
        bloc
          ..add(Increment())
          ..add(Increment());
        await Future<void>.delayed(const Duration(milliseconds: 10));
        bloc
          ..add(Increment())
          ..add(Increment());
        await Future<void>.delayed(const Duration(milliseconds: 10));

        var onCallsCount = 1;
        var onEmitCallsCount = 0;

        for (var i = 0; i < 3; i++) {
          expect(bloc.onCalls, hasLength(onCallsCount));
          expect(bloc.onEmitCalls, hasLength(onEmitCallsCount));
          expect(states, [1, 2, 3].take(i));

          onCallsCount++;
          onEmitCallsCount++;

          await wait();
        }

        expect(bloc.onCalls, hasLength(3));
        expect(bloc.onEmitCalls, hasLength(3));
        expect(states, [1, 2, 3]);
      });
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

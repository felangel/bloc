import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  group('droppable', () {
    test('forwards synchronous mapper errors with their stack traces',
        () async {
      final expectedError = Exception('mapper failed');
      late StackTrace expectedStackTrace;
      final errors = <Object>[];
      final stackTraces = <StackTrace>[];
      final uncaughtErrors = <Object>[];
      final done = Completer<void>();

      runZonedGuarded(
        () {
          droppable<int>()(
            Stream<int>.value(0),
            (_) {
              try {
                throw expectedError;
              } catch (error, stackTrace) {
                expectedStackTrace = stackTrace;
                rethrow;
              }
            },
          ).listen(
            null,
            onError: (Object error, StackTrace stackTrace) {
              errors.add(error);
              stackTraces.add(stackTrace);
            },
            onDone: done.complete,
          );
        },
        (error, stackTrace) => uncaughtErrors.add(error),
      );

      await done.future;

      expect(errors, [same(expectedError)]);
      expect(stackTraces.single.toString(), expectedStackTrace.toString());
      expect(uncaughtErrors, isEmpty);
    });

    test('continues mapping events after a synchronous mapper error', () async {
      final expectedError = StateError('mapper failed');
      final uncaughtErrors = <Object>[];
      late Stream<int> stream;

      runZonedGuarded(
        () {
          stream = droppable<int>()(
            Stream<int>.fromIterable([0, 1]),
            (event) {
              if (event == 0) throw expectedError;
              return Stream<int>.value(event);
            },
          );
        },
        (error, stackTrace) => uncaughtErrors.add(error),
      );

      await expectLater(
        stream,
        emitsInOrder([emitsError(same(expectedError)), 1]),
      );
      expect(uncaughtErrors, isEmpty);
    });

    test('processes only the current event and ignores remaining', () async {
      final states = <int>[];
      final bloc = CounterBloc(droppable())
        ..stream.listen(states.add)
        ..add(Increment())
        ..add(Increment())
        ..add(Increment());

      await tick();

      expect(bloc.onCalls, equals([Increment()]));

      await wait();

      expect(bloc.onEmitCalls, equals([Increment()]));
      expect(states, equals([1]));

      bloc
        ..add(Increment())
        ..add(Increment())
        ..add(Increment());

      await tick();

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

      bloc
        ..add(Increment())
        ..add(Increment())
        ..add(Increment());

      await tick();

      expect(
        bloc.onCalls,
        equals([Increment(), Increment(), Increment()]),
      );

      await wait();

      expect(
        bloc.onEmitCalls,
        equals([Increment(), Increment(), Increment()]),
      );
      expect(states, equals([1, 2, 3]));

      await bloc.close();

      expect(
        bloc.onCalls,
        equals([Increment(), Increment(), Increment()]),
      );

      expect(
        bloc.onEmitCalls,
        equals([Increment(), Increment(), Increment()]),
      );

      expect(states, equals([1, 2, 3]));
    });

    test('cancels the mapped subscription when it is active.', () async {
      final states = <int>[];
      final controller = StreamController<int>.broadcast();
      final stream = droppable<int>()(controller.stream, (x) async* {
        await wait();
        yield x;
      });

      final subscription = stream.listen(states.add);

      controller.add(0);

      await wait();

      expect(states, isEmpty);
      expect(controller.hasListener, isTrue);

      await subscription.cancel();

      expect(states, isEmpty);
      expect(controller.hasListener, isFalse);

      await controller.close();

      expect(states, isEmpty);
    });
  });
}

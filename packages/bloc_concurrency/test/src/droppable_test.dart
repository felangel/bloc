import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  group('droppable', () {
    test('forwards synchronous mapper errors', () async {
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

    test('forwards mapper subscription errors', () async {
      final errors = <Object>[];
      final stackTraces = <StackTrace>[];
      final uncaughtErrors = <Object>[];
      final controller = StreamController<int>();
      final subscription = controller.stream.listen(null);
      final done = Completer<void>();

      runZonedGuarded(
        () {
          droppable<int>()(
            controller.stream,
            (v) => Stream.value(v),
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

      expect(
        errors,
        [
          isA<StateError>().having(
            (e) => e.message,
            'message',
            'Stream has already been listened to.',
          ),
        ],
      );
      expect(stackTraces.single.toString(), contains('droppable'));
      expect(uncaughtErrors, isEmpty);

      await subscription.cancel();
      await controller.close();
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

    test('closes the output stream when the source ends mid-event', () async {
      final states = <int>[];
      var isDoneCallCount = 0;
      final controller = StreamController<int>();
      final stream = droppable<int>()(controller.stream, (x) async* {
        await wait();
        yield x;
      });

      final subscription = stream.listen(
        states.add,
        onDone: () => isDoneCallCount++,
      );

      controller.add(0);

      await tick();
      await controller.close();

      expect(isDoneCallCount, equals(0));
      expect(states, isEmpty);

      await wait();
      await tick();

      expect(isDoneCallCount, equals(1));
      expect(states, equals([0]));

      await subscription.cancel();
    });

    test('cancels source promptly if mapped cancellation stalls', () async {
      var sourceCancelled = false;
      final mappedCancelRelease = Completer<void>();
      final source = StreamController<int>(
        onCancel: () => sourceCancelled = true,
      );
      final mapped = StreamController<int>(
        onCancel: () => mappedCancelRelease.future,
      );
      final subscription = droppable<int>()(
        source.stream,
        (_) => mapped.stream,
      ).listen((_) {});

      source.add(1);
      await tick();

      var cancelCompleted = false;
      final cancelling =
          subscription.cancel().then((_) => cancelCompleted = true);

      expect(sourceCancelled, isTrue);
      expect(cancelCompleted, isFalse);

      mappedCancelRelease.complete();
      await cancelling;

      expect(cancelCompleted, isTrue);
    });

    test('releases the source when cancelled while idle', () async {
      final source = StreamController<int>.broadcast();
      final output = droppable<int>()(
        source.stream,
        (event) => Stream<int>.value(event),
      );
      final subscription = output.listen((_) {});

      expect(source.hasListener, isTrue);
      await subscription.cancel();
      expect(source.hasListener, isFalse);

      await source.close();
    });
  });
}

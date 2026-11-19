import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  group('droppable', () {
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

    test('cancels source promptly if mapped cancellation stalls', () async {
      final mappedCancelStarted = Completer<void>();
      final mappedCancelRelease = Completer<void>();
      final sourceCancelled = Completer<void>();
      final source = StreamController<int>(
        onCancel: sourceCancelled.complete,
      );
      final mapped = StreamController<int>(
        onCancel: () {
          mappedCancelStarted.complete();
          return mappedCancelRelease.future;
        },
      );

      final output = droppable<int>()(source.stream, (_) => mapped.stream);
      final subscription = output.listen((_) {});
      source.add(1);
      await tick();

      final cancelling = subscription.cancel();
      await mappedCancelStarted.future.timeout(const Duration(seconds: 1));
      try {
        await sourceCancelled.future.timeout(const Duration(seconds: 1));
      } finally {
        mappedCancelRelease.complete();
      }
      await cancelling.timeout(const Duration(seconds: 1));
      await source.close();
      await mapped.close();
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

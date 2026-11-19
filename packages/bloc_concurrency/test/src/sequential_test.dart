import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  group('sequential', () {
    test('processes events one at a time', () async {
      final states = <int>[];
      final bloc = CounterBloc(sequential())
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
      expect(states, equals([1]));

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

    test('waits for the previous task before starting another', () async {
      final source = StreamController<int>();
      final firstRelease = Completer<void>();
      final started = <int>[];
      final received = <int>[];
      final done = Completer<void>();

      sequential<int>()(source.stream, (event) async* {
        started.add(event);
        if (event == 1) await firstRelease.future;
        yield event;
      }).listen(received.add, onDone: done.complete);

      source
        ..add(1)
        ..add(2);
      await tick();

      expect(started, [1]);

      firstRelease.complete();
      await source.close();
      await done.future.timeout(const Duration(seconds: 1));

      expect(started, [1, 2]);
      expect(received, [1, 2]);
    });

    test('does not serialize handlers of other event types', () async {
      final release = Completer<void>();
      final bloc = TwoHandlerBloc(release.future)
        ..add(SlowEvent())
        ..add(FastEvent());
      await tick();

      expect(bloc.log, ['slow start', 'fast']);

      release.complete();
      await tick();

      expect(bloc.log, ['slow start', 'fast', 'slow end']);
      await bloc.close();
    });
  });
}

import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  group('concurrent', () {
    test('processes events concurrently by default', () async {
      final states = <int>[];
      final bloc = CounterBloc(concurrent())
        ..stream.listen(states.add)
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

    test('starts overlapping tasks and emits completion order', () async {
      final source = StreamController<int>();
      final firstRelease = Completer<void>();
      final secondRelease = Completer<void>();
      final started = <int>[];
      final received = <int>[];
      final done = Completer<void>();

      concurrent<int>()(source.stream, (event) async* {
        started.add(event);
        await (event == 1 ? firstRelease.future : secondRelease.future);
        yield event;
      }).listen(received.add, onDone: done.complete);

      source
        ..add(1)
        ..add(2);
      await tick();

      expect(started, [1, 2]);

      secondRelease.complete();
      await tick();
      firstRelease.complete();
      await source.close();
      await done.future.timeout(const Duration(seconds: 1));

      expect(received, [2, 1]);
    });
  });
}

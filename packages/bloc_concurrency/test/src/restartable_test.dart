import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  group('restartable', () {
    test('processes only the latest event and cancels remaining', () async {
      final states = <int>[];
      final bloc = CounterBloc(restartable())..stream.listen(states.add);
      Future<void> addEvents() async {
        const spacer = Duration(milliseconds: 10);
        await Future<void>.delayed(spacer);
        bloc.add(Increment());
        await Future<void>.delayed(spacer);
        bloc.add(Increment());
        await Future<void>.delayed(spacer);
        bloc.add(Increment());
        await Future<void>.delayed(spacer);
      }

      await tick();
      await addEvents();

      expect(
        bloc.onCalls,
        equals([Increment(), Increment(), Increment()]),
      );

      await wait();

      expect(bloc.onEmitCalls, equals([Increment()]));
      expect(states, equals([1]));

      await tick();
      await addEvents();

      expect(
        bloc.onCalls,
        equals([
          Increment(),
          Increment(),
          Increment(),
          Increment(),
          Increment(),
          Increment(),
        ]),
      );

      await wait();

      expect(
        bloc.onEmitCalls,
        equals([Increment(), Increment()]),
      );

      expect(states, equals([1, 2]));

      await tick();
      await addEvents();

      expect(
        bloc.onCalls,
        equals([
          Increment(),
          Increment(),
          Increment(),
          Increment(),
          Increment(),
          Increment(),
          Increment(),
          Increment(),
          Increment(),
        ]),
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
        equals([
          Increment(),
          Increment(),
          Increment(),
          Increment(),
          Increment(),
          Increment(),
          Increment(),
          Increment(),
          Increment(),
        ]),
      );

      expect(
        bloc.onEmitCalls,
        equals([Increment(), Increment(), Increment()]),
      );

      expect(states, equals([1, 2, 3]));
    });

    test('cancels stale mapped streams before delivering latest', () async {
      final source = StreamController<int>();
      final mapped = <int, StreamController<int>>{};
      final cancelled = <int>[];
      final received = <int>[];
      final done = Completer<void>();

      restartable<int>()(source.stream, (event) {
        final controller = StreamController<int>(
          onCancel: () => cancelled.add(event),
        );
        mapped[event] = controller;
        return controller.stream;
      }).listen(received.add, onDone: done.complete);

      source.add(1);
      await tick();
      source.add(2);
      await tick();

      expect(cancelled, [1]);

      mapped[2]!.add(2);
      await mapped[2]!.close();
      await source.close();
      await done.future.timeout(const Duration(seconds: 1));

      expect(received, [2]);
    });

    test('does not interrupt work started by a cancelled handler', () async {
      final gates = {1: Completer<void>(), 2: Completer<void>()};
      final states = <int>[];
      final bloc = GatedBloc(restartable(), gates)
        ..stream.listen(states.add)
        ..add(1);
      await tick();
      bloc.add(2);
      await tick();

      gates[1]!.complete();
      await tick();

      expect(bloc.log, ['start 1', 'start 2', 'end 1, isDone: true']);

      gates[2]!.complete();
      await tick();

      expect(bloc.log.last, 'end 2, isDone: false');
      expect(states, [2]);
      await bloc.close();
    });
  });
}

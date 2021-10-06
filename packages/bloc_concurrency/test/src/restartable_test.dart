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
          Increment()
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
          Increment()
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
  });
}

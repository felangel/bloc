import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  group('sequential', () {
    test('processes events one at a time', () async {
      final states = <int>[];
      final bloc = CounterBloc(sequential())
        ..stream.listen(states.add)
        ..add(CounterEvent.increment)
        ..add(CounterEvent.increment)
        ..add(CounterEvent.increment);

      await tick();

      expect(
        bloc.onCalls,
        equals([CounterEvent.increment]),
      );

      await wait();

      expect(
        bloc.onEmitCalls,
        equals([CounterEvent.increment]),
      );
      expect(states, equals([1]));

      await tick();

      expect(
        bloc.onCalls,
        equals([CounterEvent.increment, CounterEvent.increment]),
      );

      await wait();

      expect(
        bloc.onEmitCalls,
        equals([CounterEvent.increment, CounterEvent.increment]),
      );

      expect(states, equals([1, 2]));

      await tick();

      expect(
        bloc.onCalls,
        equals([
          CounterEvent.increment,
          CounterEvent.increment,
          CounterEvent.increment,
        ]),
      );

      await wait();

      expect(
        bloc.onEmitCalls,
        equals([
          CounterEvent.increment,
          CounterEvent.increment,
          CounterEvent.increment,
        ]),
      );

      expect(states, equals([1, 2, 3]));

      await bloc.close();

      expect(
        bloc.onCalls,
        equals([
          CounterEvent.increment,
          CounterEvent.increment,
          CounterEvent.increment,
        ]),
      );

      expect(
        bloc.onEmitCalls,
        equals([
          CounterEvent.increment,
          CounterEvent.increment,
          CounterEvent.increment,
        ]),
      );

      expect(states, equals([1, 2, 3]));
    });
  });
}

import 'package:bloc_concurrency/src/debounce.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  group('debounceFirst', () {
    test('should debounce all events', () async {
      final states = <int>[];
      final bloc = CounterBloc(debounce(const Duration(milliseconds: 20)))
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
  });
}

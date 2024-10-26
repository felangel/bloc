import 'package:bloc_concurrency/src/debounce_first.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  group('debounceFirst', () {
    test('should not debounce first event, and then debounce following events',
        () async {
      final states = <int>[];
      final bloc = CounterBloc(debounceFirst(const Duration(milliseconds: 20)))
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

      await bloc.close();

      expect(
        bloc.onCalls,
        equals([Increment(), Increment()]),
      );

      expect(
        bloc.onEmitCalls,
        equals([Increment(), Increment()]),
      );

      expect(states, equals([1, 2]));
    });
  });
}

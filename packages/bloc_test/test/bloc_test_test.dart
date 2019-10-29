import 'package:bloc_test/bloc_test.dart';
import 'package:test/test.dart';

import 'helpers/helpers.dart';

void main() {
  group('blocTest', () {
    group('CounterBloc', () {
      blocTest(
        'emits [0] when nothing is added',
        setUp: () => CounterBloc(),
        expect: [0],
      );

      blocTest(
        'emits [0, 1] when CounterEvent.increment is added',
        setUp: () => CounterBloc(),
        add: CounterEvent.increment,
        expect: [0, 1],
      );

      test('fails if bloc does not emit all states', () async {
        try {
          await blocTestAssertion(CounterBloc(), [0, 1]);
          fail('should throw');
        } on TestFailure catch (error) {
          expect(
              error.message,
              'Expected: [0, 1]\n'
              '  Actual: [0]\n'
              '   Which: shorter than expected at location [1]\n'
              '');
        }
      });

      test('fails if bloc does not emit correct states', () async {
        try {
          final bloc = CounterBloc();
          bloc.add(CounterEvent.increment);
          await blocTestAssertion(bloc, [0, 2]);
          fail('should throw');
        } on TestFailure catch (error) {
          expect(
            error.message,
            'Expected: [0, 2]\n'
            '  Actual: [0, 1]\n'
            '   Which: was <1> instead of <2> at location [1]\n'
            '',
          );
        }
      });

      test('fails if expecting extra states', () async {
        try {
          final bloc = CounterBloc();
          bloc.add(CounterEvent.increment);
          await blocTestAssertion(bloc, [0, 1, 2]);
          fail('should throw');
        } on TestFailure catch (error) {
          expect(
            error.message,
            'Expected: [0, 1, 2]\n'
            '  Actual: [0, 1]\n'
            '   Which: shorter than expected at location [2]\n'
            '',
          );
        }
      });
    });

    group('MultiCounterBloc', () {
      blocTest(
        'emits [0] when nothing is added',
        setUp: () => MultiCounterBloc(),
        expect: [0],
      );

      blocTest(
        'emits [0, 1, 2] when MultiCounterEvent.increment is added',
        setUp: () => MultiCounterBloc(),
        add: MultiCounterEvent.increment,
        expect: [0, 1, 2],
      );

      test('fails if bloc does not emit all states', () async {
        try {
          await blocTestAssertion(MultiCounterBloc(), [0, 1]);
          fail('should throw');
        } on TestFailure catch (error) {
          expect(
              error.message,
              'Expected: [0, 1]\n'
              '  Actual: [0]\n'
              '   Which: shorter than expected at location [1]\n'
              '');
        }
      });

      test('fails if bloc does not emit correct states', () async {
        try {
          final bloc = MultiCounterBloc();
          bloc.add(MultiCounterEvent.increment);
          await blocTestAssertion(bloc, [0, 2]);
          fail('should throw');
        } on TestFailure catch (error) {
          expect(
            error.message,
            'Expected: [0, 2]\n'
            '  Actual: [0, 1, 2]\n'
            '   Which: was <1> instead of <2> at location [1]\n'
            '',
          );
        }
      });

      test('fails if expecting extra states', () async {
        try {
          final bloc = MultiCounterBloc();
          bloc.add(MultiCounterEvent.increment);
          await blocTestAssertion(bloc, [0, 1, 2, 3]);
          fail('should throw');
        } on TestFailure catch (error) {
          expect(
            error.message,
            'Expected: [0, 1, 2, 3]\n'
            '  Actual: [0, 1, 2]\n'
            '   Which: shorter than expected at location [3]\n'
            '',
          );
        }
      });
    });
  });
}

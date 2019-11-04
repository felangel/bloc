import 'package:bloc_test/bloc_test.dart';
import 'package:test/test.dart';

import 'helpers/helpers.dart';

void main() {
  group('emitsExactly', () {
    test('throws AssertionError if bloc is null', () async {
      try {
        await emitsExactly(null, []);
      } on Object catch (error) {
        expect(error is AssertionError, true);
      }
    });

    group('CounterBloc', () {
      test('emits [0, 1] when CounterEvent.increment is added', () async {
        final bloc = CounterBloc();
        bloc.add(CounterEvent.increment);
        await emitsExactly(bloc, [0, 1]);
      });

      test('fails if bloc does not emit all states', () async {
        try {
          await emitsExactly(CounterBloc(), [0, 1]);
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
          await emitsExactly(bloc, [0, 2]);
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
          await emitsExactly(bloc, [0, 1, 2]);
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

    group('AsyncCounterBloc', () {
      test('emits [0, 1] when CounterEvent.increment is added', () async {
        final bloc = AsyncCounterBloc();
        bloc.add(AsyncCounterEvent.increment);
        await emitsExactly(bloc, [0, 1]);
      });

      test('fails if bloc does not emit all states', () async {
        try {
          await emitsExactly(AsyncCounterBloc(), [0, 1]);
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
          final bloc = AsyncCounterBloc();
          bloc.add(AsyncCounterEvent.increment);
          await emitsExactly(bloc, [0, 2]);
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
          final bloc = AsyncCounterBloc();
          bloc.add(AsyncCounterEvent.increment);
          await emitsExactly(bloc, [0, 1, 2]);
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
      test('emits [0, 1, 2] when CounterEvent.increment is added', () async {
        final bloc = MultiCounterBloc();
        bloc.add(MultiCounterEvent.increment);
        await emitsExactly(bloc, [0, 1, 2]);
      });

      test('fails if bloc does not emit all states', () async {
        try {
          await emitsExactly(MultiCounterBloc(), [0, 1]);
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
          await emitsExactly(bloc, [0, 2]);
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
          await emitsExactly(bloc, [0, 1, 2, 3]);
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

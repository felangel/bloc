import 'package:bloc_test/bloc_test.dart';
import 'package:test/test.dart';

import 'helpers/helpers.dart';

void main() {
  group('emitsExactly', () {
    test('throws AssertionError if bloc is null', () async {
      try {
        await emitsExactly(null, []);
      } on dynamic catch (error) {
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

    group('DebounceCounterBloc', () {
      test('emits [0, 1] when CounterEvent.increment is added', () async {
        final bloc = DebounceCounterBloc();
        bloc.add(DebounceCounterEvent.increment);
        await emitsExactly(bloc, [0, 1],
            duration: const Duration(milliseconds: 305));
      });

      test('fails if bloc does not emit all states', () async {
        try {
          await emitsExactly(DebounceCounterBloc(), [0, 1]);
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
          final bloc = DebounceCounterBloc();
          bloc.add(DebounceCounterEvent.increment);
          await emitsExactly(bloc, [0, 2],
              duration: const Duration(milliseconds: 305));
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
          final bloc = DebounceCounterBloc();
          bloc.add(DebounceCounterEvent.increment);
          await emitsExactly(
            bloc,
            [0, 1, 2],
            duration: const Duration(milliseconds: 305),
          );
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

    group('ComplexBloc', () {
      test('emits [ComplexStateA, ComplexStateB] when ComplexEventB is added',
          () async {
        final bloc = ComplexBloc();
        bloc.add(ComplexEventB());
        await emitsExactly(bloc, [isA<ComplexStateA>(), isA<ComplexStateB>()]);
      });

      test('fails if bloc does not emit all states', () async {
        try {
          await emitsExactly(
              ComplexBloc(), [isA<ComplexStateA>(), isA<ComplexStateB>()]);
          fail('should throw');
        } on TestFailure catch (error) {
          expect(
              error.message,
              // ignore: lines_longer_than_80_chars
              'Expected: [<<Instance of \'ComplexStateA\'>>, <<Instance of \'ComplexStateB\'>>]\n'
              '  Actual: [Instance of \'ComplexStateA\']\n'
              '   Which: shorter than expected at location [1]\n'
              '');
        }
      });

      test('fails if bloc does not emit correct states', () async {
        try {
          final bloc = ComplexBloc();
          bloc.add(ComplexEventA());
          await emitsExactly(
            bloc,
            [isA<ComplexStateA>(), isA<ComplexStateB>()],
          );
          fail('should throw');
        } on TestFailure catch (error) {
          expect(
              error.message,
              // ignore: lines_longer_than_80_chars
              'Expected: [<<Instance of \'ComplexStateA\'>>, <<Instance of \'ComplexStateB\'>>]\n'
              // ignore: lines_longer_than_80_chars
              '  Actual: [Instance of \'ComplexStateA\', Instance of \'ComplexStateA\']\n'
              // ignore: lines_longer_than_80_chars
              '   Which: does not match <Instance of \'ComplexStateB\'> at location [1]\n'
              '');
        }
      });

      test('fails if expecting extra states', () async {
        try {
          final bloc = ComplexBloc();
          bloc.add(ComplexEventB());
          await emitsExactly(
            bloc,
            [isA<ComplexStateA>(), isA<ComplexStateB>(), isA<ComplexStateA>()],
          );
          fail('should throw');
        } on TestFailure catch (error) {
          expect(
              error.message,
              'Expected: [\n'
              '            <<Instance of \'ComplexStateA\'>>,\n'
              '            <<Instance of \'ComplexStateB\'>>,\n'
              '            <<Instance of \'ComplexStateA\'>>\n'
              '          ]\n'
              // ignore: lines_longer_than_80_chars
              '  Actual: [Instance of \'ComplexStateA\', Instance of \'ComplexStateB\']\n'
              '   Which: shorter than expected at location [2]\n'
              '');
        }
      });
    });
  });
}

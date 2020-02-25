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
      test('emits [1] when CounterEvent.increment is added', () async {
        final bloc = CounterBloc();
        bloc.add(CounterEvent.increment);
        await emitsExactly(bloc, [1]);
      });

      test('emits [0, 1] when CounterEvent.increment is added and skip: 0',
          () async {
        final bloc = CounterBloc();
        bloc.add(CounterEvent.increment);
        await emitsExactly(bloc, [0, 1], skip: 0);
      });

      test('fails if bloc does not emit all states', () async {
        try {
          await emitsExactly(CounterBloc(), [1]);
          fail('should throw');
        } on TestFailure catch (error) {
          expect(
              error.message,
              'Expected: [1]\n'
              '  Actual: []\n'
              '   Which: shorter than expected at location [0]\n'
              '');
        }
      });

      test('fails if bloc does not emit correct states', () async {
        try {
          final bloc = CounterBloc();
          bloc.add(CounterEvent.increment);
          await emitsExactly(bloc, [2]);
          fail('should throw');
        } on TestFailure catch (error) {
          expect(
            error.message,
            'Expected: [2]\n'
            '  Actual: [1]\n'
            '   Which: was <1> instead of <2> at location [0]\n'
            '',
          );
        }
      });

      test('fails if expecting extra states', () async {
        try {
          final bloc = CounterBloc();
          bloc.add(CounterEvent.increment);
          await emitsExactly(bloc, [1, 2]);
          fail('should throw');
        } on TestFailure catch (error) {
          expect(
            error.message,
            'Expected: [1, 2]\n'
            '  Actual: [1]\n'
            '   Which: shorter than expected at location [1]\n'
            '',
          );
        }
      });
    });

    group('AsyncCounterBloc', () {
      test('emits [1] when CounterEvent.increment is added', () async {
        final bloc = AsyncCounterBloc();
        bloc.add(AsyncCounterEvent.increment);
        await emitsExactly(bloc, [1]);
      });

      test('emits [0, 1] when CounterEvent.increment is added and skip: 0',
          () async {
        final bloc = AsyncCounterBloc();
        bloc.add(AsyncCounterEvent.increment);
        await emitsExactly(bloc, [0, 1], skip: 0);
      });

      test('fails if bloc does not emit all states', () async {
        try {
          await emitsExactly(AsyncCounterBloc(), [1]);
          fail('should throw');
        } on TestFailure catch (error) {
          expect(
              error.message,
              'Expected: [1]\n'
              '  Actual: []\n'
              '   Which: shorter than expected at location [0]\n'
              '');
        }
      });

      test('fails if bloc does not emit correct states', () async {
        try {
          final bloc = AsyncCounterBloc();
          bloc.add(AsyncCounterEvent.increment);
          await emitsExactly(bloc, [2]);
          fail('should throw');
        } on TestFailure catch (error) {
          expect(
            error.message,
            'Expected: [2]\n'
            '  Actual: [1]\n'
            '   Which: was <1> instead of <2> at location [0]\n'
            '',
          );
        }
      });

      test('fails if expecting extra states', () async {
        try {
          final bloc = AsyncCounterBloc();
          bloc.add(AsyncCounterEvent.increment);
          await emitsExactly(bloc, [1, 2]);
          fail('should throw');
        } on TestFailure catch (error) {
          expect(
            error.message,
            'Expected: [1, 2]\n'
            '  Actual: [1]\n'
            '   Which: shorter than expected at location [1]\n'
            '',
          );
        }
      });
    });

    group('DebounceCounterBloc', () {
      test('emits [1] when CounterEvent.increment is added', () async {
        final bloc = DebounceCounterBloc();
        bloc.add(DebounceCounterEvent.increment);
        await emitsExactly(bloc, [1],
            duration: const Duration(milliseconds: 305));
      });

      test('emits [0, 1] when CounterEvent.increment is added and skip: 0',
          () async {
        final bloc = DebounceCounterBloc();
        bloc.add(DebounceCounterEvent.increment);
        await emitsExactly(
          bloc,
          [0, 1],
          duration: const Duration(milliseconds: 305),
          skip: 0,
        );
      });

      test('fails if bloc does not emit all states', () async {
        try {
          await emitsExactly(DebounceCounterBloc(), [1]);
          fail('should throw');
        } on TestFailure catch (error) {
          expect(
              error.message,
              'Expected: [1]\n'
              '  Actual: []\n'
              '   Which: shorter than expected at location [0]\n'
              '');
        }
      });

      test('fails if bloc does not emit correct states', () async {
        try {
          final bloc = DebounceCounterBloc();
          bloc.add(DebounceCounterEvent.increment);
          await emitsExactly(bloc, [2],
              duration: const Duration(milliseconds: 305));
          fail('should throw');
        } on TestFailure catch (error) {
          expect(
            error.message,
            'Expected: [2]\n'
            '  Actual: [1]\n'
            '   Which: was <1> instead of <2> at location [0]\n'
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
            [1, 2],
            duration: const Duration(milliseconds: 305),
          );
          fail('should throw');
        } on TestFailure catch (error) {
          expect(
            error.message,
            'Expected: [1, 2]\n'
            '  Actual: [1]\n'
            '   Which: shorter than expected at location [1]\n'
            '',
          );
        }
      });
    });

    group('MultiCounterBloc', () {
      test('emits [1, 2] when CounterEvent.increment is added', () async {
        final bloc = MultiCounterBloc();
        bloc.add(MultiCounterEvent.increment);
        await emitsExactly(bloc, [1, 2]);
      });

      test('emits [0, 1, 2] when CounterEvent.increment is added and skip: 0',
          () async {
        final bloc = MultiCounterBloc();
        bloc.add(MultiCounterEvent.increment);
        await emitsExactly(bloc, [0, 1, 2], skip: 0);
      });

      test('fails if bloc does not emit all states', () async {
        try {
          await emitsExactly(MultiCounterBloc(), [1]);
          fail('should throw');
        } on TestFailure catch (error) {
          expect(
              error.message,
              'Expected: [1]\n'
              '  Actual: []\n'
              '   Which: shorter than expected at location [0]\n'
              '');
        }
      });

      test('fails if bloc does not emit correct states', () async {
        try {
          final bloc = MultiCounterBloc();
          bloc.add(MultiCounterEvent.increment);
          await emitsExactly(bloc, [2]);
          fail('should throw');
        } on TestFailure catch (error) {
          expect(
            error.message,
            'Expected: [2]\n'
            '  Actual: [1, 2]\n'
            '   Which: was <1> instead of <2> at location [0]\n'
            '',
          );
        }
      });

      test('fails if expecting extra states', () async {
        try {
          final bloc = MultiCounterBloc();
          bloc.add(MultiCounterEvent.increment);
          await emitsExactly(bloc, [1, 2, 3]);
          fail('should throw');
        } on TestFailure catch (error) {
          expect(
            error.message,
            'Expected: [1, 2, 3]\n'
            '  Actual: [1, 2]\n'
            '   Which: shorter than expected at location [2]\n'
            '',
          );
        }
      });
    });

    group('ComplexBloc', () {
      test('emits [ComplexStateB] when ComplexEventB is added', () async {
        final bloc = ComplexBloc();
        bloc.add(ComplexEventB());
        await emitsExactly(bloc, [isA<ComplexStateB>()]);
      });

      test(
          'emits [ComplexStateA, ComplexStateB] when ComplexEventB '
          'is added and skip: 0', () async {
        final bloc = ComplexBloc();
        bloc.add(ComplexEventB());
        await emitsExactly(
          bloc,
          [isA<ComplexStateA>(), isA<ComplexStateB>()],
          skip: 0,
        );
      });

      test('fails if bloc does not emit all states', () async {
        try {
          await emitsExactly(ComplexBloc(), [isA<ComplexStateB>()]);
          fail('should throw');
        } on TestFailure catch (error) {
          expect(
              error.message,
              'Expected: [<<Instance of \'ComplexStateB\'>>]\n'
              '  Actual: []\n'
              '   Which: shorter than expected at location [0]\n'
              '');
        }
      });

      test('fails if bloc does not emit correct states', () async {
        try {
          final bloc = ComplexBloc();
          bloc.add(ComplexEventA());
          await emitsExactly(
            bloc,
            [isA<ComplexStateB>()],
          );
          fail('should throw');
        } on TestFailure catch (error) {
          expect(
              error.message,
              'Expected: [<<Instance of \'ComplexStateB\'>>]\n'
              '  Actual: [Instance of \'ComplexStateA\']\n'
              // ignore: lines_longer_than_80_chars
              '   Which: does not match <Instance of \'ComplexStateB\'> at location [0]\n'
              '');
        }
      });

      test('fails if expecting extra states', () async {
        try {
          final bloc = ComplexBloc();
          bloc.add(ComplexEventB());
          await emitsExactly(
            bloc,
            [isA<ComplexStateB>(), isA<ComplexStateA>()],
          );
          fail('should throw');
        } on TestFailure catch (error) {
          expect(
              error.message,
              // ignore: lines_longer_than_80_chars
              'Expected: [<<Instance of \'ComplexStateB\'>>, <<Instance of \'ComplexStateA\'>>]\n'
              '  Actual: [Instance of \'ComplexStateB\']\n'
              '   Which: shorter than expected at location [1]\n'
              '');
        }
      });
    });
  });
}

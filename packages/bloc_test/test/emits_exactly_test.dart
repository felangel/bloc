import 'package:bloc_test/bloc_test.dart';
import 'package:test/test.dart';

import 'blocs/blocs.dart';

void main() {
  group('emitsExactly', () {
    test('throws AssertionError if bloc is null', () async {
      try {
        await emitsExactly<CounterBloc, int>(null, const <int>[]);
      } on dynamic catch (error) {
        expect(error is AssertionError, true);
      }
    });

    group('CounterBloc', () {
      test('emits [1] when CounterEvent.increment is added', () async {
        final bloc = CounterBloc()..add(CounterEvent.increment);
        await emitsExactly<CounterBloc, int>(bloc, const <int>[1]);
      });

      test('emits [2] when CounterEvent.increment twice is added and skip: 1',
          () async {
        final bloc = CounterBloc()
          ..add(CounterEvent.increment)
          ..add(CounterEvent.increment);
        await emitsExactly<CounterBloc, int>(bloc, const <int>[2], skip: 1);
      });

      test('fails if bloc does not emit all states', () async {
        try {
          await emitsExactly<CounterBloc, int>(CounterBloc(), const <int>[1]);
          fail('should throw');
        } on TestFailure catch (error) {
          expect(
              error.message,
              'Expected: [1]\n'
              '  Actual: []\n'
              '   Which: at location [0] is [] which shorter than expected\n'
              '');
        }
      });

      test('fails if bloc does not emit correct states', () async {
        try {
          final bloc = CounterBloc()..add(CounterEvent.increment);
          await emitsExactly<CounterBloc, int>(bloc, const <int>[2]);
          fail('should throw');
        } on TestFailure catch (error) {
          expect(
            error.message,
            'Expected: [2]\n'
            '  Actual: [1]\n'
            '   Which: at location [0] is <1> instead of <2>\n'
            '',
          );
        }
      });

      test('fails if expecting extra states', () async {
        try {
          final bloc = CounterBloc()..add(CounterEvent.increment);
          await emitsExactly<CounterBloc, int>(bloc, const <int>[1, 2]);
          fail('should throw');
        } on TestFailure catch (error) {
          expect(
            error.message,
            'Expected: [1, 2]\n'
            '  Actual: [1]\n'
            '   Which: at location [1] is [1] which shorter than expected\n'
            '',
          );
        }
      });
    });

    group('AsyncCounterBloc', () {
      test('emits [1] when CounterEvent.increment is added', () async {
        final bloc = AsyncCounterBloc()..add(AsyncCounterEvent.increment);
        await emitsExactly<AsyncCounterBloc, int>(bloc, const <int>[1]);
      });

      test('emits [2] when CounterEvent.increment is added twice and skip: 1',
          () async {
        final bloc = AsyncCounterBloc()
          ..add(AsyncCounterEvent.increment)
          ..add(AsyncCounterEvent.increment);
        await emitsExactly<AsyncCounterBloc, int>(
          bloc,
          const <int>[2],
          skip: 1,
        );
      });

      test('fails if bloc does not emit all states', () async {
        try {
          await emitsExactly<AsyncCounterBloc, int>(
            AsyncCounterBloc(),
            const <int>[1],
          );
          fail('should throw');
        } on TestFailure catch (error) {
          expect(
              error.message,
              'Expected: [1]\n'
              '  Actual: []\n'
              '   Which: at location [0] is [] which shorter than expected\n'
              '');
        }
      });

      test('fails if bloc does not emit correct states', () async {
        try {
          final bloc = AsyncCounterBloc()..add(AsyncCounterEvent.increment);
          await emitsExactly<AsyncCounterBloc, int>(bloc, const <int>[2]);
          fail('should throw');
        } on TestFailure catch (error) {
          expect(
            error.message,
            'Expected: [2]\n'
            '  Actual: [1]\n'
            '   Which: at location [0] is <1> instead of <2>\n'
            '',
          );
        }
      });

      test('fails if expecting extra states', () async {
        try {
          final bloc = AsyncCounterBloc()..add(AsyncCounterEvent.increment);
          await emitsExactly<AsyncCounterBloc, int>(bloc, const <int>[1, 2]);
          fail('should throw');
        } on TestFailure catch (error) {
          expect(
            error.message,
            'Expected: [1, 2]\n'
            '  Actual: [1]\n'
            '   Which: at location [1] is [1] which shorter than expected\n'
            '',
          );
        }
      });
    });

    group('DebounceCounterBloc', () {
      test('emits [1] when CounterEvent.increment is added', () async {
        final bloc = DebounceCounterBloc()..add(DebounceCounterEvent.increment);
        await emitsExactly<DebounceCounterBloc, int>(bloc, const <int>[1],
            duration: const Duration(milliseconds: 305));
      });

      test('emits [2] when CounterEvent.increment is added twice and skip: 0',
          () async {
        final bloc = DebounceCounterBloc()..add(DebounceCounterEvent.increment);
        await Future<void>.delayed(const Duration(milliseconds: 305));
        bloc.add(DebounceCounterEvent.increment);
        await emitsExactly<DebounceCounterBloc, int>(
          bloc,
          const <int>[2],
          duration: const Duration(milliseconds: 305),
          skip: 0,
        );
      });

      test('fails if bloc does not emit all states', () async {
        try {
          await emitsExactly<DebounceCounterBloc, int>(
            DebounceCounterBloc(),
            const <int>[1],
          );
          fail('should throw');
        } on TestFailure catch (error) {
          expect(
              error.message,
              'Expected: [1]\n'
              '  Actual: []\n'
              '   Which: at location [0] is [] which shorter than expected\n'
              '');
        }
      });

      test('fails if bloc does not emit correct states', () async {
        try {
          final bloc = DebounceCounterBloc()
            ..add(DebounceCounterEvent.increment);
          await emitsExactly<DebounceCounterBloc, int>(
            bloc,
            const <int>[2],
            duration: const Duration(milliseconds: 305),
          );
          fail('should throw');
        } on TestFailure catch (error) {
          expect(
            error.message,
            'Expected: [2]\n'
            '  Actual: [1]\n'
            '   Which: at location [0] is <1> instead of <2>\n'
            '',
          );
        }
      });

      test('fails if expecting extra states', () async {
        try {
          final bloc = DebounceCounterBloc()
            ..add(DebounceCounterEvent.increment);
          await emitsExactly<DebounceCounterBloc, int>(
            bloc,
            const <int>[1, 2],
            duration: const Duration(milliseconds: 305),
          );
          fail('should throw');
        } on TestFailure catch (error) {
          expect(
            error.message,
            'Expected: [1, 2]\n'
            '  Actual: [1]\n'
            '   Which: at location [1] is [1] which shorter than expected\n'
            '',
          );
        }
      });
    });

    group('MultiCounterBloc', () {
      test('emits [1, 2] when CounterEvent.increment is added', () async {
        final bloc = MultiCounterBloc()..add(MultiCounterEvent.increment);
        await emitsExactly<MultiCounterBloc, int>(bloc, const <int>[1, 2]);
      });

      test('emits [2] when CounterEvent.increment is added and skip: 1',
          () async {
        final bloc = MultiCounterBloc()..add(MultiCounterEvent.increment);
        await emitsExactly<MultiCounterBloc, int>(
          bloc,
          const <int>[2],
          skip: 1,
        );
      });

      test('fails if bloc does not emit all states', () async {
        try {
          await emitsExactly<MultiCounterBloc, int>(
            MultiCounterBloc(),
            const <int>[1],
          );
          fail('should throw');
        } on TestFailure catch (error) {
          expect(
              error.message,
              'Expected: [1]\n'
              '  Actual: []\n'
              '   Which: at location [0] is [] which shorter than expected\n'
              '');
        }
      });

      test('fails if bloc does not emit correct states', () async {
        try {
          final bloc = MultiCounterBloc()..add(MultiCounterEvent.increment);
          await emitsExactly<MultiCounterBloc, int>(bloc, const <int>[2]);
          fail('should throw');
        } on TestFailure catch (error) {
          expect(
            error.message,
            'Expected: [2]\n'
            '  Actual: [1, 2]\n'
            '   Which: at location [0] is <1> instead of <2>\n'
            '',
          );
        }
      });

      test('fails if expecting extra states', () async {
        try {
          final bloc = MultiCounterBloc()..add(MultiCounterEvent.increment);
          await emitsExactly<MultiCounterBloc, int>(bloc, const <int>[1, 2, 3]);
          fail('should throw');
        } on TestFailure catch (error) {
          expect(
            error.message,
            'Expected: [1, 2, 3]\n'
            '  Actual: [1, 2]\n'
            '   Which: at location [2] is [1, 2] which shorter than expected\n'
            '',
          );
        }
      });
    });

    group('ComplexBloc', () {
      test('emits [ComplexStateB] when ComplexEventB is added', () async {
        final bloc = ComplexBloc()..add(ComplexEventB());
        await emitsExactly<ComplexBloc, ComplexState>(
          bloc,
          <Matcher>[isA<ComplexStateB>()],
        );
      });

      test(
          'emits [ComplexStateA] when [ComplexEventB, ComplexEventA] '
          'is added and skip: 1', () async {
        final bloc = ComplexBloc()..add(ComplexEventB())..add(ComplexEventA());
        await emitsExactly<ComplexBloc, ComplexState>(
          bloc,
          <Matcher>[isA<ComplexStateA>()],
          skip: 1,
        );
      });

      test('fails if bloc does not emit all states', () async {
        try {
          await emitsExactly<ComplexBloc, ComplexState>(
            ComplexBloc(),
            <Matcher>[isA<ComplexStateB>()],
          );
          fail('should throw');
        } on TestFailure catch (error) {
          expect(
            error.message,
            'Expected: [<<Instance of \'ComplexStateB\'>>]\n'
            '  Actual: []\n'
            '   Which: at location [0] is [] which shorter than expected\n'
            '',
          );
        }
      });

      test('fails if bloc does not emit correct states', () async {
        try {
          final bloc = ComplexBloc()..add(ComplexEventA());
          await emitsExactly<ComplexBloc, ComplexState>(
            bloc,
            <Matcher>[isA<ComplexStateB>()],
          );
          fail('should throw');
        } on TestFailure catch (error) {
          expect(
            error.message,
            'Expected: [<<Instance of \'ComplexStateB\'>>]\n'
            '  Actual: [Instance of \'ComplexStateA\']\n'
            // ignore: lines_longer_than_80_chars
            '   Which: at location [0] is <Instance of \'ComplexStateA\'> which is not an instance of \'ComplexStateB\'\n'
            '',
          );
        }
      });

      test('fails if expecting extra states', () async {
        try {
          final bloc = ComplexBloc()..add(ComplexEventB());
          await emitsExactly<ComplexBloc, ComplexState>(
            bloc,
            <Matcher>[isA<ComplexStateB>(), isA<ComplexStateA>()],
          );
          fail('should throw');
        } on TestFailure catch (error) {
          expect(
            error.message,
            // ignore: lines_longer_than_80_chars
            'Expected: [<<Instance of \'ComplexStateB\'>>, <<Instance of \'ComplexStateA\'>>]\n'
            '  Actual: [Instance of \'ComplexStateB\']\n'
            // ignore: lines_longer_than_80_chars
            '   Which: at location [1] is [Instance of \'ComplexStateB\'] which shorter than expected\n'
            '',
          );
        }
      });
    });
  });
}
